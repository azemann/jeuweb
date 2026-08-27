#!/usr/bin/env python3
"""Normalise l'attaque toxique candidate du Vacuum Trooper sans publication."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

from PIL import Image, ImageDraw


PROJECT_ROOT = Path(__file__).resolve().parents[3]
SOURCE = PROJECT_ROOT / (
    "pipeline/assets/sources/imagegen/enemies/vacuum_trooper/attack_v001/"
    "vacuum-trooper-toxic-attack-sheet-transparent-candidate-v001.png"
)
WORKING_DIR = PROJECT_ROOT / "pipeline/assets/working/enemies/vacuum_trooper"
EXPORT_DIR = PROJECT_ROOT / "pipeline/assets/exports/enemies/vacuum_trooper"

X_EDGES = [0, 444, 887, 1331, 1774]
Y_EDGES = [0, 444, 887]
SOURCE_ROOTS = [
    (190, 395), (180, 394), (180, 395), (175, 395),
    (180, 323), (175, 325), (175, 323), (175, 323),
]
EDGE_CLEANUP_LEFT = {3: 24, 5: 34, 7: 34}
EDGE_CLEANUP_RIGHT = {2: 24}
PHASES = [
    "detect", "windup", "charge", "release",
    "active", "recoil", "recover", "ready",
]
DURATIONS_MS = [160, 180, 220, 90, 100, 110, 160, 180]
CANONICAL_SIZE = (512, 384)
CANONICAL_ROOT = (256, 360)
RUNTIME_SIZE = (256, 192)
RUNTIME_ROOT = (128, 180)
SAFE_RECT = (4, 4, 508, 380)
ALPHA_THRESHOLD = 24
PADDING = 4


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    bbox = image.getchannel("A").point(
        lambda value: 255 if value > ALPHA_THRESHOLD else 0
    ).getbbox()
    if bbox is None:
        raise RuntimeError("Frame d'attaque sans contenu alpha exploitable.")
    return (
        max(0, bbox[0] - PADDING),
        max(0, bbox[1] - PADDING),
        min(image.width, bbox[2] + PADDING),
        min(image.height, bbox[3] + PADDING),
    )


def source_cells(source: Image.Image) -> list[Image.Image]:
    cells = []
    for index in range(8):
        column = index % 4
        row = index // 4
        cell = source.crop(
            (X_EDGES[column], Y_EDGES[row], X_EDGES[column + 1], Y_EDGES[row + 1])
        )
        cleanup = EDGE_CLEANUP_LEFT.get(index, 0)
        if cleanup:
            cell.paste((0, 0, 0, 0), (0, 0, cleanup, cell.height))
        cleanup = EDGE_CLEANUP_RIGHT.get(index, 0)
        if cleanup:
            cell.paste((0, 0, 0, 0), (cell.width - cleanup, 0, cell.width, cell.height))
        cells.append(cell)
    return cells


def common_scale(boxes: list[tuple[int, int, int, int]]) -> float:
    left, top, right, bottom = SAFE_RECT
    limits = []
    for bbox, root in zip(boxes, SOURCE_ROOTS):
        distances = (
            (root[0] - bbox[0], CANONICAL_ROOT[0] - left),
            (bbox[2] - root[0], right - CANONICAL_ROOT[0]),
            (root[1] - bbox[1], CANONICAL_ROOT[1] - top),
            (bbox[3] - root[1], bottom - CANONICAL_ROOT[1]),
        )
        limits.extend(available / distance for distance, available in distances if distance > 0)
    return min(limits)


def checkerboard(size: tuple[int, int]) -> Image.Image:
    image = Image.new("RGBA", size, (38, 41, 49, 255))
    draw = ImageDraw.Draw(image)
    tile = 24
    for y in range(0, size[1], tile):
        for x in range(0, size[0], tile):
            if (x // tile + y // tile) % 2 == 0:
                draw.rectangle((x, y, x + tile - 1, y + tile - 1), fill=(62, 66, 78, 255))
    return image


def process() -> dict:
    source = Image.open(SOURCE).convert("RGBA")
    if source.size != (1774, 887) or source.getchannel("A").getextrema() != (0, 255):
        raise RuntimeError("La source d'attaque attendue doit être RGBA 1774 × 887.")
    cells = source_cells(source)
    boxes = [alpha_bbox(cell) for cell in cells]
    scale = common_scale(boxes)

    canonical_dir = WORKING_DIR / "toxic-attack-canonical-512"
    runtime_dir = EXPORT_DIR / "toxic-attack-frames-256"
    canonical_dir.mkdir(parents=True, exist_ok=True)
    runtime_dir.mkdir(parents=True, exist_ok=True)
    atlas = Image.new("RGBA", (1024, 384), (0, 0, 0, 0))
    reports = []
    runtime_frames = []

    for index, (cell, bbox, root, phase, duration) in enumerate(
        zip(cells, boxes, SOURCE_ROOTS, PHASES, DURATIONS_MS)
    ):
        isolated = cell.crop(bbox)
        size = (max(1, round(isolated.width * scale)), max(1, round(isolated.height * scale)))
        sprite = isolated.resize(size, Image.Resampling.LANCZOS)
        position = (
            round(CANONICAL_ROOT[0] - (root[0] - bbox[0]) * scale),
            round(CANONICAL_ROOT[1] - (root[1] - bbox[1]) * scale),
        )
        canonical = Image.new("RGBA", CANONICAL_SIZE, (0, 0, 0, 0))
        canonical.alpha_composite(sprite, position)
        canonical.save(canonical_dir / f"frame_{index:02d}_{phase}.png")
        runtime = canonical.resize(RUNTIME_SIZE, Image.Resampling.LANCZOS)
        runtime.save(runtime_dir / f"frame_{index:02d}.png")
        runtime_frames.append(runtime)
        atlas.alpha_composite(runtime, ((index % 4) * 256, (index // 4) * 192))
        reports.append({
            "index": index,
            "phase": phase,
            "duration_ms": duration,
            "source_bbox": list(bbox),
            "source_root": list(root),
            "canonical_position": list(position),
            "canonical_size": list(size),
            "runtime_root": list(RUNTIME_ROOT),
        })

    atlas_path = EXPORT_DIR / "vacuum-trooper-toxic-attack-4x2-256-candidate-v001.png"
    atlas.save(atlas_path)
    review = checkerboard(atlas.size)
    review.alpha_composite(atlas)
    draw = ImageDraw.Draw(review)
    for column in range(1, 4):
        draw.line((column * 256, 0, column * 256, 384), fill=(240, 32, 141, 180))
    draw.line((0, 192, 1024, 192), fill=(240, 32, 141, 180))
    for index in range(8):
        cell_x, cell_y = (index % 4) * 256, (index // 4) * 192
        draw.line((cell_x, cell_y + 180, cell_x + 256, cell_y + 180), fill=(181, 214, 31, 180))
        draw.line((cell_x + 122, cell_y + 180, cell_x + 134, cell_y + 180), fill=(181, 214, 31, 255), width=2)
    review_path = WORKING_DIR / "vacuum-trooper-toxic-attack-v001-review.png"
    review.save(review_path)
    preview_path = WORKING_DIR / "vacuum-trooper-toxic-attack-v001-preview.webp"
    runtime_frames[0].save(
        preview_path,
        save_all=True,
        append_images=runtime_frames[1:],
        duration=DURATIONS_MS,
        loop=0,
        lossless=True,
        method=6,
    )
    report = {
        "schema": "jeuweb.enemy-animation-qa.v1",
        "status": "candidate",
        "source": str(SOURCE.relative_to(PROJECT_ROOT)),
        "source_sha256": sha256(SOURCE),
        "source_dimensions": list(source.size),
        "source_grid_edges": {"x": X_EDGES, "y": Y_EDGES},
        "frame_count": 8,
        "common_scale": round(scale, 6),
        "canonical_canvas": list(CANONICAL_SIZE),
        "canonical_root": list(CANONICAL_ROOT),
        "runtime_frame": list(RUNTIME_SIZE),
        "runtime_root": list(RUNTIME_ROOT),
        "atlas": str(atlas_path.relative_to(PROJECT_ROOT)),
        "atlas_sha256": sha256(atlas_path),
        "review": str(review_path.relative_to(PROJECT_ROOT)),
        "preview": str(preview_path.relative_to(PROJECT_ROOT)),
        "frames": reports,
        "statuses": {"visual": "candidate", "temporal": "candidate", "technical": "passed", "gameplay": "unmapped"},
        "known_limits": [
            "La grille source possède des moitiés de pixel et utilise des limites explicites.",
            "Trois bandes alpha et un fragment étranger franchissant une cellule sont retirés avant normalisation.",
            "La longue trompe impose une échelle commune plus petite que la marche ; revue humaine obligatoire.",
        ],
    }
    qa_path = WORKING_DIR / "vacuum-trooper-toxic-attack-v001-qa.json"
    qa_path.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return report


if __name__ == "__main__":
    result = process()
    print(f"Vacuum Trooper toxic attack: {result['frame_count']} candidate frames processed")
