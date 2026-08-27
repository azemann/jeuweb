#!/usr/bin/env python3
"""Valide le projectile et l'impact toxiques candidats."""

import hashlib
import json
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[3]
QA = ROOT / "pipeline/assets/working/enemies/vacuum_trooper/toxic-pressure-lot-v001-qa.json"
PROFILE = ROOT / "pipeline/assets/profiles/toxic_pressure_profile_v001.json"
MANIFEST = ROOT / "pipeline/assets/manifests/toxic_pressure_v001.json"


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def validate_atlas(path: Path, size: tuple[int, int], cell: tuple[int, int], count: int, columns: int) -> None:
    atlas = Image.open(path)
    assert atlas.mode == "RGBA" and atlas.size == size
    assert atlas.getchannel("A").getextrema() == (0, 255)
    for index in range(count):
        left, top = (index % columns) * cell[0], (index // columns) * cell[1]
        frame = atlas.crop((left, top, left + cell[0], top + cell[1]))
        frame_bbox = frame.getchannel("A").point(lambda value: 255 if value > 24 else 0).getbbox()
        assert frame_bbox is not None
        assert frame_bbox[0] > 0 and frame_bbox[1] > 0 and frame_bbox[2] < cell[0] and frame_bbox[3] < cell[1]


def main() -> None:
    report = json.loads(QA.read_text(encoding="utf-8"))
    profile = json.loads(PROFILE.read_text(encoding="utf-8"))
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    validate_atlas(ROOT / report["projectile"]["atlas"], (384, 64), (96, 64), 4, 4)
    validate_atlas(ROOT / report["impact"]["atlas"], (576, 320), (192, 160), 6, 3)
    assert len(report["projectile"]["durations_ms"]) == 4
    assert len(report["impact"]["durations_ms"]) == 6
    assert profile["status"] == "published"
    assert profile["projectile"]["runtimeCell"] == report["projectile"]["runtime_cell"]
    assert profile["projectile"]["durationsMs"] == report["projectile"]["durations_ms"]
    assert profile["impact"]["runtimeCell"] == report["impact"]["runtime_cell"]
    assert profile["impact"]["durationsMs"] == report["impact"]["durations_ms"]
    assert manifest["status"] == "published"
    assert manifest["statuses"] == report["statuses"]
    for asset in manifest["assets"]:
        assert sha256(ROOT / asset["path"]) == asset["sha256"]
    print("Toxic pressure projectile/impact candidates: technical validation passed")


if __name__ == "__main__":
    main()
