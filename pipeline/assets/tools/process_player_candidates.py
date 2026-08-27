#!/usr/bin/env python3
"""Normalise les candidats joueur ImageGen sans les publier dans Godot.

Recette adaptée des pipelines fighter-sprites-2d, horde-brawler et
serre-mecanique de my-space. Les sorties restent candidates jusqu'à revue.
"""

from __future__ import annotations

import json
from pathlib import Path

import cv2
import numpy as np
from PIL import Image, ImageDraw


PROJECT_ROOT = Path(__file__).resolve().parents[3]
SOURCE_DIR = PROJECT_ROOT / "pipeline/assets/sources/imagegen/player"
WORKING_DIR = PROJECT_ROOT / "pipeline/assets/working/player"
EXPORT_DIR = PROJECT_ROOT / "pipeline/assets/exports/player"

BODY_SOURCE = SOURCE_DIR / "player-body-action-sheet-v001.png"
WEAPON_SOURCE = SOURCE_DIR / "player-primary-cannon-v001.png"

FRAME_NAMES = [
    "idle",
    "walk_contact",
    "walk_passing",
    "run_extension",
    "jump_rise",
    "jump_apex",
    "fall",
    "landing",
    "crouch",
    "aim_up",
    "recoil",
    "hurt",
]

CANONICAL_SIZE = (384, 384)
CANONICAL_ROOT = (192, 360)
CANONICAL_CONTENT_BASELINE = 356
CANONICAL_SAFE = (340, 340)
RUNTIME_SIZE = (192, 192)
RUNTIME_ROOT = (96, 180)
ALPHA_THRESHOLD = 24
MIN_COMPONENT_AREA = 10_000


def detect_components(image: Image.Image) -> list[dict]:
    alpha = np.asarray(image.getchannel("A"))
    mask = (alpha > ALPHA_THRESHOLD).astype(np.uint8)
    count, labels, stats, centroids = cv2.connectedComponentsWithStats(mask, 8)
    components = []
    for label in range(1, count):
        x, y, width, height, area = (int(value) for value in stats[label])
        if area < MIN_COMPONENT_AREA:
            continue
        components.append(
            {
                "label": label,
                "bbox": [x, y, width, height],
                "area": area,
                "centroid": [float(centroids[label][0]), float(centroids[label][1])],
                "mask": labels == label,
            }
        )
    if len(components) != len(FRAME_NAMES):
        raise RuntimeError(
            f"Expected {len(FRAME_NAMES)} player components, found {len(components)}"
        )
    components.sort(key=lambda item: item["centroid"][1])
    ordered = []
    for row_start in range(0, len(FRAME_NAMES), 4):
        row = components[row_start : row_start + 4]
        row.sort(key=lambda item: item["centroid"][0])
        ordered.extend(row)
    return ordered


def isolate_component(image: Image.Image, component: dict) -> Image.Image:
    x, y, width, height = component["bbox"]
    pixels = np.asarray(image).copy()
    alpha = pixels[:, :, 3]
    alpha[~component["mask"]] = 0
    pixels[:, :, 3] = alpha
    return Image.fromarray(pixels, "RGBA").crop((x, y, x + width, y + height))


def normalize_body_frames() -> dict:
    source = Image.open(BODY_SOURCE).convert("RGBA")
    components = detect_components(source)
    maximum_width = max(item["bbox"][2] for item in components)
    maximum_height = max(item["bbox"][3] for item in components)
    scale = min(
        CANONICAL_SAFE[0] / maximum_width,
        CANONICAL_SAFE[1] / maximum_height,
    )

    canonical_dir = WORKING_DIR / "body-canonical-384"
    runtime_dir = EXPORT_DIR / "body-frames-192"
    canonical_dir.mkdir(parents=True, exist_ok=True)
    runtime_dir.mkdir(parents=True, exist_ok=True)
    atlas = Image.new(
        "RGBA", (RUNTIME_SIZE[0] * 4, RUNTIME_SIZE[1] * 3), (0, 0, 0, 0)
    )
    frame_reports = []

    for index, (name, component) in enumerate(zip(FRAME_NAMES, components)):
        isolated = isolate_component(source, component)
        width = max(1, round(isolated.width * scale))
        height = max(1, round(isolated.height * scale))
        sprite = isolated.resize((width, height), Image.Resampling.LANCZOS)
        canonical = Image.new("RGBA", CANONICAL_SIZE, (0, 0, 0, 0))
        canonical_position = (
            CANONICAL_ROOT[0] - width // 2,
            CANONICAL_CONTENT_BASELINE - height,
        )
        canonical.alpha_composite(sprite, canonical_position)
        canonical.save(canonical_dir / f"{index:02d}-{name}.png")

        runtime = canonical.resize(RUNTIME_SIZE, Image.Resampling.LANCZOS)
        runtime.save(runtime_dir / f"{index:02d}-{name}.png")
        atlas.alpha_composite(
            runtime,
            ((index % 4) * RUNTIME_SIZE[0], (index // 4) * RUNTIME_SIZE[1]),
        )
        frame_reports.append(
            {
                "index": index,
                "name": name,
                "source_bbox": component["bbox"],
                "canonical_position": list(canonical_position),
                "canonical_size": [width, height],
                "root_px": list(CANONICAL_ROOT),
                "data_status": "estimated",
            }
        )

    atlas_path = EXPORT_DIR / "player-body-atlas-4x3-192-v001.png"
    atlas.save(atlas_path)
    return {
        "source": str(BODY_SOURCE.relative_to(PROJECT_ROOT)),
        "component_count": len(components),
        "common_scale": round(scale, 6),
        "canonical_canvas": list(CANONICAL_SIZE),
        "canonical_root": list(CANONICAL_ROOT),
        "canonical_content_baseline": CANONICAL_CONTENT_BASELINE,
        "runtime_frame": list(RUNTIME_SIZE),
        "runtime_root": list(RUNTIME_ROOT),
        "atlas": str(atlas_path.relative_to(PROJECT_ROOT)),
        "frames": frame_reports,
    }


def normalize_weapon() -> dict:
    source = Image.open(WEAPON_SOURCE).convert("RGBA")
    bbox = source.getchannel("A").point(lambda value: 255 if value > ALPHA_THRESHOLD else 0).getbbox()
    if bbox is None:
        raise RuntimeError("Weapon source has no usable alpha content")
    isolated = source.crop(bbox)
    canvas_size = (768, 384)
    safe_size = (704, 320)
    scale = min(safe_size[0] / isolated.width, safe_size[1] / isolated.height)
    size = (round(isolated.width * scale), round(isolated.height * scale))
    sprite = isolated.resize(size, Image.Resampling.LANCZOS)
    position = (24, 192 - size[1] // 2)
    canvas = Image.new("RGBA", canvas_size, (0, 0, 0, 0))
    canvas.alpha_composite(sprite, position)
    output = EXPORT_DIR / "player-primary-cannon-768-v001.png"
    canvas.save(output)
    return {
        "source": str(WEAPON_SOURCE.relative_to(PROJECT_ROOT)),
        "source_bbox": list(bbox),
        "canvas": list(canvas_size),
        "content_position": list(position),
        "content_size": list(size),
        "pivot_px": [112, 192],
        "muzzle_px": [728, 192],
        "data_status": "estimated",
        "output": str(output.relative_to(PROJECT_ROOT)),
    }


def build_review_sheet(body_atlas_path: Path, weapon_path: Path) -> None:
    body = Image.open(body_atlas_path).convert("RGBA")
    weapon = Image.open(weapon_path).convert("RGBA")
    review = Image.new("RGBA", (900, 920), (29, 32, 40, 255))
    body_preview = body.resize((768, 576), Image.Resampling.LANCZOS)
    review.alpha_composite(body_preview, (66, 46))
    weapon_preview = weapon.resize((768, 384), Image.Resampling.LANCZOS)
    review.alpha_composite(weapon_preview, (66, 580))
    draw = ImageDraw.Draw(review)
    draw.rectangle((65, 45, 835, 623), outline=(240, 32, 141, 255), width=2)
    draw.rectangle((65, 579, 835, 919), outline=(181, 214, 31, 255), width=2)
    review.save(WORKING_DIR / "player-lot-v001-review-dark.png")


def main() -> None:
    WORKING_DIR.mkdir(parents=True, exist_ok=True)
    EXPORT_DIR.mkdir(parents=True, exist_ok=True)
    body_report = normalize_body_frames()
    weapon_report = normalize_weapon()
    report = {
        "schema": "jeuweb.player-asset-qa.v1",
        "status": "candidate",
        "body": body_report,
        "weapon": weapon_report,
        "known_limits": [
            "ImageGen sheet poses are key-pose candidates, not a temporally validated animation.",
            "Root is estimated from the visible bottom because the source sheet has no authored landmarks.",
            "Weapon pivot and muzzle sockets require human review in the player scene.",
        ],
    }
    report_path = WORKING_DIR / "player-lot-v001-qa.json"
    report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    build_review_sheet(
        PROJECT_ROOT / body_report["atlas"], PROJECT_ROOT / weapon_report["output"]
    )
    print(f"Player candidate lot processed; QA: {report_path.relative_to(PROJECT_ROOT)}")


if __name__ == "__main__":
    main()
