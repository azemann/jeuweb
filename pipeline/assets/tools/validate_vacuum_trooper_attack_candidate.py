#!/usr/bin/env python3
"""Valide les invariants techniques de l'attaque candidate."""

import hashlib
import json
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[3]
QA = ROOT / "pipeline/assets/working/enemies/vacuum_trooper/vacuum-trooper-toxic-attack-v001-qa.json"
PROFILE = ROOT / "pipeline/assets/profiles/vacuum_trooper_attack_profile_v001.json"
MANIFEST = ROOT / "pipeline/assets/manifests/vacuum_trooper_attack_v001.json"


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> None:
    report = json.loads(QA.read_text(encoding="utf-8"))
    profile = json.loads(PROFILE.read_text(encoding="utf-8"))
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    atlas = Image.open(ROOT / report["atlas"])
    assert atlas.mode == "RGBA" and atlas.size == (1024, 384)
    assert atlas.getchannel("A").getextrema() == (0, 255)
    assert report["frame_count"] == 8
    assert report["runtime_root"] == [128, 180]
    phases = [
        "detect", "windup", "charge", "release", "active", "recoil", "recover", "ready"
    ]
    assert [frame["phase"] for frame in report["frames"]] == phases
    animation = profile["animations"]["toxic_attack"]
    assert profile["status"] == "published"
    assert profile["runtimeRoot"] == report["runtime_root"]
    assert animation["phases"] == phases
    assert animation["durationsMs"] == [frame["duration_ms"] for frame in report["frames"]]
    assert manifest["status"] == "published"
    assert manifest["statuses"] == report["statuses"]
    for asset in manifest["assets"]:
        if "sha256" in asset:
            assert sha256(ROOT / asset["path"]) == asset["sha256"]
    for index in range(8):
        cell = atlas.crop(((index % 4) * 256, (index // 4) * 192, (index % 4 + 1) * 256, (index // 4 + 1) * 192))
        bbox = cell.getchannel("A").point(lambda value: 255 if value > 24 else 0).getbbox()
        assert bbox is not None and 0 <= bbox[0] < bbox[2] <= 256 and 0 <= bbox[1] < bbox[3] <= 192
    print("Vacuum Trooper toxic attack candidate: technical validation passed")


if __name__ == "__main__":
    main()
