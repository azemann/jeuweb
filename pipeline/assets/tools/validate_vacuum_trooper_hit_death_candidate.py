#!/usr/bin/env python3
"""Valide le lot candidat impact/mort sans le promouvoir sous art/."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

from PIL import Image


PROJECT_ROOT = Path(__file__).resolve().parents[3]
MANIFEST = PROJECT_ROOT / "pipeline/assets/manifests/vacuum_trooper_hit_death_v001.json"
QA = PROJECT_ROOT / "pipeline/assets/working/enemies/vacuum_trooper/vacuum-trooper-hit-death-v001-qa.json"
PROFILE = PROJECT_ROOT / "pipeline/assets/profiles/vacuum_trooper_hit_death_profile_v001.json"
SOURCE = PROJECT_ROOT / "pipeline/assets/sources/imagegen/enemies/vacuum_trooper/vacuum-trooper-hit-death-sheet-candidate-v001.png"
FRAMES = PROJECT_ROOT / "pipeline/assets/exports/enemies/vacuum_trooper/hit-death-frames-256"
ATLAS = PROJECT_ROOT / "pipeline/assets/exports/enemies/vacuum_trooper/vacuum-trooper-hit-death-4x2-256-candidate-v001.png"
PUBLISHED = PROJECT_ROOT / "art/characters/enemies/vacuum_trooper/vacuum-trooper-hit-death-4x2-256-v001.png"
EXPECTED_SOURCE_SHA256 = "336b73c59be18335a713aa9a331662f8a4774b8d64ff6020b7d7e5109c5ecde1"
EXPECTED_PUBLISHED_SHA256 = "54b6342c11b1c3354c316d685b74fd0f56eeae44de3cb489b91b5d493f934ed2"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise RuntimeError(message)


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int] | None:
    return image.getchannel("A").point(lambda value: 255 if value > 24 else 0).getbbox()


def main() -> None:
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    qa = json.loads(QA.read_text(encoding="utf-8"))
    profile = json.loads(PROFILE.read_text(encoding="utf-8"))

    require(manifest["status"] == "published", "Le lot approuvé doit rester publié.")
    require(manifest["statuses"]["visual"] == "passed", "L'approbation visuelle doit rester enregistrée.")
    require(manifest["statuses"]["temporal"] == "passed", "L'approbation temporelle doit rester enregistrée.")
    require(manifest["statuses"]["gameplay"] == "integrated", "Le lot doit rester relié au SpriteFrames runtime.")
    require(hashlib.sha256(SOURCE.read_bytes()).hexdigest() == EXPECTED_SOURCE_SHA256, "La source ImageGen a changé.")
    require(hashlib.sha256(PUBLISHED.read_bytes()).hexdigest() == EXPECTED_PUBLISHED_SHA256, "L'atlas publié a changé.")
    require(qa["source_dimensions"] == [2079, 756], "Les dimensions source ont changé.")
    require(qa["frame_count"] == 8, "Le lot doit contenir exactement huit poses.")
    require(qa["runtime_frame"] == [256, 192], "Le canevas runtime doit mesurer 256 × 192.")
    require(qa["runtime_root"] == [128, 180], "Le root runtime commun doit rester [128, 180].")
    require(profile["animations"]["hit"]["durationsMs"] == [90, 80, 130, 160], "Timings impact inattendus.")
    require(profile["animations"]["death"]["durationsMs"] == [120, 160, 220, 600], "Timings mort inattendus.")

    frame_paths = sorted(FRAMES.glob("frame_*.png"))
    require(len(frame_paths) == 8, "Le dossier runtime doit contenir exactement huit frames.")
    for frame_path in frame_paths:
        with Image.open(frame_path).convert("RGBA") as frame:
            require(frame.size == (256, 192), f"Dimensions invalides : {frame_path.name}")
            bbox = alpha_bbox(frame)
            require(bbox is not None, f"Frame alpha vide : {frame_path.name}")
            require(bbox[0] > 0 and bbox[1] > 0 and bbox[2] < 256 and bbox[3] < 192, f"Silhouette au bord : {frame_path.name}")

    with Image.open(ATLAS).convert("RGBA") as atlas:
        require(atlas.size == (1024, 384), "L'atlas doit mesurer 1024 × 384.")

    print("Vacuum Trooper hit/death v001: published QA passed (8 frames, fixed root, alpha safe).")


if __name__ == "__main__":
    main()
