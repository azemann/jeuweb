#!/usr/bin/env python3
"""Porte de validation technique du lot joueur v001."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

from PIL import Image


PROJECT_ROOT = Path(__file__).resolve().parents[3]
MANIFEST_PATH = PROJECT_ROOT / "pipeline/assets/manifests/player_lot_v001.json"
EXPORT_DIR = PROJECT_ROOT / "pipeline/assets/exports/player"
FRAME_DIR = EXPORT_DIR / "body-frames-192"


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def require(condition: bool, message: str, failures: list[str]) -> None:
    if not condition:
        failures.append(message)


def main() -> None:
    failures: list[str] = []
    manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    require(
        manifest["status"] in ["candidate", "validated", "integrated"],
        "invalid lot lifecycle status",
        failures,
    )
    for asset in manifest["assets"]:
        path = PROJECT_ROOT / asset["path"]
        require(path.is_file(), f"missing source: {asset['path']}", failures)
        require(sha256(path) == asset["sha256"], f"hash mismatch: {asset['path']}", failures)

    frames = sorted(FRAME_DIR.glob("*.png"))
    require(len(frames) == 12, f"expected 12 frames, found {len(frames)}", failures)
    for frame in frames:
        image = Image.open(frame).convert("RGBA")
        bbox = image.getchannel("A").getbbox()
        require(image.size == (192, 192), f"invalid frame size: {frame.name}", failures)
        require(bbox is not None, f"empty alpha: {frame.name}", failures)
        if bbox is not None:
            require(bbox[0] >= 0 and bbox[2] <= 192, f"horizontal overflow: {frame.name}", failures)
            require(bbox[1] >= 0 and bbox[3] <= 181, f"root overflow: {frame.name} {bbox}", failures)

    expected = {
        "player-body-atlas-4x3-192-v001.png": (768, 576),
        "player-primary-cannon-768-v001.png": (768, 384),
    }
    for filename, size in expected.items():
        image = Image.open(EXPORT_DIR / filename).convert("RGBA")
        require(image.size == size, f"invalid export size: {filename}", failures)
        require(image.getchannel("A").getbbox() is not None, f"empty export: {filename}", failures)

    if failures:
        for failure in failures:
            print(f"ERROR: {failure}")
        raise SystemExit(1)
    print("PLAYER_ASSET_CANDIDATE_VALIDATION: PASS")


if __name__ == "__main__":
    main()
