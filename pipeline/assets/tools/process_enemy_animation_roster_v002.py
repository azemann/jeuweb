#!/usr/bin/env python3
"""Normalise et publie les 88 poses ennemies de la passe v002.

Les sources ImageGen sont des bandes horizontales de quatre poses sur fond cyan.
Le pipeline est l'autorite du detourage, de l'echelle commune par action, de
l'ancrage et de la construction des atlas runtime.
"""

from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass
from pathlib import Path

import cv2
import numpy as np
from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[3]
INDUSTRIAL_SOURCE = ROOT / "pipeline/assets/sources/imagegen/enemies/industrial_toxic_v002"
TROOPER_SOURCE = ROOT / "pipeline/assets/sources/imagegen/enemies/vacuum_trooper_v002"
EXPORT_ROOT = ROOT / "pipeline/assets/exports/enemies/animation_roster_v002"
WORKING_ROOT = ROOT / "pipeline/assets/working/enemies/animation_roster_v002"

ACTIONS = ("move", "attack", "hit", "death")
CYAN_DISTANCE_MIN = 20.0
CYAN_DISTANCE_MAX = 105.0
ALPHA_THRESHOLD = 20


@dataclass(frozen=True)
class Archetype:
    source_dir: Path
    source_strips: dict[str, tuple[str, ...]]
    frame_size: tuple[int, int]
    root: tuple[int, int]
    flying: bool = False


ARCHETYPES = {
    "vacuum_grunt": Archetype(
        INDUSTRIAL_SOURCE / "vacuum_grunt",
        {action: (f"{action}-strip-candidate-v002.png",) for action in ACTIONS},
        (320, 256),
        (160, 240),
    ),
    "vacuum_flying": Archetype(
        INDUSTRIAL_SOURCE / "vacuum_flying",
        {action: (f"{action}-strip-candidate-v002.png",) for action in ACTIONS},
        (256, 256),
        (128, 128),
        flying=True,
    ),
    "vacuum_boss": Archetype(
        INDUSTRIAL_SOURCE / "vacuum_boss",
        {action: (f"{action}-strip-candidate-v002.png",) for action in ACTIONS},
        (384, 320),
        (192, 300),
    ),
    "vacuum_pilot_saboteur": Archetype(
        INDUSTRIAL_SOURCE / "vacuum_pilot_saboteur",
        {action: (f"{action}-strip-candidate-v002.png",) for action in ACTIONS},
        (192, 192),
        (96, 180),
    ),
    "vacuum_trooper": Archetype(
        TROOPER_SOURCE,
        {
            "move": (
                "walk-a-strip-candidate-v002.png",
                "walk-b-strip-candidate-v002.png",
            ),
            "attack": (
                "attack-a-strip-candidate-v002.png",
                "attack-b-strip-candidate-v002.png",
            ),
            "hit": ("hit-strip-candidate-v002.png",),
            "death": ("death-strip-candidate-v002.png",),
        },
        (256, 192),
        (128, 180),
    ),
}


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def extract_alpha(source: Image.Image) -> Image.Image:
    rgb = np.asarray(source.convert("RGB"), dtype=np.float32)
    border = np.concatenate((rgb[0], rgb[-1], rgb[:, 0], rgb[:, -1]), axis=0)
    background = np.median(border, axis=0)
    distance = np.linalg.norm(rgb - background, axis=2)
    alpha = np.clip(
        (distance - CYAN_DISTANCE_MIN)
        * 255.0
        / (CYAN_DISTANCE_MAX - CYAN_DISTANCE_MIN),
        0.0,
        255.0,
    ).astype(np.uint8)
    cyan = (rgb[:, :, 1] > 165) & (rgb[:, :, 2] > 165) & (rgb[:, :, 0] < 125)
    alpha[cyan & (distance < CYAN_DISTANCE_MAX)] = 0
    rgba = np.dstack((rgb.astype(np.uint8), alpha))
    rgba[alpha == 0, :3] = 0
    return Image.fromarray(rgba, "RGBA")


def split_strip(path: Path) -> list[Image.Image]:
    source = extract_alpha(Image.open(path).convert("RGB"))
    width, height = source.size
    edges = [round(width * index / 4) for index in range(5)]
    return [
        remove_edge_fragments(source.crop((edges[index], 0, edges[index + 1], height)))
        for index in range(4)
    ]


def remove_edge_fragments(cell: Image.Image) -> Image.Image:
    """Retire les miettes d'une pose voisine sans toucher aux effets internes."""
    pixels = np.asarray(cell).copy()
    mask = (pixels[:, :, 3] > ALPHA_THRESHOLD).astype(np.uint8)
    count, labels, stats, _centroids = cv2.connectedComponentsWithStats(mask, connectivity=8)
    if count <= 1:
        return cell
    largest_label = 1 + int(np.argmax(stats[1:, cv2.CC_STAT_AREA]))
    width = mask.shape[1]
    for label in range(1, count):
        x, _y, component_width, _component_height, _area = stats[label]
        touches_side = x <= 2 or x + component_width >= width - 2
        if touches_side and label != largest_label:
            pixels[labels == label] = 0
    return Image.fromarray(pixels, "RGBA")


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    bbox = image.getchannel("A").point(
        lambda value: 255 if value > ALPHA_THRESHOLD else 0
    ).getbbox()
    if bbox is None:
        raise RuntimeError("Pose vide apres extraction alpha")
    return bbox


def normalise_action(
    cells: list[Image.Image], spec: Archetype
) -> tuple[list[Image.Image], float]:
    bboxes = [alpha_bbox(cell) for cell in cells]
    max_width = max(right - left for left, _top, right, _bottom in bboxes)
    max_height = max(bottom - top for _left, top, _right, bottom in bboxes)
    frame_width, frame_height = spec.frame_size
    horizontal_margin = max(8, round(frame_width * 0.035))
    vertical_margin = max(8, round(frame_height * 0.045))
    available_width = frame_width - horizontal_margin * 2
    available_height = frame_height - vertical_margin * 2
    if not spec.flying:
        available_height = spec.root[1] - vertical_margin
    scale = min(available_width / max_width, available_height / max_height)

    frames: list[Image.Image] = []
    for cell, bbox in zip(cells, bboxes):
        content = cell.crop(bbox)
        size = (
            max(1, round(content.width * scale)),
            max(1, round(content.height * scale)),
        )
        content = content.resize(size, Image.Resampling.LANCZOS)
        frame = Image.new("RGBA", spec.frame_size, (0, 0, 0, 0))
        x = spec.root[0] - content.width // 2
        if spec.flying:
            y = spec.root[1] - content.height // 2
        else:
            y = spec.root[1] - content.height
        x = min(max(horizontal_margin, x), frame_width - horizontal_margin - content.width)
        y = min(max(vertical_margin, y), frame_height - vertical_margin - content.height)
        frame.alpha_composite(content, (x, y))
        frames.append(frame)
    return frames, scale


def checkerboard(size: tuple[int, int]) -> Image.Image:
    result = Image.new("RGBA", size, (38, 41, 49, 255))
    draw = ImageDraw.Draw(result)
    tile = 24
    for y in range(0, size[1], tile):
        for x in range(0, size[0], tile):
            if (x // tile + y // tile) % 2 == 0:
                draw.rectangle((x, y, x + tile - 1, y + tile - 1), fill=(62, 66, 78, 255))
    return result


def save_review(
    archetype_id: str,
    frames_by_action: dict[str, list[Image.Image]],
    spec: Archetype,
) -> Path:
    frame_width, frame_height = spec.frame_size
    columns = max(len(frames) for frames in frames_by_action.values())
    review = checkerboard((columns * frame_width, 4 * frame_height))
    draw = ImageDraw.Draw(review)
    for row, action in enumerate(ACTIONS):
        for column, frame in enumerate(frames_by_action[action]):
            review.alpha_composite(frame, (column * frame_width, row * frame_height))
            root_x = column * frame_width + spec.root[0]
            root_y = row * frame_height + spec.root[1]
            draw.line((root_x - 7, root_y, root_x + 7, root_y), fill=(181, 214, 31, 255), width=2)
        draw.text((6, row * frame_height + 5), action, fill=(240, 32, 141, 255))
    for column in range(1, columns):
        x = column * frame_width
        draw.line((x, 0, x, review.height), fill=(240, 32, 141, 150))
    for row in range(1, 4):
        y = row * frame_height
        draw.line((0, y, review.width, y), fill=(240, 32, 141, 150))
    path = WORKING_ROOT / f"{archetype_id.replace('_', '-')}-animation-v002-review.png"
    review.save(path)
    return path


def save_preview(
    archetype_id: str, frames_by_action: dict[str, list[Image.Image]]
) -> Path:
    frames = [frame for action in ACTIONS for frame in frames_by_action[action]]
    durations: list[int] = []
    for action in ACTIONS:
        count = len(frames_by_action[action])
        if action == "move":
            durations.extend([115] * count)
        elif action == "attack":
            durations.extend(([150, 190, 130, 230] * 2)[:count])
        elif action == "hit":
            durations.extend([80, 105, 135, 190])
        else:
            durations.extend([145, 180, 230, 650])
    path = WORKING_ROOT / f"{archetype_id.replace('_', '-')}-animation-v002-preview.webp"
    frames[0].save(
        path,
        save_all=True,
        append_images=frames[1:],
        duration=durations,
        loop=0,
        lossless=True,
        method=6,
    )
    return path


def publish_atlases(
    archetype_id: str,
    frames_by_action: dict[str, list[Image.Image]],
    spec: Archetype,
) -> list[Path]:
    frame_width, frame_height = spec.frame_size
    target_dir = EXPORT_ROOT / archetype_id
    target_dir.mkdir(parents=True, exist_ok=True)
    if archetype_id == "vacuum_trooper":
        layouts = {
            "walk-4x2-256-v002.png": ("move",),
            "toxic-attack-4x2-256-v002.png": ("attack",),
            "hit-death-4x2-256-v002.png": ("hit", "death"),
        }
    else:
        layouts = {"animation-4x4-v002.png": ACTIONS}

    paths: list[Path] = []
    for filename, actions in layouts.items():
        if len(actions) == 1:
            frames = frames_by_action[actions[0]]
            columns, rows = 4, 2
        else:
            frames = [frame for action in actions for frame in frames_by_action[action]]
            columns = 4
            rows = len(frames) // columns
        atlas = Image.new("RGBA", (columns * frame_width, rows * frame_height), (0, 0, 0, 0))
        for index, frame in enumerate(frames):
            atlas.alpha_composite(frame, ((index % columns) * frame_width, (index // columns) * frame_height))
        path = target_dir / filename
        atlas.save(path)
        paths.append(path)
    return paths


def process() -> dict:
    EXPORT_ROOT.mkdir(parents=True, exist_ok=True)
    WORKING_ROOT.mkdir(parents=True, exist_ok=True)
    entries = []
    total_frames = 0
    for archetype_id, spec in ARCHETYPES.items():
        frames_by_action: dict[str, list[Image.Image]] = {}
        action_scales = {}
        sources = []
        for action in ACTIONS:
            cells = []
            for filename in spec.source_strips[action]:
                path = spec.source_dir / filename
                cells.extend(split_strip(path))
                sources.append({
                    "action": action,
                    "path": str(path.relative_to(ROOT)),
                    "sha256": sha256(path),
                })
            frames, scale = normalise_action(cells, spec)
            frames_by_action[action] = frames
            action_scales[action] = round(scale, 6)
            total_frames += len(frames)

        atlases = publish_atlases(archetype_id, frames_by_action, spec)
        review = save_review(archetype_id, frames_by_action, spec)
        preview = save_preview(archetype_id, frames_by_action)
        frame_reports = []
        for action in ACTIONS:
            for index, frame in enumerate(frames_by_action[action]):
                bbox = alpha_bbox(frame)
                touches_edge = bbox[0] <= 1 or bbox[1] <= 1 or bbox[2] >= frame.width - 1 or bbox[3] >= frame.height - 1
                if touches_edge:
                    raise RuntimeError(f"{archetype_id}/{action}_{index}: contenu au bord")
                frame_reports.append({
                    "phase": f"{action}_{index}",
                    "alpha_bbox": list(bbox),
                    "root": list(spec.root),
                })
        entries.append({
            "archetype_id": archetype_id,
            "frame_size": list(spec.frame_size),
            "root": list(spec.root),
            "frame_count": len(frame_reports),
            "sources": sources,
            "action_scales": action_scales,
            "atlases": [
                {
                    "path": str(path.relative_to(ROOT)),
                    "sha256": sha256(path),
                }
                for path in atlases
            ],
            "review": str(review.relative_to(ROOT)),
            "preview": str(preview.relative_to(ROOT)),
            "frames": frame_reports,
        })

    report = {
        "schema": "jeuweb.enemy-animation-roster-qa.v2",
        "status": "published",
        "frame_count": total_frames,
        "entries": entries,
        "statuses": {
            "source_identity": "reviewed",
            "visual": "accepted",
            "temporal": "accepted-key-poses",
            "technical": "passed",
            "gameplay": "integrated-resource-test",
        },
        "rejected_generations": [
            "vacuum_flying/move initial: turbine inventory discontinuity",
            "vacuum_flying/hit initial: turbine inventory discontinuity",
            "vacuum_boss/attack initial: active beam touched cell boundary",
        ],
    }
    qa_path = WORKING_ROOT / "enemy-animation-roster-v002-qa.json"
    qa_path.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return report


if __name__ == "__main__":
    result = process()
    print(f"Enemy animation roster v002: {result['frame_count']} poses processed")
