#!/usr/bin/env python3
"""Publie les Ground Pieces abyssales normalisées."""

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
EXPORT_V2_DIR = EXPORT_DIR / "v002"
ART_V2_DIR = ART_DIR / "v002"

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
    crop: tuple[float, float, float, float] | None = None


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

JOBS_V2 = [
    GroundPieceJob(
        "abyssal_black_coral_platform_small",
        "black-coral-platform-source-v001.png",
        "black-coral-platform-small-v002.png",
        (430, 210),
        76,
    ),
    GroundPieceJob(
        "abyssal_black_coral_platform_large",
        "black-coral-platform-source-v001.png",
        "black-coral-platform-large-v002.png",
        (736, 300),
        30,
    ),
    GroundPieceJob(
        "abyssal_black_coral_floor_cap_left",
        "black-coral-platform-source-v001.png",
        "black-coral-floor-cap-left-v002.png",
        (360, 252),
        62,
        "cap_left",
        (0.0, 0.0, 0.58, 1.0),
    ),
    GroundPieceJob(
        "abyssal_black_coral_floor_cap_right",
        "black-coral-platform-source-v001.png",
        "black-coral-floor-cap-right-v002.png",
        (360, 252),
        62,
        "cap_right",
        (0.42, 0.0, 1.0, 1.0),
    ),
    GroundPieceJob(
        "abyssal_black_coral_slope_up",
        "black-coral-platform-source-v001.png",
        "black-coral-slope-up-v002.png",
        (650, 224),
        84,
        "slope_up",
    ),
    GroundPieceJob(
        "abyssal_black_coral_slope_down",
        "black-coral-platform-source-v001.png",
        "black-coral-slope-down-v002.png",
        (650, 224),
        84,
        "slope_down",
    ),
    GroundPieceJob(
        "abyssal_black_coral_step_low",
        "black-coral-platform-source-v001.png",
        "black-coral-step-low-v002.png",
        (430, 210),
        106,
        "step_low",
    ),
    GroundPieceJob(
        "abyssal_black_coral_step_high",
        "black-coral-platform-source-v001.png",
        "black-coral-step-high-v002.png",
        (500, 248),
        82,
        "step_high",
    ),
    GroundPieceJob(
        "abyssal_tide_engine_bridge_short",
        "tide-engine-bridge-source-v001.png",
        "tide-engine-bridge-short-v002.png",
        (430, 216),
        76,
    ),
    GroundPieceJob(
        "abyssal_tide_engine_bridge_long",
        "tide-engine-bridge-source-v001.png",
        "tide-engine-bridge-long-v002.png",
        (736, 272),
        48,
    ),
    GroundPieceJob(
        "abyssal_tide_engine_support_pillar",
        "tide-engine-bridge-source-v001.png",
        "tide-engine-support-pillar-v002.png",
        (220, 320),
        34,
        "pillar",
        (0.34, 0.0, 0.66, 1.0),
    ),
    GroundPieceJob(
        "abyssal_temple_arch_large",
        "abyssal-temple-arch-source-v001.png",
        "abyssal-temple-arch-large-v002.png",
        (620, 330),
        26,
    ),
    GroundPieceJob(
        "abyssal_temple_column_intact",
        "abyssal-temple-arch-source-v001.png",
        "abyssal-temple-column-intact-v002.png",
        (210, 330),
        26,
        "column",
        (0.08, 0.0, 0.38, 1.0),
    ),
    GroundPieceJob(
        "abyssal_temple_column_broken",
        "abyssal-temple-arch-source-v001.png",
        "abyssal-temple-column-broken-v002.png",
        (210, 290),
        64,
        "column_broken",
        (0.60, 0.0, 0.9, 1.0),
    ),
    GroundPieceJob(
        "abyssal_destructible_pearl_wall_small",
        "destructible-pearl-wall-source-v001.png",
        "destructible-pearl-wall-small-v002.png",
        (260, 250),
        78,
    ),
    GroundPieceJob(
        "abyssal_destructible_pearl_wall_large",
        "destructible-pearl-wall-source-v001.png",
        "destructible-pearl-wall-large-v002.png",
        (440, 336),
        22,
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


def isolate_and_resize(
    image: Image.Image,
    safe_size: tuple[int, int],
    crop: tuple[float, float, float, float] | None = None,
) -> Image.Image:
    bbox = alpha_bbox(image)
    if crop is not None:
        width = bbox[2] - bbox[0]
        height = bbox[3] - bbox[1]
        bbox = (
            bbox[0] + round(width * crop[0]),
            bbox[1] + round(height * crop[1]),
            bbox[0] + round(width * crop[2]),
            bbox[1] + round(height * crop[3]),
        )
    isolated = image.crop(bbox)
    scale = min(safe_size[0] / isolated.width, safe_size[1] / isolated.height)
    content_size = (
        max(1, round(isolated.width * scale)),
        max(1, round(isolated.height * scale)),
    )
    return isolated.resize(content_size, Image.Resampling.LANCZOS)


def stylize(content: Image.Image, variant: str) -> Image.Image:
    if variant in ["slope", "slope_up"]:
        sloped = content.rotate(-10, resample=Image.Resampling.BICUBIC, expand=True)
        sloped = ImageEnhance.Contrast(sloped).enhance(1.08)
        return ImageEnhance.Color(sloped).enhance(1.06)
    if variant == "slope_down":
        sloped = content.rotate(10, resample=Image.Resampling.BICUBIC, expand=True)
        sloped = ImageEnhance.Contrast(sloped).enhance(1.08)
        return ImageEnhance.Color(sloped).enhance(1.06)
    if variant == "cap_right":
        return content.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
    if variant in ["step_low", "step_high"]:
        step = Image.new("RGBA", (content.width + 120, content.height + 70), (0, 0, 0, 0))
        lower = content.resize((content.width, content.height), Image.Resampling.LANCZOS)
        upper = content.resize((max(1, round(content.width * 0.72)), max(1, round(content.height * 0.68))), Image.Resampling.LANCZOS)
        step.alpha_composite(lower, (0, 70))
        step.alpha_composite(upper, (88 if variant == "step_low" else 132, 0))
        return step
    if variant == "column_broken":
        return content.crop((0, round(content.height * 0.14), content.width, content.height))
    if variant in ["pillar", "column", "cap_left", "standard"]:
        return content
    return content


def compose(job: GroundPieceJob) -> Image.Image:
    source = clean_alpha(Image.open(SOURCE_DIR / job.source_name))
    content = stylize(isolate_and_resize(source, job.safe_size, job.crop), job.variant)
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
    EXPORT_V2_DIR.mkdir(parents=True, exist_ok=True)
    ART_V2_DIR.mkdir(parents=True, exist_ok=True)
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
    outputs_v2 = []
    for job in JOBS_V2:
        canvas = compose(job)
        export_path = EXPORT_V2_DIR / job.output_name
        art_path = ART_V2_DIR / job.output_name
        canvas.save(export_path)
        canvas.save(art_path)
        outputs_v2.append({
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

    report_v2 = {
        "schema": "jeuweb.abyssal-ground-kit.v2",
        "lot": "abyssal-ground-kit-v002",
        "source_pack": "jeuweb-abyssal-asset-pack-v001",
        "source_pack_commit": "e2b81a5",
        "status": "published-runtime-v002",
        "outputs": outputs_v2,
    }
    working_v2_dir = WORKING_DIR / "v002"
    working_v2_dir.mkdir(parents=True, exist_ok=True)
    (working_v2_dir / "abyssal-ground-kit-v002-qa.json").write_text(
        json.dumps(report_v2, indent=2) + "\n",
        encoding="utf-8",
    )
    print("Abyssal Ground Kit v001 processed: %d outputs" % len(outputs))
    print("Abyssal Ground Kit v002 processed: %d outputs" % len(outputs_v2))


if __name__ == "__main__":
    main()
