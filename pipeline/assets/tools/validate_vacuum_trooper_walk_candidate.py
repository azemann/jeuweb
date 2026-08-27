#!/usr/bin/env python3
"""Valide le lot candidat Vacuum Trooper sans le promouvoir sous art/."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

from PIL import Image


PROJECT_ROOT = Path(__file__).resolve().parents[3]
MANIFEST = PROJECT_ROOT / "pipeline/assets/manifests/vacuum_trooper_walk_v001.json"
QA = PROJECT_ROOT / "pipeline/assets/working/enemies/vacuum_trooper/vacuum-trooper-walk-v001-qa.json"
PROFILE = PROJECT_ROOT / "pipeline/assets/profiles/vacuum_trooper_animation_profile_v001.json"
SOURCE = PROJECT_ROOT / "pipeline/assets/sources/imagegen/enemies/vacuum_trooper/vacuum-trooper-walk-sheet-candidate-v001.png"
FRAMES = PROJECT_ROOT / "pipeline/assets/exports/enemies/vacuum_trooper/walk-frames-256"
ATLAS = PROJECT_ROOT / "pipeline/assets/exports/enemies/vacuum_trooper/vacuum-trooper-walk-4x2-256-candidate-v001.png"
PUBLISHED = PROJECT_ROOT / "art/characters/enemies/vacuum_trooper/vacuum-trooper-walk-4x2-256-v001.png"
EXPECTED_SOURCE_SHA256 = "db489e24387f5b5a3a9b94ff2f075cd6359d7892f294c2a6f5b8322ea6ee063a"
EXPECTED_PUBLISHED_SHA256 = "d885176606cb70d76e98df81044c3a6683afaac370d1a4c0bb14c5086b19a9e3"


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
    require(qa["frame_count"] == 8, "Le cycle doit contenir exactement huit poses.")
    require(qa["runtime_frame"] == [256, 192], "Le canevas runtime doit mesurer 256 × 192.")
    require(qa["runtime_root"] == [128, 180], "Le root runtime commun doit rester [128, 180].")
    require(profile["animations"]["walk"]["durationsMs"] == [160] * 8, "Les huit durées doivent rester à 160 ms.")

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

    print("Vacuum Trooper walk v001: published QA passed (8 frames, fixed root, alpha safe).")


if __name__ == "__main__":
    main()
