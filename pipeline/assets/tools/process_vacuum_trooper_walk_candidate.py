#!/usr/bin/env python3
"""Normalise le cycle de marche candidat du Vacuum Trooper sans le publier."""

from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageDraw


PROJECT_ROOT = Path(__file__).resolve().parents[3]
SOURCE = (
    PROJECT_ROOT
    / "pipeline/assets/sources/imagegen/enemies/vacuum_trooper/"
    "vacuum-trooper-walk-sheet-candidate-v001.png"
)
WORKING_DIR = PROJECT_ROOT / "pipeline/assets/working/enemies/vacuum_trooper"
EXPORT_DIR = PROJECT_ROOT / "pipeline/assets/exports/enemies/vacuum_trooper"

GRID = (4, 2)
FRAME_COUNT = 8
FRAME_DURATION_MS = 160
ALPHA_THRESHOLD = 24
SOURCE_PADDING = 8

CANONICAL_SIZE = (512, 384)
CANONICAL_ROOT = (256, 360)
CANONICAL_CONTENT_BASELINE = 356
CANONICAL_SAFE = (472, 336)
RUNTIME_SIZE = (256, 192)
RUNTIME_ROOT = (128, 180)

PHASES = [
    "contact_a",
    "compression_a",
    "passing_a",
    "rise_a",
    "contact_b",
    "compression_b",
    "passing_b",
    "rise_b",
]


def threshold_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    alpha = image.getchannel("A")
    mask = alpha.point(lambda value: 255 if value > ALPHA_THRESHOLD else 0)
    bbox = mask.getbbox()
    if bbox is None:
        raise RuntimeError("Une cellule ne contient aucune silhouette alpha exploitable.")
    return (
        max(0, bbox[0] - SOURCE_PADDING),
        max(0, bbox[1] - SOURCE_PADDING),
        min(image.width, bbox[2] + SOURCE_PADDING),
        min(image.height, bbox[3] + SOURCE_PADDING),
    )


def split_source(source: Image.Image) -> tuple[list[Image.Image], tuple[int, int]]:
    if source.width % GRID[0] != 0 or source.height % GRID[1] != 0:
        raise RuntimeError("La source doit être divisible par la grille 4 × 2.")
    cell_size = (source.width // GRID[0], source.height // GRID[1])
    cells = []
    for index in range(FRAME_COUNT):
        column = index % GRID[0]
        row = index // GRID[0]
        cells.append(
            source.crop(
                (
                    column * cell_size[0],
                    row * cell_size[1],
                    (column + 1) * cell_size[0],
                    (row + 1) * cell_size[1],
                )
            )
        )
    return cells, cell_size


def normalize() -> dict:
    source = Image.open(SOURCE).convert("RGBA")
    if source.getextrema()[3][0] == source.getextrema()[3][1]:
        raise RuntimeError("La source doit posséder un canal alpha non uniforme.")
    cells, cell_size = split_source(source)
    boxes = [threshold_bbox(cell) for cell in cells]
    maximum_width = max(box[2] - box[0] for box in boxes)
    maximum_height = max(box[3] - box[1] for box in boxes)
    scale = min(
        CANONICAL_SAFE[0] / maximum_width,
        CANONICAL_SAFE[1] / maximum_height,
    )

    canonical_dir = WORKING_DIR / "walk-canonical-512"
    runtime_dir = EXPORT_DIR / "walk-frames-256"
    canonical_dir.mkdir(parents=True, exist_ok=True)
    runtime_dir.mkdir(parents=True, exist_ok=True)
    atlas = Image.new(
        "RGBA", (RUNTIME_SIZE[0] * GRID[0], RUNTIME_SIZE[1] * GRID[1]), (0, 0, 0, 0)
    )
    frame_reports = []

    for index, (cell, bbox, phase) in enumerate(zip(cells, boxes, PHASES)):
        isolated = cell.crop(bbox)
        width = max(1, round(isolated.width * scale))
        height = max(1, round(isolated.height * scale))
        sprite = isolated.resize((width, height), Image.Resampling.LANCZOS)

        source_center_offset = ((bbox[0] + bbox[2]) * 0.5) - cell_size[0] * 0.5
        canonical_position = (
            round(CANONICAL_ROOT[0] + source_center_offset * scale - width * 0.5),
            CANONICAL_CONTENT_BASELINE - height,
        )
        canonical = Image.new("RGBA", CANONICAL_SIZE, (0, 0, 0, 0))
        canonical.alpha_composite(sprite, canonical_position)
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
                "duration_ms": FRAME_DURATION_MS,
                "source_bbox": list(bbox),
                "canonical_position": list(canonical_position),
                "canonical_size": [width, height],
                "canonical_root": list(CANONICAL_ROOT),
                "runtime_root": list(RUNTIME_ROOT),
            }
        )

    atlas_path = EXPORT_DIR / "vacuum-trooper-walk-4x2-256-candidate-v001.png"
    atlas.save(atlas_path)
    review_path = build_review(atlas)
    preview_path = build_preview(runtime_dir)
    report = {
        "schema": "jeuweb.enemy-animation-qa.v1",
        "status": "candidate",
        "source": str(SOURCE.relative_to(PROJECT_ROOT)),
        "source_grid": list(GRID),
        "source_cell": list(cell_size),
        "frame_count": FRAME_COUNT,
        "common_scale": round(scale, 6),
        "canonical_canvas": list(CANONICAL_SIZE),
        "canonical_root": list(CANONICAL_ROOT),
        "runtime_frame": list(RUNTIME_SIZE),
        "runtime_root": list(RUNTIME_ROOT),
        "atlas": str(atlas_path.relative_to(PROJECT_ROOT)),
        "review": str(review_path.relative_to(PROJECT_ROOT)),
        "preview": str(preview_path.relative_to(PROJECT_ROOT)),
        "frames": frame_reports,
        "statuses": {
            "visual": "candidate",
            "temporal": "candidate",
            "technical": "passed",
            "gameplay": "unmapped",
        },
        "known_limits": [
            "La cohérence temporelle exige une revue humaine en boucle.",
            "Le root est dérivé de la ligne de sol alpha, sans landmark auteur.",
            "La planche n'est pas publiée sous art/ avant approbation humaine.",
        ],
    }
    report_path = WORKING_DIR / "vacuum-trooper-walk-v001-qa.json"
    report_path.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return report


def build_review(atlas: Image.Image) -> Path:
    checker = Image.new("RGBA", atlas.size, (40, 43, 52, 255))
    draw = ImageDraw.Draw(checker)
    tile = 24
    for y in range(0, checker.height, tile):
        for x in range(0, checker.width, tile):
            if (x // tile + y // tile) % 2 == 0:
                draw.rectangle((x, y, x + tile - 1, y + tile - 1), fill=(62, 66, 78, 255))
    checker.alpha_composite(atlas)
    draw = ImageDraw.Draw(checker)
    for column in range(1, GRID[0]):
        x = column * RUNTIME_SIZE[0]
        draw.line((x, 0, x, checker.height), fill=(240, 32, 141, 180), width=1)
    draw.line((0, RUNTIME_SIZE[1], checker.width, RUNTIME_SIZE[1]), fill=(240, 32, 141, 180), width=1)
    for index in range(FRAME_COUNT):
        root_x = (index % GRID[0]) * RUNTIME_SIZE[0] + RUNTIME_ROOT[0]
        root_y = (index // GRID[0]) * RUNTIME_SIZE[1] + RUNTIME_ROOT[1]
        draw.line((root_x - 6, root_y, root_x + 6, root_y), fill=(181, 214, 31, 255), width=2)
        draw.line((root_x, root_y - 6, root_x, root_y + 6), fill=(181, 214, 31, 255), width=2)
    output = WORKING_DIR / "vacuum-trooper-walk-v001-review.png"
    checker.save(output)
    return output


def build_preview(runtime_dir: Path) -> Path:
    frames = [
        Image.open(runtime_dir / f"frame_{index:02d}.png").convert("RGBA")
        for index in range(FRAME_COUNT)
    ]
    output = WORKING_DIR / "vacuum-trooper-walk-v001-preview.webp"
    frames[0].save(
        output,
        save_all=True,
        append_images=frames[1:],
        duration=FRAME_DURATION_MS,
        loop=0,
        lossless=True,
        method=6,
    )
    return output


def main() -> None:
    WORKING_DIR.mkdir(parents=True, exist_ok=True)
    EXPORT_DIR.mkdir(parents=True, exist_ok=True)
    report = normalize()
    print(
        "Vacuum Trooper walk candidate processed: "
        f"{report['frame_count']} frames, technical={report['statuses']['technical']}"
    )


if __name__ == "__main__":
    main()
