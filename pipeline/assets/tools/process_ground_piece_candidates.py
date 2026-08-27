#!/usr/bin/env python3
"""Normalise les Ground Pieces candidates sans les publier dans Godot."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

import numpy as np
from PIL import Image


PROJECT_ROOT = Path(__file__).resolve().parents[3]
SOURCE_DIR = PROJECT_ROOT / "pipeline/assets/sources/terrain_kits/toxic_coast/natural"
WORKING_DIR = PROJECT_ROOT / "pipeline/assets/working/terrain_kits/toxic_coast"
EXPORT_DIR = PROJECT_ROOT / "pipeline/assets/exports/terrain_kits/toxic_coast/natural"
SOURCE = SOURCE_DIR / "natural-ledge-medium-source-v002.png"
REJECTED_SOURCE = SOURCE_DIR / "natural-ledge-medium-source-v001.png"
EXPORT = EXPORT_DIR / "natural-ledge-medium-768x384-v001.png"

CANVAS_SIZE = (768, 384)
SAFE_SIZE = (704, 304)
CONTENT_TOP = 40
PIVOT = [384, 64]
ALPHA_FLOOR = 16
ALPHA_BBOX_THRESHOLD = 24


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def threshold_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    alpha = image.getchannel("A")
    bbox = alpha.point(
        lambda value: 255 if value > ALPHA_BBOX_THRESHOLD else 0
    ).getbbox()
    if bbox is None:
        raise RuntimeError("La source ne contient aucune silhouette alpha exploitable")
    return bbox


def main() -> None:
    source = Image.open(SOURCE).convert("RGBA")
    rgba = np.asarray(source).copy()
    alpha = rgba[:, :, 3].astype(np.int32)
    alpha = np.where(
        alpha <= ALPHA_FLOOR,
        0,
        np.clip((alpha - ALPHA_FLOOR) * 255 // (255 - ALPHA_FLOOR), 0, 255),
    ).astype(np.uint8)
    rgba[:, :, 3] = alpha
    cleaned = Image.fromarray(rgba, "RGBA")
    source_bbox = threshold_bbox(cleaned)
    isolated = cleaned.crop(source_bbox)
    scale = min(SAFE_SIZE[0] / isolated.width, SAFE_SIZE[1] / isolated.height)
    content_size = (
        max(1, round(isolated.width * scale)),
        max(1, round(isolated.height * scale)),
    )
    content = isolated.resize(content_size, Image.Resampling.LANCZOS)
    content_position = ((CANVAS_SIZE[0] - content_size[0]) // 2, CONTENT_TOP)
    canvas = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    canvas.alpha_composite(content, content_position)

    EXPORT_DIR.mkdir(parents=True, exist_ok=True)
    WORKING_DIR.mkdir(parents=True, exist_ok=True)
    canvas.save(EXPORT)
    report = {
        "schema": "jeuweb.ground-piece-asset-qa.v1",
        "piece_id": "natural_ledge_medium",
        "status": "candidate",
        "source": str(SOURCE.relative_to(PROJECT_ROOT)),
        "rejected_source": str(REJECTED_SOURCE.relative_to(PROJECT_ROOT)),
        "output": str(EXPORT.relative_to(PROJECT_ROOT)),
        "source_bbox": list(source_bbox),
        "canvas": list(CANVAS_SIZE),
        "content_position": list(content_position),
        "content_size": list(content_size),
        "pivot_px": PIVOT,
        "alpha_floor_removed": ALPHA_FLOOR,
        "alpha_bbox": list(threshold_bbox(canvas)),
        "source_sha256": sha256(SOURCE),
        "rejected_source_sha256": sha256(REJECTED_SOURCE),
        "export_sha256": sha256(EXPORT),
        "validation": {
            "technical": "pending",
            "visual": "pending",
            "human_approval": "pending",
            "consumer_import": "not-run"
        }
    }
    qa_path = WORKING_DIR / "natural-ledge-medium-v001-qa.json"
    qa_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"Ground Piece candidate processed; QA: {qa_path.relative_to(PROJECT_ROOT)}")


if __name__ == "__main__":
    main()
