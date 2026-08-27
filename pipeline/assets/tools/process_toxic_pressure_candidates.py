#!/usr/bin/env python3
"""Normalise projectile et impact toxiques candidats sans publication."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[3]
SOURCE_DIR = ROOT / "pipeline/assets/sources/imagegen/enemies/vacuum_trooper/toxic_pressure_v001"
PROJECTILE_SOURCE = SOURCE_DIR / "toxic-pressure-projectile-sheet-candidate-v001.png"
IMPACT_SOURCE = SOURCE_DIR / "toxic-pressure-impact-sheet-candidate-v001.png"
EXPORT_DIR = ROOT / "pipeline/assets/exports/enemies/vacuum_trooper"
WORKING_DIR = ROOT / "pipeline/assets/working/enemies/vacuum_trooper"

PROJECTILE_CELL = (543, 724)
PROJECTILE_CANVAS = (96, 64)
PROJECTILE_SAFE = (88, 56)
IMPACT_CELL = (512, 512)
IMPACT_CANVAS = (192, 160)
IMPACT_SAFE = (168, 136)
PROJECTILE_DURATIONS = [90, 70, 90, 70]
IMPACT_DURATIONS = [45, 55, 75, 85, 110, 140]
ALPHA_THRESHOLD = 24


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def bbox(image: Image.Image) -> tuple[int, int, int, int]:
    result = image.getchannel("A").point(
        lambda value: 255 if value > ALPHA_THRESHOLD else 0
    ).getbbox()
    if result is None:
        raise RuntimeError("Frame sans alpha exploitable.")
    return result


def cells(source: Image.Image, columns: int, rows: int, cell: tuple[int, int]) -> list[Image.Image]:
    return [
        source.crop(((index % columns) * cell[0], (index // columns) * cell[1], (index % columns + 1) * cell[0], (index // columns + 1) * cell[1]))
        for index in range(columns * rows)
    ]


def normalize_sheet(
    source: Image.Image,
    columns: int,
    rows: int,
    source_cell: tuple[int, int],
    target_cell: tuple[int, int],
    safe: tuple[int, int],
) -> tuple[Image.Image, list[Image.Image], list[dict], float]:
    source_frames = cells(source, columns, rows, source_cell)
    boxes = [bbox(frame) for frame in source_frames]
    scale = min(
        min(safe[0] / (box[2] - box[0]), safe[1] / (box[3] - box[1]))
        for box in boxes
    )
    atlas = Image.new("RGBA", (target_cell[0] * columns, target_cell[1] * rows), (0, 0, 0, 0))
    runtime_frames = []
    reports = []
    for index, (frame, source_bbox) in enumerate(zip(source_frames, boxes)):
        isolated = frame.crop(source_bbox)
        size = (max(1, round(isolated.width * scale)), max(1, round(isolated.height * scale)))
        content = isolated.resize(size, Image.Resampling.LANCZOS)
        position = ((target_cell[0] - size[0]) // 2, (target_cell[1] - size[1]) // 2)
        runtime = Image.new("RGBA", target_cell, (0, 0, 0, 0))
        runtime.alpha_composite(content, position)
        runtime_frames.append(runtime)
        atlas.alpha_composite(runtime, ((index % columns) * target_cell[0], (index // columns) * target_cell[1]))
        reports.append({"index": index, "source_bbox": list(source_bbox), "runtime_position": list(position), "runtime_size": list(size)})
    return atlas, runtime_frames, reports, scale


def checkerboard(size: tuple[int, int]) -> Image.Image:
    image = Image.new("RGBA", size, (38, 41, 49, 255))
    draw = ImageDraw.Draw(image)
    tile = 16
    for y in range(0, size[1], tile):
        for x in range(0, size[0], tile):
            if (x // tile + y // tile) % 2 == 0:
                draw.rectangle((x, y, x + tile - 1, y + tile - 1), fill=(62, 66, 78, 255))
    return image


def save_review(atlas: Image.Image, path: Path, cell: tuple[int, int], columns: int, rows: int) -> None:
    review = checkerboard(atlas.size)
    review.alpha_composite(atlas)
    draw = ImageDraw.Draw(review)
    for column in range(1, columns):
        draw.line((column * cell[0], 0, column * cell[0], atlas.height), fill=(240, 32, 141, 180))
    for row in range(1, rows):
        draw.line((0, row * cell[1], atlas.width, row * cell[1]), fill=(240, 32, 141, 180))
    path.parent.mkdir(parents=True, exist_ok=True)
    review.save(path)


def process() -> dict:
    projectile_source = Image.open(PROJECTILE_SOURCE).convert("RGBA")
    impact_source = Image.open(IMPACT_SOURCE).convert("RGBA")
    if projectile_source.size != (2172, 724) or impact_source.size != (1536, 1024):
        raise RuntimeError("Dimensions inattendues pour le lot de pression toxique.")
    EXPORT_DIR.mkdir(parents=True, exist_ok=True)
    WORKING_DIR.mkdir(parents=True, exist_ok=True)

    projectile, projectile_frames, projectile_reports, projectile_scale = normalize_sheet(
        projectile_source, 4, 1, PROJECTILE_CELL, PROJECTILE_CANVAS, PROJECTILE_SAFE
    )
    impact, impact_frames, impact_reports, impact_scale = normalize_sheet(
        impact_source, 3, 2, IMPACT_CELL, IMPACT_CANVAS, IMPACT_SAFE
    )
    projectile_path = EXPORT_DIR / "toxic-pressure-projectile-4x1-96-candidate-v001.png"
    impact_path = EXPORT_DIR / "toxic-pressure-impact-3x2-192x160-candidate-v001.png"
    projectile.save(projectile_path)
    impact.save(impact_path)
    projectile_review = WORKING_DIR / "toxic-pressure-projectile-v001-review.png"
    impact_review = WORKING_DIR / "toxic-pressure-impact-v001-review.png"
    save_review(projectile, projectile_review, PROJECTILE_CANVAS, 4, 1)
    save_review(impact, impact_review, IMPACT_CANVAS, 3, 2)
    projectile_preview = WORKING_DIR / "toxic-pressure-projectile-v001-preview.webp"
    impact_preview = WORKING_DIR / "toxic-pressure-impact-v001-preview.webp"
    projectile_frames[0].save(projectile_preview, save_all=True, append_images=projectile_frames[1:], duration=PROJECTILE_DURATIONS, loop=0, lossless=True, method=6)
    impact_frames[0].save(impact_preview, save_all=True, append_images=impact_frames[1:], duration=IMPACT_DURATIONS, loop=0, lossless=True, method=6)

    report = {
        "schema": "jeuweb.enemy-projectile-impact-qa.v1",
        "status": "candidate",
        "sources": {
            str(PROJECTILE_SOURCE.relative_to(ROOT)): sha256(PROJECTILE_SOURCE),
            str(IMPACT_SOURCE.relative_to(ROOT)): sha256(IMPACT_SOURCE),
        },
        "projectile": {
            "atlas": str(projectile_path.relative_to(ROOT)), "atlas_sha256": sha256(projectile_path),
            "layout": [4, 1], "runtime_cell": list(PROJECTILE_CANVAS), "pivot": [48, 32],
            "durations_ms": PROJECTILE_DURATIONS, "common_scale": round(projectile_scale, 6),
            "frames": projectile_reports, "review": str(projectile_review.relative_to(ROOT)), "preview": str(projectile_preview.relative_to(ROOT)),
        },
        "impact": {
            "atlas": str(impact_path.relative_to(ROOT)), "atlas_sha256": sha256(impact_path),
            "layout": [3, 2], "runtime_cell": list(IMPACT_CANVAS), "pivot": [96, 80],
            "durations_ms": IMPACT_DURATIONS, "common_scale": round(impact_scale, 6),
            "frames": impact_reports, "review": str(impact_review.relative_to(ROOT)), "preview": str(impact_preview.relative_to(ROOT)),
        },
        "statuses": {"visual": "candidate", "temporal": "candidate", "technical": "passed", "gameplay": "unmapped"},
        "known_limits": ["Vitesse, collision et dégâts restent à définir dans ProjectileData.", "L'impact doit être revu sur fond clair et sombre avant publication."],
    }
    qa_path = WORKING_DIR / "toxic-pressure-lot-v001-qa.json"
    qa_path.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return report


if __name__ == "__main__":
    process()
    print("Toxic pressure projectile/impact candidates processed")
