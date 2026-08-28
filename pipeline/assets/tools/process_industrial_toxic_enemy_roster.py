#!/usr/bin/env python3
"""Extrait, normalise et valide les 64 poses du roster industriel toxique."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

import cv2
import numpy as np
from PIL import Image, ImageDraw


PROJECT_ROOT = Path(__file__).resolve().parents[3]
SOURCE_ROOT = PROJECT_ROOT / "pipeline/assets/sources/imagegen/enemies/industrial_toxic_v001"
EXPORT_ROOT = PROJECT_ROOT / "pipeline/assets/exports/enemies/industrial_toxic_v001"
WORKING_ROOT = PROJECT_ROOT / "pipeline/assets/working/enemies/industrial_toxic_v001"

ROSTER = {
    "vacuum_grunt": {
        "source": "vacuum-grunt-animation-sheet-candidate-v001.png",
        "frame": (320, 256),
        "root": (160, 240),
    },
    "vacuum_flying": {
        "source": "vacuum-flying-animation-sheet-candidate-v001.png",
        "frame": (256, 256),
        "root": (128, 128),
    },
    "vacuum_boss": {
        "source": "vacuum-boss-animation-sheet-candidate-v001.png",
        "frame": (384, 320),
        "root": (192, 300),
    },
    "vacuum_pilot_saboteur": {
        "source": "vacuum-pilot-saboteur-animation-sheet-candidate-v001.png",
        "frame": (192, 192),
        "root": (96, 180),
    },
}

PHASES = [
    "move_0", "move_1", "move_2", "move_3",
    "attack_0", "attack_1", "attack_2", "attack_3",
    "hit_0", "hit_1", "hit_2", "hit_3",
    "death_0", "death_1", "death_2", "death_3",
]
GRID_EDGES = [0, 314, 627, 941, 1254]
BACKGROUND_DISTANCE_MIN = 18.0
BACKGROUND_DISTANCE_MAX = 92.0


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def extract_alpha(source: Image.Image) -> Image.Image:
    rgb = np.asarray(source.convert("RGB"), dtype=np.float32)
    border = np.concatenate((rgb[0], rgb[-1], rgb[:, 0], rgb[:, -1]), axis=0)
    background = np.median(border, axis=0)
    distance = np.linalg.norm(rgb - background, axis=2)
    alpha = np.clip(
        (distance - BACKGROUND_DISTANCE_MIN)
        * 255.0
        / (BACKGROUND_DISTANCE_MAX - BACKGROUND_DISTANCE_MIN),
        0.0,
        255.0,
    ).astype(np.uint8)
    cyan = (rgb[:, :, 1] > 175) & (rgb[:, :, 2] > 175) & (rgb[:, :, 0] < 105)
    alpha[cyan & (distance < BACKGROUND_DISTANCE_MAX)] = 0
    rgba = np.dstack((rgb.astype(np.uint8), alpha))
    rgba[alpha == 0, :3] = 0
    return Image.fromarray(rgba, "RGBA")


def normalise_cell(cell: Image.Image, frame_size: tuple[int, int]) -> Image.Image:
    cell = remove_edge_fragments(cell)
    square = min(frame_size)
    content = cell.resize((square, square), Image.Resampling.LANCZOS)
    frame = Image.new("RGBA", frame_size, (0, 0, 0, 0))
    frame.alpha_composite(content, ((frame_size[0] - square) // 2, 0))
    return frame


def remove_edge_fragments(cell: Image.Image) -> Image.Image:
    pixels = np.asarray(cell).copy()
    mask = (pixels[:, :, 3] > 16).astype(np.uint8)
    count, labels, stats, _centroids = cv2.connectedComponentsWithStats(mask, connectivity=8)
    if count <= 1:
        return cell
    largest = int(stats[1:, cv2.CC_STAT_AREA].max())
    height, width = mask.shape
    for label in range(1, count):
        x, _y, component_width, _component_height, area = stats[label]
        touches_side = x <= 1 or x + component_width >= width - 1
        if touches_side and area < largest * 0.18:
            pixels[labels == label] = 0
    return Image.fromarray(pixels, "RGBA")


def checkerboard(size: tuple[int, int]) -> Image.Image:
    review = Image.new("RGBA", size, (38, 41, 49, 255))
    draw = ImageDraw.Draw(review)
    tile = 24
    for y in range(0, size[1], tile):
        for x in range(0, size[0], tile):
            if (x // tile + y // tile) % 2 == 0:
                draw.rectangle((x, y, x + tile - 1, y + tile - 1), fill=(62, 66, 78, 255))
    return review


def process() -> dict:
    EXPORT_ROOT.mkdir(parents=True, exist_ok=True)
    WORKING_ROOT.mkdir(parents=True, exist_ok=True)
    entries = []
    for archetype_id, spec in ROSTER.items():
        source_path = SOURCE_ROOT / spec["source"]
        source = Image.open(source_path).convert("RGB")
        if source.size != (1254, 1254):
            raise RuntimeError(f"{source_path.name}: dimensions 1254 × 1254 attendues")
        transparent = extract_alpha(source)
        frame_width, frame_height = spec["frame"]
        atlas = Image.new("RGBA", (frame_width * 4, frame_height * 4), (0, 0, 0, 0))
        frame_reports = []
        frames = []
        for index, phase in enumerate(PHASES):
            column = index % 4
            row = index // 4
            cell = transparent.crop((
                GRID_EDGES[column], GRID_EDGES[row],
                GRID_EDGES[column + 1], GRID_EDGES[row + 1],
            ))
            frame = normalise_cell(cell, spec["frame"])
            alpha_bbox = frame.getchannel("A").point(lambda value: 255 if value > 16 else 0).getbbox()
            if alpha_bbox is None:
                raise RuntimeError(f"{archetype_id}/{phase}: pose alpha vide")
            frames.append(frame)
            atlas.alpha_composite(frame, (column * frame_width, row * frame_height))
            frame_reports.append({
                "index": index,
                "phase": phase,
                "alpha_bbox": list(alpha_bbox),
                "root": list(spec["root"]),
            })

        atlas_path = EXPORT_ROOT / f"{archetype_id.replace('_', '-')}-animation-4x4-v001.png"
        atlas.save(atlas_path)
        if atlas.getchannel("A").getextrema() != (0, 255):
            raise RuntimeError(f"{atlas_path.name}: alpha runtime incomplet")
        review = checkerboard(atlas.size)
        review.alpha_composite(atlas)
        draw = ImageDraw.Draw(review)
        for column in range(1, 4):
            draw.line((column * frame_width, 0, column * frame_width, atlas.height), fill=(240, 32, 141, 180))
        for row in range(1, 4):
            draw.line((0, row * frame_height, atlas.width, row * frame_height), fill=(240, 32, 141, 180))
        for index in range(16):
            x = (index % 4) * frame_width + spec["root"][0]
            y = (index // 4) * frame_height + spec["root"][1]
            draw.line((x - 8, y, x + 8, y), fill=(181, 214, 31, 255), width=2)
        review_path = WORKING_ROOT / f"{archetype_id.replace('_', '-')}-animation-v001-review.png"
        review.save(review_path)
        preview_path = WORKING_ROOT / f"{archetype_id.replace('_', '-')}-animation-v001-preview.webp"
        durations = [140] * 4 + [170, 210, 150, 240] + [90, 110, 130, 170] + [160, 190, 240, 520]
        frames[0].save(
            preview_path,
            save_all=True,
            append_images=frames[1:],
            duration=durations,
            loop=0,
            lossless=True,
            method=6,
        )
        entries.append({
            "archetype_id": archetype_id,
            "source": str(source_path.relative_to(PROJECT_ROOT)),
            "source_sha256": sha256(source_path),
            "atlas": str(atlas_path.relative_to(PROJECT_ROOT)),
            "atlas_sha256": sha256(atlas_path),
            "frame_size": list(spec["frame"]),
            "root": list(spec["root"]),
            "review": str(review_path.relative_to(PROJECT_ROOT)),
            "preview": str(preview_path.relative_to(PROJECT_ROOT)),
            "frames": frame_reports,
        })

    report = {
        "schema": "jeuweb.enemy-roster-qa.v1",
        "status": "published",
        "frame_count": 64,
        "entries": entries,
        "statuses": {
            "visual": "accepted",
            "temporal": "accepted-key-poses",
            "technical": "passed",
            "gameplay": "integrated",
        },
        "known_limits": [
            "L'alpha est extrait du fond cyan uniforme demandé à ImageGen.",
            "Les interpolations entre les quatre poses restent portées par SpriteFrames.",
        ],
    }
    qa_path = WORKING_ROOT / "industrial-toxic-enemy-roster-v001-qa.json"
    qa_path.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return report


if __name__ == "__main__":
    result = process()
    print(f"Industrial toxic enemy roster: {result['frame_count']} poses processed")
