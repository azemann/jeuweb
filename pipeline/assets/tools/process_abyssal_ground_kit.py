#!/usr/bin/env python3
"""Publie les premières Ground Pieces abyssales normalisées."""

from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass
from pathlib import Path

import numpy as np
from PIL import Image, ImageEnhance


PROJECT_ROOT = Path(__file__).resolve().parents[3]
SOURCE_DIR = PROJECT_ROOT / "pipeline/assets/sources/terrain_kits/abyssal"
WORKING_DIR = PROJECT_ROOT / "pipeline/assets/working/terrain_kits/abyssal"
EXPORT_DIR = PROJECT_ROOT / "pipeline/assets/exports/terrain_kits/abyssal"
ART_DIR = PROJECT_ROOT / "art/terrain/pieces/abyssal"

CANVAS_SIZE = (768, 384)
ALPHA_FLOOR = 14
ALPHA_BBOX_THRESHOLD = 24


@dataclass(frozen=True)
class GroundPieceJob:
    piece_id: str
    source_name: str
    output_name: str
    safe_size: tuple[int, int]
    content_top: int
    variant: str = "standard"


JOBS = [
    GroundPieceJob(
        "abyssal_black_coral_platform_medium",
        "black-coral-platform-source-v001.png",
        "black-coral-platform-medium-v001.png",
        (704, 276),
        42,
    ),
    GroundPieceJob(
        "abyssal_black_coral_slope_connector",
        "black-coral-platform-source-v001.png",
        "black-coral-slope-connector-v001.png",
        (676, 236),
        74,
        "slope",
    ),
    GroundPieceJob(
        "abyssal_tide_engine_bridge_medium",
        "tide-engine-bridge-source-v001.png",
        "tide-engine-bridge-medium-v001.png",
        (704, 262),
        52,
    ),
    GroundPieceJob(
        "abyssal_destructible_pearl_wall_medium",
        "destructible-pearl-wall-source-v001.png",
        "destructible-pearl-wall-medium-v001.png",
        (360, 318),
        34,
    ),
]


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def clean_alpha(image: Image.Image) -> Image.Image:
    rgba = np.asarray(image.convert("RGBA")).copy()
    alpha = rgba[:, :, 3].astype(np.int32)
    alpha = np.where(
        alpha <= ALPHA_FLOOR,
        0,
        np.clip((alpha - ALPHA_FLOOR) * 255 // (255 - ALPHA_FLOOR), 0, 255),
    ).astype(np.uint8)
    rgba[:, :, 3] = alpha
    return Image.fromarray(rgba, "RGBA")


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    bbox = image.getchannel("A").point(
        lambda value: 255 if value > ALPHA_BBOX_THRESHOLD else 0
    ).getbbox()
    if bbox is None:
        raise RuntimeError("La source ne contient aucune silhouette alpha exploitable")
    return bbox


def isolate_and_resize(image: Image.Image, safe_size: tuple[int, int]) -> Image.Image:
    isolated = image.crop(alpha_bbox(image))
    scale = min(safe_size[0] / isolated.width, safe_size[1] / isolated.height)
    content_size = (
        max(1, round(isolated.width * scale)),
        max(1, round(isolated.height * scale)),
    )
    return isolated.resize(content_size, Image.Resampling.LANCZOS)


def stylize(content: Image.Image, variant: str) -> Image.Image:
    if variant != "slope":
        return content
    sloped = content.rotate(-10, resample=Image.Resampling.BICUBIC, expand=True)
    sloped = ImageEnhance.Contrast(sloped).enhance(1.08)
    return ImageEnhance.Color(sloped).enhance(1.06)


def compose(job: GroundPieceJob) -> Image.Image:
    source = clean_alpha(Image.open(SOURCE_DIR / job.source_name))
    content = stylize(isolate_and_resize(source, job.safe_size), job.variant)
    if content.width > CANVAS_SIZE[0] or content.height > CANVAS_SIZE[1] - job.content_top:
        scale = min(CANVAS_SIZE[0] / content.width, (CANVAS_SIZE[1] - job.content_top) / content.height)
        content = content.resize(
            (max(1, round(content.width * scale)), max(1, round(content.height * scale))),
            Image.Resampling.LANCZOS,
        )
    canvas = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    position = ((CANVAS_SIZE[0] - content.width) // 2, job.content_top)
    canvas.alpha_composite(content, position)
    return canvas


def main() -> None:
    EXPORT_DIR.mkdir(parents=True, exist_ok=True)
    ART_DIR.mkdir(parents=True, exist_ok=True)
    WORKING_DIR.mkdir(parents=True, exist_ok=True)

    outputs = []
    for job in JOBS:
        canvas = compose(job)
        export_path = EXPORT_DIR / job.output_name
        art_path = ART_DIR / job.output_name
        canvas.save(export_path)
        canvas.save(art_path)
        outputs.append({
            "piece_id": job.piece_id,
            "source": str((SOURCE_DIR / job.source_name).relative_to(PROJECT_ROOT)),
            "export": str(export_path.relative_to(PROJECT_ROOT)),
            "runtime": str(art_path.relative_to(PROJECT_ROOT)),
            "canvas": list(CANVAS_SIZE),
            "alpha_bbox": list(alpha_bbox(canvas)),
            "source_sha256": sha256(SOURCE_DIR / job.source_name),
            "export_sha256": sha256(export_path),
            "runtime_sha256": sha256(art_path),
            "variant": job.variant,
        })

    report = {
        "schema": "jeuweb.abyssal-ground-kit.v1",
        "lot": "abyssal-ground-kit-v001",
        "source_pack": "jeuweb-abyssal-asset-pack-v001",
        "source_pack_commit": "e2b81a5",
        "status": "published-runtime-v001",
        "outputs": outputs,
    }
    (WORKING_DIR / "abyssal-ground-kit-v001-qa.json").write_text(
        json.dumps(report, indent=2) + "\n",
        encoding="utf-8",
    )
    print("Abyssal Ground Kit v001 processed: %d outputs" % len(outputs))


if __name__ == "__main__":
    main()
