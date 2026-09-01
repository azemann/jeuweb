#!/usr/bin/env python3
"""Publie les grands sols abyssaux générés pour Mission 2."""

from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass
from pathlib import Path

import numpy as np
from PIL import Image


PROJECT_ROOT = Path(__file__).resolve().parents[3]
SOURCE = (
    PROJECT_ROOT
    / "pipeline/assets/sources/terrain_kits/abyssal/generated_large_structures/abyssal-large-ground-structures-source-v004.png"
)
EXPORT_DIR = PROJECT_ROOT / "pipeline/assets/exports/terrain_kits/abyssal/v004_large_structures"
ART_DIR = PROJECT_ROOT / "art/terrain/pieces/abyssal/v004_large_structures"
WORKING_DIR = PROJECT_ROOT / "pipeline/assets/working/terrain_kits/abyssal/v004_large_structures"

CANVAS_SIZE = (1024, 320)
ALPHA_THRESHOLD = 24


@dataclass(frozen=True)
class LargeStructureJob:
    piece_id: str
    output_name: str
    crop_box: tuple[int, int, int, int]
    pivot_px: tuple[int, int]
    walk_half_width: int
    display_name: str


JOBS = [
    LargeStructureJob(
        "abyssal_generated_coral_machine_slab",
        "generated-coral-machine-slab-v004.png",
        (0, 0, 900, 724),
        (512, 82),
        430,
        "Abysses généré — grand socle corail machine",
    ),
    LargeStructureJob(
        "abyssal_generated_tide_engine_floor",
        "generated-tide-engine-floor-v004.png",
        (320, 0, 1220, 724),
        (512, 82),
        430,
        "Abysses généré — plancher moteur de marée",
    ),
    LargeStructureJob(
        "abyssal_generated_black_coral_slab",
        "generated-black-coral-slab-v004.png",
        (650, 0, 1550, 724),
        (512, 82),
        420,
        "Abysses généré — socle corail noir",
    ),
    LargeStructureJob(
        "abyssal_generated_ruin_engine_slab",
        "generated-ruin-engine-slab-v004.png",
        (970, 0, 1870, 724),
        (512, 82),
        420,
        "Abysses généré — socle ruine moteur",
    ),
    LargeStructureJob(
        "abyssal_generated_right_coral_engine_slab",
        "generated-right-coral-engine-slab-v004.png",
        (1270, 0, 2172, 724),
        (512, 82),
        410,
        "Abysses généré — socle moteur corail droit",
    ),
]


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    bbox = image.getchannel("A").point(
        lambda value: 255 if value > ALPHA_THRESHOLD else 0
    ).getbbox()
    if bbox is None:
        raise RuntimeError("La source ne contient aucune silhouette alpha exploitable")
    return bbox


def remove_generation_fringe(image: Image.Image) -> Image.Image:
    rgba = np.asarray(image.convert("RGBA")).copy()
    red_fringe = (rgba[:, :, 0] > 180) & (rgba[:, :, 1] < 95) & (rgba[:, :, 2] < 120)
    electric_blue_fringe = (
        (rgba[:, :, 2] > 220)
        & (rgba[:, :, 1] < 110)
        & (rgba[:, :, 0] < 90)
    )
    fringe = red_fringe | electric_blue_fringe
    rgba[:, :, 3] = np.where(fringe, 0, rgba[:, :, 3]).astype(np.uint8)
    return Image.fromarray(rgba, "RGBA")


def publish(job: LargeStructureJob, source: Image.Image) -> dict:
    crop = source.crop(job.crop_box)
    crop = remove_generation_fringe(crop)
    isolated = crop.crop(alpha_bbox(crop))
    scale = min(980 / isolated.width, 304 / isolated.height)
    scaled = isolated.resize(
        (
            max(1, round(isolated.width * scale)),
            max(1, round(isolated.height * scale)),
        ),
        Image.Resampling.LANCZOS,
    )
    canvas = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    x = (CANVAS_SIZE[0] - scaled.width) // 2
    y = 14
    canvas.alpha_composite(scaled, (x, y))

    EXPORT_DIR.mkdir(parents=True, exist_ok=True)
    ART_DIR.mkdir(parents=True, exist_ok=True)
    export_path = EXPORT_DIR / job.output_name
    runtime_path = ART_DIR / job.output_name
    canvas.save(export_path)
    canvas.save(runtime_path)
    bbox = alpha_bbox(canvas)
    return {
        "piece_id": job.piece_id,
        "display_name": job.display_name,
        "source": str(SOURCE.relative_to(PROJECT_ROOT)),
        "crop_box": list(job.crop_box),
        "export": str(export_path.relative_to(PROJECT_ROOT)),
        "runtime": str(runtime_path.relative_to(PROJECT_ROOT)),
        "canvas": list(CANVAS_SIZE),
        "pivot_px": list(job.pivot_px),
        "walk_half_width": job.walk_half_width,
        "walk_surface_y": 0,
        "alpha_bbox": list(bbox),
        "source_sha256": sha256(SOURCE),
        "runtime_sha256": sha256(runtime_path),
    }


def main() -> None:
    source = Image.open(SOURCE).convert("RGBA")
    outputs = [publish(job, source) for job in JOBS]
    WORKING_DIR.mkdir(parents=True, exist_ok=True)
    report = {
        "schema": "jeuweb.abyssal-generated-large-structures.v1",
        "lot": "abyssal-generated-large-structures-v004",
        "source_type": "imagegen-generated-sheet",
        "status": "published-runtime-v004",
        "replaces_rejected_lot": "abyssal-da08-large-structures-v003",
        "constraints": [
            "single clear walkable top edge per module",
            "transparent background",
            "no direct DA-08 crop in runtime",
        ],
        "outputs": outputs,
    }
    (WORKING_DIR / "abyssal-generated-large-structures-v004-qa.json").write_text(
        json.dumps(report, indent=2) + "\n",
        encoding="utf-8",
    )
    print("Abyssal generated large structures v004 processed: %d outputs" % len(outputs))


if __name__ == "__main__":
    main()
