#!/usr/bin/env python3
"""Valide sources, exports, publication et contrat consommateur du roster v002."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[3]
QA_PATH = ROOT / "pipeline/assets/working/enemies/animation_roster_v002/enemy-animation-roster-v002-qa.json"
MANIFEST_PATH = ROOT / "pipeline/assets/manifests/enemy_animation_roster_v002.json"
PROVENANCE_PATH = ROOT / "pipeline/assets/provenance/enemy_animation_roster_v002.json"
RECIPE_PATH = ROOT / "pipeline/assets/recipes/enemy_animation_roster_v002.md"

PUBLICATION = {
    "vacuum_grunt": {
        "animation-4x4-v002.png": (
            "art/enemies/industrial_toxic/vacuum-grunt-animation-4x4-v002.png",
            (1280, 1024),
        ),
    },
    "vacuum_flying": {
        "animation-4x4-v002.png": (
            "art/enemies/industrial_toxic/vacuum-flying-animation-4x4-v002.png",
            (1024, 1024),
        ),
    },
    "vacuum_boss": {
        "animation-4x4-v002.png": (
            "art/enemies/industrial_toxic/vacuum-boss-animation-4x4-v002.png",
            (1536, 1280),
        ),
    },
    "vacuum_pilot_saboteur": {
        "animation-4x4-v002.png": (
            "art/enemies/industrial_toxic/vacuum-pilot-saboteur-animation-4x4-v002.png",
            (768, 768),
        ),
    },
    "vacuum_trooper": {
        "walk-4x2-256-v002.png": (
            "art/characters/enemies/vacuum_trooper/vacuum-trooper-walk-4x2-256-v002.png",
            (1024, 384),
        ),
        "toxic-attack-4x2-256-v002.png": (
            "art/characters/enemies/vacuum_trooper/vacuum-trooper-toxic-attack-4x2-256-v002.png",
            (1024, 384),
        ),
        "hit-death-4x2-256-v002.png": (
            "art/characters/enemies/vacuum_trooper/vacuum-trooper-hit-death-4x2-256-v002.png",
            (1024, 384),
        ),
    },
}

RESOURCE_FILES = [
    "characters/enemies/vacuum_grunt/vacuum_grunt_frames.tres",
    "characters/enemies/vacuum_flying/vacuum_flying_frames.tres",
    "characters/enemies/vacuum_boss/vacuum_boss_frames.tres",
    "characters/enemies/vacuum_pilot_saboteur/vacuum_pilot_saboteur_frames.tres",
    "characters/enemies/vacuum_trooper/vacuum_trooper_frames.tres",
    "characters/enemies/vacuum_trooper/vacuum_trooper_attack_frames.tres",
]


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def require(condition: bool, message: str) -> None:
    if not condition:
        raise RuntimeError(message)


def main() -> None:
    for path in (QA_PATH, MANIFEST_PATH, PROVENANCE_PATH, RECIPE_PATH):
        require(path.is_file(), f"Fichier de contrat absent : {path.relative_to(ROOT)}")

    qa = json.loads(QA_PATH.read_text(encoding="utf-8"))
    manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    require(qa["status"] == "published", "Le QA v002 doit être publié.")
    require(manifest["status"] == "published", "Le manifeste v002 doit être publié.")
    require(qa["frame_count"] == 88 == manifest["poseCount"], "Le lot doit contenir exactement 88 poses.")
    require(qa["statuses"]["technical"] == "passed", "Le statut technique doit être passed.")
    require(len(qa["entries"]) == 5, "Le QA doit couvrir cinq archétypes.")

    checked_atlases = 0
    for entry in qa["entries"]:
        archetype_id = entry["archetype_id"]
        require(archetype_id in PUBLICATION, f"Archétype inattendu : {archetype_id}")
        for source in entry["sources"]:
            source_path = ROOT / source["path"]
            require(source_path.is_file(), f"Source absente : {source['path']}")
            require(sha256(source_path) == source["sha256"], f"Hash source invalide : {source['path']}")
        for atlas in entry["atlases"]:
            export_path = ROOT / atlas["path"]
            filename = export_path.name
            require(filename in PUBLICATION[archetype_id], f"Atlas inattendu : {atlas['path']}")
            published_relative, expected_size = PUBLICATION[archetype_id][filename]
            published_path = ROOT / published_relative
            require(export_path.is_file() and published_path.is_file(), f"Export/publication absent : {filename}")
            require(sha256(export_path) == atlas["sha256"], f"Hash export invalide : {filename}")
            require(sha256(export_path) == sha256(published_path), f"Publication désynchronisée : {filename}")
            image = Image.open(published_path).convert("RGBA")
            require(image.size == expected_size, f"Dimensions incompatibles : {published_relative}")
            alpha_extrema = image.getchannel("A").getextrema()
            require(alpha_extrema == (0, 255), f"Alpha runtime invalide : {published_relative}")
            checked_atlases += 1

    require(checked_atlases == 7, "La publication doit contenir sept atlas.")
    for relative in RESOURCE_FILES:
        text = (ROOT / relative).read_text(encoding="utf-8")
        require("-v002.png" in text, f"Resource non migrée vers v002 : {relative}")
        require("-v001.png" not in text, f"Resource encore liée à v001 : {relative}")

    print("ENEMY_ANIMATION_ROSTER_V002_VALIDATION: PASS (88 poses, 7 atlas, 5 archetypes)")


if __name__ == "__main__":
    main()
