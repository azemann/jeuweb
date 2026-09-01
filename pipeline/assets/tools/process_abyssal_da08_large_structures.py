#!/usr/bin/env python3
"""Extrait les grands socles de sol visibles en bas de DA-08."""

from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass
from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter


PROJECT_ROOT = Path(__file__).resolve().parents[3]
SOURCE_DIR = PROJECT_ROOT / "pipeline/assets/sources/terrain_kits/abyssal/da08_large_structures"
SOURCE = SOURCE_DIR / "da-08-abyssal-mission-large-structures-source-v001.png"
EXPORT_DIR = PROJECT_ROOT / "pipeline/assets/exports/terrain_kits/abyssal/v003_large_structures"
ART_DIR = PROJECT_ROOT / "art/terrain/pieces/abyssal/v003_large_structures"
WORKING_DIR = PROJECT_ROOT / "pipeline/assets/working/terrain_kits/abyssal/v003_large_structures"

CANVAS_SIZE = (1024, 320)


@dataclass(frozen=True)
class StructureJob:
    piece_id: str
    output_name: str
    crop_box: tuple[int, int, int, int]
    pivot_px: tuple[int, int]
    walk_width: int


JOBS = [
    StructureJob(
        "abyssal_da08_massive_coral_machine_slab",
        "da08-massive-coral-machine-slab-v003.png",
        (16, 792, 346, 936),
        (512, 88),
        860,
    ),
    StructureJob(
        "abyssal_da08_broken_machine_floor",
        "da08-broken-machine-floor-v003.png",
        (350, 792, 620, 936),
        (512, 92),
        760,
    ),
    StructureJob(
        "abyssal_da08_rotor_slope_floor",
        "da08-rotor-slope-floor-v003.png",
        (626, 788, 902, 936),
        (512, 112),
        760,
    ),
    StructureJob(
        "abyssal_da08_tide_bridge_foundation",
        "da08-tide-bridge-foundation-v003.png",
        (904, 792, 1156, 936),
        (512, 96),
        760,
    ),
    StructureJob(
        "abyssal_da08_right_engine_slab",
        "da08-right-engine-slab-v003.png",
        (1160, 792, 1368, 936),
        (512, 96),
        700,
    ),
]


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def remove_dark_sheet_background(image: Image.Image) -> Image.Image:
    rgba = np.asarray(image.convert("RGBA")).copy()
    rgb = rgba[:, :, :3].astype(np.int16)
    brightness = rgb.max(axis=2)
    contrast = rgb.max(axis=2) - rgb.min(axis=2)
    alpha = np.where(
        brightness < 26,
        0,
        np.where(brightness < 42, (brightness - 26) * 14, 255),
    )
    alpha = np.where((brightness < 54) & (contrast < 12), 0, alpha)
    alpha = np.clip(alpha, 0, 255).astype(np.uint8)
    rgba[:, :, 3] = alpha
    cleaned = Image.fromarray(rgba, "RGBA")
    return cleaned.filter(ImageFilter.GaussianBlur(radius=0.2))


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    bbox = image.getchannel("A").point(lambda value: 255 if value > 24 else 0).getbbox()
    if bbox is None:
        raise RuntimeError("Aucune silhouette alpha exploitable")
    return bbox


def publish(job: StructureJob, source: Image.Image) -> dict:
    crop = source.crop(job.crop_box)
    cleaned = remove_dark_sheet_background(crop)
    isolated = cleaned.crop(alpha_bbox(cleaned))
    scale = min(948 / isolated.width, 246 / isolated.height)
    scaled = isolated.resize(
        (max(1, round(isolated.width * scale)), max(1, round(isolated.height * scale))),
        Image.Resampling.LANCZOS,
    )
    canvas = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    position = ((CANVAS_SIZE[0] - scaled.width) // 2, 32)
    canvas.alpha_composite(scaled, position)

    EXPORT_DIR.mkdir(parents=True, exist_ok=True)
    ART_DIR.mkdir(parents=True, exist_ok=True)
    export_path = EXPORT_DIR / job.output_name
    art_path = ART_DIR / job.output_name
    canvas.save(export_path)
    canvas.save(art_path)
    return {
        "piece_id": job.piece_id,
        "source": str(SOURCE.relative_to(PROJECT_ROOT)),
        "crop_box": list(job.crop_box),
        "export": str(export_path.relative_to(PROJECT_ROOT)),
        "runtime": str(art_path.relative_to(PROJECT_ROOT)),
        "canvas": list(CANVAS_SIZE),
        "pivot_px": list(job.pivot_px),
        "walk_width": job.walk_width,
        "alpha_bbox": list(alpha_bbox(canvas)),
        "source_sha256": sha256(SOURCE),
        "runtime_sha256": sha256(art_path),
    }


def main() -> None:
    source = Image.open(SOURCE).convert("RGB")
    outputs = [publish(job, source) for job in JOBS]
    WORKING_DIR.mkdir(parents=True, exist_ok=True)
    report = {
        "schema": "jeuweb.abyssal-da08-large-structures.v1",
        "lot": "abyssal-da08-large-structures-v003",
        "source_concept": "art/concepts/da-08-abyssal-mission.png",
        "status": "published-runtime-v003",
        "outputs": outputs,
    }
    (WORKING_DIR / "abyssal-da08-large-structures-v003-qa.json").write_text(
        json.dumps(report, indent=2) + "\n",
        encoding="utf-8",
    )
    print("Abyssal DA-08 large structures v003 processed: %d outputs" % len(outputs))


if __name__ == "__main__":
    main()
