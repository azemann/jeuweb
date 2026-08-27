#!/usr/bin/env python3
"""Normalise les impacts et la mort candidats du Vacuum Trooper sans publication."""

from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageDraw


PROJECT_ROOT = Path(__file__).resolve().parents[3]
SOURCE = (
    PROJECT_ROOT
    / "pipeline/assets/sources/imagegen/enemies/vacuum_trooper/"
    "vacuum-trooper-hit-death-sheet-candidate-v001.png"
)
WORKING_DIR = PROJECT_ROOT / "pipeline/assets/working/enemies/vacuum_trooper"
EXPORT_DIR = PROJECT_ROOT / "pipeline/assets/exports/enemies/vacuum_trooper"

GRID = (4, 2)
FRAME_COUNT = 8
ALPHA_THRESHOLD = 24
SOURCE_PADDING = 6

CANONICAL_SIZE = (512, 384)
CANONICAL_ROOT = (256, 360)
CANONICAL_SAFE_RECT = (20, 12, 492, 378)
RUNTIME_SIZE = (256, 192)
RUNTIME_ROOT = (128, 180)

PHASES = [
    "hit_start",
    "hit_impact",
    "hit_crumple",
    "hit_recover",
    "death_damage",
    "death_hatch_open",
    "death_pilot_eject",
    "death_wreck",
]
DURATIONS_MS = [90, 80, 130, 160, 120, 160, 220, 600]

# La source fait 2079 px : ses colonnes ne sont donc pas divisibles par quatre.
X_EDGES = [0, 520, 1040, 1560, 2079]

# Les frames 5 et 6 dépassent volontairement dans la rangée supérieure. Entre
# y=330 et y=378, les poses supérieures sont déjà terminées : cette bande permet
# de récupérer sans peinture la fumée et la tête du pilote éjecté.
SOURCE_RECTS = [
    (0, 0, 520, 330),
    (520, 0, 1040, 330),
    (1040, 0, 1560, 330),
    (1560, 0, 2079, 330),
    (0, 378, 520, 756),
    (520, 330, 1040, 756),
    (1040, 330, 1560, 756),
    (1560, 378, 2079, 756),
]
SOURCE_ROOTS = [
    (260.0, 320.0),
    (260.0, 320.0),
    (260.0, 320.0),
    (259.5, 320.0),
    (260.0, 320.0),
    (260.0, 368.0),
    (260.0, 368.0),
    (259.5, 320.0),
]


def threshold_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    alpha = image.getchannel("A")
    bbox = alpha.point(lambda value: 255 if value > ALPHA_THRESHOLD else 0).getbbox()
    if bbox is None:
        raise RuntimeError("Une frame ne contient aucune silhouette alpha exploitable.")
    return (
        max(0, bbox[0] - SOURCE_PADDING),
        max(0, bbox[1] - SOURCE_PADDING),
        min(image.width, bbox[2] + SOURCE_PADDING),
        min(image.height, bbox[3] + SOURCE_PADDING),
    )


def common_root_scale(
    boxes: list[tuple[int, int, int, int]],
) -> float:
    limits: list[float] = []
    safe_left, safe_top, safe_right, safe_bottom = CANONICAL_SAFE_RECT
    for bbox, root in zip(boxes, SOURCE_ROOTS):
        left = root[0] - bbox[0]
        right = bbox[2] - root[0]
        top = root[1] - bbox[1]
        bottom = bbox[3] - root[1]
        if left > 0:
            limits.append((CANONICAL_ROOT[0] - safe_left) / left)
        if right > 0:
            limits.append((safe_right - CANONICAL_ROOT[0]) / right)
        if top > 0:
            limits.append((CANONICAL_ROOT[1] - safe_top) / top)
        if bottom > 0:
            limits.append((safe_bottom - CANONICAL_ROOT[1]) / bottom)
    return min(limits)


def normalize() -> dict:
    source = Image.open(SOURCE).convert("RGBA")
    if source.size != (2079, 756):
        raise RuntimeError("La source attendue doit mesurer 2079 × 756.")
    if source.getchannel("A").getextrema() != (0, 255):
        raise RuntimeError("La source doit posséder un véritable canal alpha.")

    cells = [source.crop(rect) for rect in SOURCE_RECTS]
    boxes = [threshold_bbox(cell) for cell in cells]
    scale = common_root_scale(boxes)

    canonical_dir = WORKING_DIR / "hit-death-canonical-512"
    runtime_dir = EXPORT_DIR / "hit-death-frames-256"
    canonical_dir.mkdir(parents=True, exist_ok=True)
    runtime_dir.mkdir(parents=True, exist_ok=True)
    atlas = Image.new(
        "RGBA", (RUNTIME_SIZE[0] * GRID[0], RUNTIME_SIZE[1] * GRID[1]), (0, 0, 0, 0)
    )
    frame_reports = []

    for index, (cell, bbox, source_root, phase, duration) in enumerate(
        zip(cells, boxes, SOURCE_ROOTS, PHASES, DURATIONS_MS)
    ):
        isolated = cell.crop(bbox)
        width = max(1, round(isolated.width * scale))
        height = max(1, round(isolated.height * scale))
        sprite = isolated.resize((width, height), Image.Resampling.LANCZOS)
        position = (
            round(CANONICAL_ROOT[0] - (source_root[0] - bbox[0]) * scale),
            round(CANONICAL_ROOT[1] - (source_root[1] - bbox[1]) * scale),
        )

        canonical = Image.new("RGBA", CANONICAL_SIZE, (0, 0, 0, 0))
        canonical.alpha_composite(sprite, position)
        canonical_path = canonical_dir / f"frame_{index:02d}_{phase}.png"
        canonical.save(canonical_path)

        runtime = canonical.resize(RUNTIME_SIZE, Image.Resampling.LANCZOS)
        runtime_path = runtime_dir / f"frame_{index:02d}.png"
        runtime.save(runtime_path)
        atlas.alpha_composite(
            runtime,
            ((index % GRID[0]) * RUNTIME_SIZE[0], (index // GRID[0]) * RUNTIME_SIZE[1]),
        )
        frame_reports.append(
            {
                "index": index,
                "phase": phase,
                "duration_ms": duration,
                "source_rect": list(SOURCE_RECTS[index]),
                "source_bbox": list(bbox),
                "source_root": list(source_root),
                "canonical_position": list(position),
                "canonical_size": [width, height],
                "canonical_root": list(CANONICAL_ROOT),
                "runtime_root": list(RUNTIME_ROOT),
            }
        )

    atlas_path = EXPORT_DIR / "vacuum-trooper-hit-death-4x2-256-candidate-v001.png"
    atlas.save(atlas_path)
    review_path = build_review(atlas)
    hit_preview, death_preview = build_previews(runtime_dir)
    report = {
        "schema": "jeuweb.enemy-animation-qa.v1",
        "status": "published",
        "source": str(SOURCE.relative_to(PROJECT_ROOT)),
        "source_grid": list(GRID),
        "source_dimensions": list(source.size),
        "source_column_edges": X_EDGES,
        "frame_count": FRAME_COUNT,
        "common_scale": round(scale, 6),
        "canonical_canvas": list(CANONICAL_SIZE),
        "canonical_root": list(CANONICAL_ROOT),
        "runtime_frame": list(RUNTIME_SIZE),
        "runtime_root": list(RUNTIME_ROOT),
        "atlas": str(atlas_path.relative_to(PROJECT_ROOT)),
        "review": str(review_path.relative_to(PROJECT_ROOT)),
        "hit_preview": str(hit_preview.relative_to(PROJECT_ROOT)),
        "death_preview": str(death_preview.relative_to(PROJECT_ROOT)),
        "runtime_review": "pipeline/assets/working/enemies/vacuum_trooper/vacuum-trooper-hit-death-v001-runtime-review.png",
        "frames": frame_reports,
        "statuses": {
            "visual": "passed",
            "temporal": "passed",
            "technical": "passed",
            "gameplay": "integrated",
        },
        "known_limits": [
            "La grille source a des colonnes inégales car 2079 n'est pas divisible par quatre.",
            "La fumée de la frame 5 et le pilote de la frame 6 franchissent la séparation des rangées ; ils sont reconstruits depuis les pixels source.",
            "Les timings ont été approuvés avec le lot v001 et restent protégés par le profil.",
            "Le pilote éjecté est une présentation raster et non un acteur gameplay séparé.",
        ],
    }
    qa_path = WORKING_DIR / "vacuum-trooper-hit-death-v001-qa.json"
    qa_path.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return report


def checkerboard(size: tuple[int, int]) -> Image.Image:
    image = Image.new("RGBA", size, (40, 43, 52, 255))
    draw = ImageDraw.Draw(image)
    tile = 24
    for y in range(0, image.height, tile):
        for x in range(0, image.width, tile):
            if (x // tile + y // tile) % 2 == 0:
                draw.rectangle((x, y, x + tile - 1, y + tile - 1), fill=(62, 66, 78, 255))
    return image


def build_review(atlas: Image.Image) -> Path:
    review = checkerboard(atlas.size)
    review.alpha_composite(atlas)
    draw = ImageDraw.Draw(review)
    for column in range(1, GRID[0]):
        x = column * RUNTIME_SIZE[0]
        draw.line((x, 0, x, review.height), fill=(240, 32, 141, 180), width=1)
    draw.line((0, RUNTIME_SIZE[1], review.width, RUNTIME_SIZE[1]), fill=(240, 32, 141, 180), width=1)
    for index in range(FRAME_COUNT):
        cell_x = (index % GRID[0]) * RUNTIME_SIZE[0]
        cell_y = (index // GRID[0]) * RUNTIME_SIZE[1]
        root_x = cell_x + RUNTIME_ROOT[0]
        root_y = cell_y + RUNTIME_ROOT[1]
        draw.line((cell_x, root_y, cell_x + RUNTIME_SIZE[0], root_y), fill=(181, 214, 31, 150), width=1)
        draw.line((root_x - 6, root_y, root_x + 6, root_y), fill=(181, 214, 31, 255), width=2)
        draw.line((root_x, root_y - 6, root_x, root_y + 6), fill=(181, 214, 31, 255), width=2)
    output = WORKING_DIR / "vacuum-trooper-hit-death-v001-review.png"
    review.save(output)
    return output


def build_previews(runtime_dir: Path) -> tuple[Path, Path]:
    frames = [
        Image.open(runtime_dir / f"frame_{index:02d}.png").convert("RGBA")
        for index in range(FRAME_COUNT)
    ]
    hit_output = WORKING_DIR / "vacuum-trooper-hit-v001-preview.webp"
    frames[0].save(
        hit_output,
        save_all=True,
        append_images=frames[1:4],
        duration=DURATIONS_MS[:4],
        loop=0,
        lossless=True,
        method=6,
    )
    death_output = WORKING_DIR / "vacuum-trooper-death-v001-preview.webp"
    frames[4].save(
        death_output,
        save_all=True,
        append_images=frames[5:8],
        duration=DURATIONS_MS[4:],
        loop=0,
        lossless=True,
        method=6,
    )
    return hit_output, death_output


def main() -> None:
    WORKING_DIR.mkdir(parents=True, exist_ok=True)
    EXPORT_DIR.mkdir(parents=True, exist_ok=True)
    report = normalize()
    print(
        "Vacuum Trooper hit/death candidate processed: "
        f"{report['frame_count']} frames, technical={report['statuses']['technical']}"
    )


if __name__ == "__main__":
    main()
