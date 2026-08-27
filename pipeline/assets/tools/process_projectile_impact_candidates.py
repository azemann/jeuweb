#!/usr/bin/env python3
"""Produit les candidats projectile/impact sans publier dans Godot."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

import numpy as np
from PIL import Image


PROJECT_ROOT = Path(__file__).resolve().parents[3]
SOURCE_DIR = PROJECT_ROOT / "pipeline/assets/sources/imagegen/weapons"
EXPORT_DIR = PROJECT_ROOT / "pipeline/assets/exports/weapons"
WORKING_DIR = PROJECT_ROOT / "pipeline/assets/working/weapons"

PROJECTILE_SOURCE = SOURCE_DIR / "field-round-source-v001.png"
IMPACT_SOURCE = SOURCE_DIR / "field-round-impact-sheet-source-v001.png"
PROJECTILE_OUTPUT = EXPORT_DIR / "field-round-384x192-v001.png"
IMPACT_OUTPUT = EXPORT_DIR / "field-round-impact-3x2-256-v001.png"

ALPHA_CONTENT_THRESHOLD = 24
IMPACT_ALPHA_FLOOR = 16
PROJECTILE_CANVAS = (384, 192)
PROJECTILE_SAFE = (352, 160)
IMPACT_SOURCE_CELL = (512, 512)
IMPACT_RUNTIME_CELL = (256, 256)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def alpha_bbox(image: Image.Image, threshold: int) -> tuple[int, int, int, int]:
    alpha = image.getchannel("A")
    bbox = alpha.point(lambda value: 255 if value > threshold else 0).getbbox()
    if bbox is None:
        raise RuntimeError("Image sans contenu alpha exploitable")
    return bbox


def normalize_projectile() -> dict:
    source = Image.open(PROJECTILE_SOURCE).convert("RGBA")
    source_bbox = alpha_bbox(source, ALPHA_CONTENT_THRESHOLD)
    isolated = source.crop(source_bbox)
    scale = min(
        PROJECTILE_SAFE[0] / isolated.width,
        PROJECTILE_SAFE[1] / isolated.height,
    )
    content_size = (
        max(1, round(isolated.width * scale)),
        max(1, round(isolated.height * scale)),
    )
    content = isolated.resize(content_size, Image.Resampling.LANCZOS)
    position = (
        (PROJECTILE_CANVAS[0] - content_size[0]) // 2,
        (PROJECTILE_CANVAS[1] - content_size[1]) // 2,
    )
    canvas = Image.new("RGBA", PROJECTILE_CANVAS, (0, 0, 0, 0))
    canvas.alpha_composite(content, position)
    canvas.save(PROJECTILE_OUTPUT)
    return {
        "source": str(PROJECTILE_SOURCE.relative_to(PROJECT_ROOT)),
        "output": str(PROJECTILE_OUTPUT.relative_to(PROJECT_ROOT)),
        "source_bbox": list(source_bbox),
        "canvas": list(PROJECTILE_CANVAS),
        "content_position": list(position),
        "content_size": list(content_size),
        "pivot_px": [192, 96],
        "direction": "right",
    }


def clean_impact_cell(cell: Image.Image) -> tuple[Image.Image, dict]:
    rgba = np.asarray(cell.convert("RGBA")).copy()
    # int32 évite le débordement de (239 * 255) observé avec int16.
    alpha = rgba[:, :, 3].astype(np.int32)
    alpha = np.where(
        alpha <= IMPACT_ALPHA_FLOOR,
        0,
        np.clip(
            (alpha - IMPACT_ALPHA_FLOOR) * 255 // (255 - IMPACT_ALPHA_FLOOR),
            0,
            255,
        ),
    ).astype(np.uint8)
    rgba[:, :, 3] = alpha
    cleaned = Image.fromarray(rgba, "RGBA")
    source_bbox = alpha_bbox(cleaned, ALPHA_CONTENT_THRESHOLD)
    runtime = cleaned.resize(IMPACT_RUNTIME_CELL, Image.Resampling.LANCZOS)
    runtime_bbox = alpha_bbox(runtime, ALPHA_CONTENT_THRESHOLD)
    return runtime, {
        "source_bbox_after_cleanup": list(source_bbox),
        "runtime_bbox": list(runtime_bbox),
        "edge_alpha_max": max(
            max(runtime.getchannel("A").crop((0, 0, 256, 1)).getextrema()),
            max(runtime.getchannel("A").crop((0, 255, 256, 256)).getextrema()),
            max(runtime.getchannel("A").crop((0, 0, 1, 256)).getextrema()),
            max(runtime.getchannel("A").crop((255, 0, 256, 256)).getextrema()),
        ),
    }


def normalize_impact() -> dict:
    source = Image.open(IMPACT_SOURCE).convert("RGBA")
    if source.size != (1536, 1024):
        raise RuntimeError(f"Planche impact inattendue: {source.size}")
    sheet = Image.new("RGBA", (768, 512), (0, 0, 0, 0))
    frames = []
    for index in range(6):
        column = index % 3
        row = index // 3
        left = column * IMPACT_SOURCE_CELL[0]
        top = row * IMPACT_SOURCE_CELL[1]
        cell = source.crop(
            (left, top, left + IMPACT_SOURCE_CELL[0], top + IMPACT_SOURCE_CELL[1])
        )
        runtime, report = clean_impact_cell(cell)
        sheet.alpha_composite(
            runtime,
            (column * IMPACT_RUNTIME_CELL[0], row * IMPACT_RUNTIME_CELL[1]),
        )
        report.update({"index": index, "column": column, "row": row})
        frames.append(report)
    sheet.save(IMPACT_OUTPUT)
    return {
        "source": str(IMPACT_SOURCE.relative_to(PROJECT_ROOT)),
        "output": str(IMPACT_OUTPUT.relative_to(PROJECT_ROOT)),
        "layout": [3, 2],
        "runtime_cell": list(IMPACT_RUNTIME_CELL),
        "pivot_px": [128, 128],
        "alpha_floor_removed": IMPACT_ALPHA_FLOOR,
        "frames": frames,
    }


def main() -> None:
    EXPORT_DIR.mkdir(parents=True, exist_ok=True)
    WORKING_DIR.mkdir(parents=True, exist_ok=True)
    report = {
        "schema": "jeuweb.projectile-impact-asset-qa.v1",
        "status": "candidate",
        "projectile": normalize_projectile(),
        "impact": normalize_impact(),
        "source_sha256": {
            str(PROJECTILE_SOURCE.relative_to(PROJECT_ROOT)): sha256(PROJECTILE_SOURCE),
            str(IMPACT_SOURCE.relative_to(PROJECT_ROOT)): sha256(IMPACT_SOURCE),
        },
        "known_limits": [
            "La continuité des six poses d'impact doit encore être approuvée visuellement.",
            "Le pivot et l'échelle runtime restent à valider dans la scène Projectile2D.",
        ],
    }
    report["export_sha256"] = {
        str(PROJECTILE_OUTPUT.relative_to(PROJECT_ROOT)): sha256(PROJECTILE_OUTPUT),
        str(IMPACT_OUTPUT.relative_to(PROJECT_ROOT)): sha256(IMPACT_OUTPUT),
    }
    qa_path = WORKING_DIR / "field-round-lot-v001-qa.json"
    qa_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"Candidats produits; QA: {qa_path.relative_to(PROJECT_ROOT)}")


if __name__ == "__main__":
    main()
