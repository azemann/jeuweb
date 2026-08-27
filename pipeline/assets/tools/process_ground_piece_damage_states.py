#!/usr/bin/env python3
"""Extrait et normalise les états endommagé/détruit d'une Ground Piece."""

from __future__ import annotations

from collections import deque
import hashlib
import json
from pathlib import Path

import numpy as np
from PIL import Image


PROJECT_ROOT = Path(__file__).resolve().parents[3]
SOURCE_DIR = PROJECT_ROOT / "pipeline/assets/sources/terrain_kits/toxic_coast/natural/damage_states"
EXPORT_DIR = PROJECT_ROOT / "pipeline/assets/exports/terrain_kits/toxic_coast/natural/damage_states"
WORKING_DIR = PROJECT_ROOT / "pipeline/assets/working/terrain_kits/toxic_coast"
STATES = {
    "damaged": SOURCE_DIR / "natural-ledge-medium-damaged-source-v001.png",
    "destroyed": SOURCE_DIR / "natural-ledge-medium-destroyed-source-v001.png",
}
CANVAS_SIZE = (768, 384)
SAFE_SIZE = (704, 304)
CONTENT_TOP = 40
PIVOT = [384, 64]


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def edge_background_mask(rgb: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    """Retire uniquement le fond uni relié aux bords, sans trouer le sujet."""
    height, width, _channels = rgb.shape
    corners = np.concatenate((
        rgb[:24, :24].reshape(-1, 3),
        rgb[:24, -24:].reshape(-1, 3),
        rgb[-24:, :24].reshape(-1, 3),
        rgb[-24:, -24:].reshape(-1, 3),
    ))
    background = np.median(corners, axis=0).astype(np.int32)
    difference = rgb.astype(np.int32) - background
    distance = np.sqrt(np.sum(difference * difference, axis=2, dtype=np.int64))
    light_background = float(background.mean()) > 127.0
    connection_limit = 155.0 if light_background else 72.0
    opaque_distance = 142.0 if light_background else 64.0
    candidate = distance <= connection_limit
    connected = np.zeros((height, width), dtype=bool)
    queue: deque[tuple[int, int]] = deque()
    for x in range(width):
        if candidate[0, x]:
            connected[0, x] = True
            queue.append((0, x))
        if candidate[height - 1, x]:
            connected[height - 1, x] = True
            queue.append((height - 1, x))
    for y in range(height):
        if candidate[y, 0]:
            connected[y, 0] = True
            queue.append((y, 0))
        if candidate[y, width - 1]:
            connected[y, width - 1] = True
            queue.append((y, width - 1))
    while queue:
        y, x = queue.popleft()
        for ny, nx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
            if 0 <= ny < height and 0 <= nx < width and candidate[ny, nx] and not connected[ny, nx]:
                connected[ny, nx] = True
                queue.append((ny, nx))
    alpha = np.full((height, width), 255, dtype=np.uint8)
    alpha[connected] = np.clip(
        (distance[connected] - 8.0) * 255.0 / (opaque_distance - 8.0), 0, 255
    ).astype(np.uint8)
    return alpha, background


def remove_background_matte(rgb: np.ndarray, alpha: np.ndarray, background: np.ndarray) -> np.ndarray:
    """Retire la contamination blanche/noire des pixels semi-transparents."""
    alpha_fraction = alpha.astype(np.float32) / 255.0
    corrected = rgb.astype(np.float32).copy()
    partial = (alpha > 0) & (alpha < 255)
    for channel in range(3):
        values = corrected[:, :, channel]
        values[partial] = (
            values[partial] - float(background[channel]) * (1.0 - alpha_fraction[partial])
        ) / np.maximum(alpha_fraction[partial], 1.0 / 255.0)
        corrected[:, :, channel] = values
    corrected[alpha == 0] = 0.0
    return np.clip(corrected, 0, 255).astype(np.uint8)


def normalize(state: str, source_path: Path) -> dict:
    source = Image.open(source_path).convert("RGB")
    rgb = np.asarray(source)
    alpha, background = edge_background_mask(rgb)
    clean_rgb = remove_background_matte(rgb, alpha, background)
    rgba = np.dstack((clean_rgb, alpha))
    isolated_source = Image.fromarray(rgba, "RGBA")
    bbox = isolated_source.getchannel("A").point(lambda value: 255 if value > 24 else 0).getbbox()
    if bbox is None:
        raise RuntimeError(f"{state}: aucun sujet après extraction du fond")
    isolated = isolated_source.crop(bbox)
    scale = min(SAFE_SIZE[0] / isolated.width, SAFE_SIZE[1] / isolated.height)
    content_size = (max(1, round(isolated.width * scale)), max(1, round(isolated.height * scale)))
    content = isolated.resize(content_size, Image.Resampling.LANCZOS)
    position = ((CANVAS_SIZE[0] - content_size[0]) // 2, CONTENT_TOP)
    canvas = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    canvas.alpha_composite(content, position)
    output = EXPORT_DIR / f"natural-ledge-medium-{state}-768x384-v001.png"
    output.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(output)
    return {
        "state": state,
        "source": str(source_path.relative_to(PROJECT_ROOT)),
        "output": str(output.relative_to(PROJECT_ROOT)),
        "source_background_rgb": background.astype(int).tolist(),
        "source_bbox": list(bbox),
        "content_size": list(content_size),
        "content_position": list(position),
        "pivot_px": PIVOT,
        "source_sha256": sha256(source_path),
        "export_sha256": sha256(output),
    }


def main() -> None:
    report = {
        "schema": "jeuweb.ground-piece-damage-states-qa.v1",
        "piece_id": "natural_ledge_medium",
        "status": "candidate",
        "canvas": list(CANVAS_SIZE),
        "pivot_px": PIVOT,
        "states": [normalize(state, source) for state, source in STATES.items()],
        "validation": {"technical": "pending", "human_approval": "pending", "consumer_import": "not-run"},
    }
    WORKING_DIR.mkdir(parents=True, exist_ok=True)
    qa_path = WORKING_DIR / "natural-ledge-medium-damage-states-v001-qa.json"
    qa_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"Ground Piece damage states processed; QA: {qa_path.relative_to(PROJECT_ROOT)}")


if __name__ == "__main__":
    main()
