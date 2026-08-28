#!/usr/bin/env python3
"""Valide les livrables publiés du roster ennemi industriel toxique."""

from __future__ import annotations

import json
from pathlib import Path

from PIL import Image


PROJECT_ROOT = Path(__file__).resolve().parents[3]
QA_PATH = PROJECT_ROOT / "pipeline/assets/working/enemies/industrial_toxic_v001/industrial-toxic-enemy-roster-v001-qa.json"
MANIFEST_PATH = PROJECT_ROOT / "pipeline/assets/manifests/industrial_toxic_enemy_roster_v001.json"
EXPECTED = {
    "vacuum_grunt": (1280, 1024),
    "vacuum_flying": (1024, 1024),
    "vacuum_boss": (1536, 1280),
    "vacuum_pilot_saboteur": (768, 768),
}


def validate() -> None:
    manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    report = json.loads(QA_PATH.read_text(encoding="utf-8"))
    assert manifest["status"] == "published", "manifest not published"
    assert report["status"] == "published", "QA not published"
    assert report["statuses"]["gameplay"] == "integrated", "gameplay not integrated"
    assert report["frame_count"] == 64, "64 poses expected"
    assert set(manifest["archetypes"]) == set(EXPECTED), "manifest roster mismatch"
    assert len(report["entries"]) == 4, "four QA entries expected"
    for entry in report["entries"]:
        archetype_id = entry["archetype_id"]
        assert archetype_id in EXPECTED, f"unexpected archetype: {archetype_id}"
        assert len(entry["frames"]) == 16, f"{archetype_id}: 16 poses expected"
        export_path = PROJECT_ROOT / entry["atlas"]
        runtime_path = PROJECT_ROOT / "art/enemies/industrial_toxic" / export_path.name
        for path in (export_path, runtime_path):
            assert path.is_file(), f"missing atlas: {path}"
            with Image.open(path) as image:
                assert image.mode == "RGBA", f"{path.name}: RGBA expected"
                assert image.size == EXPECTED[archetype_id], f"{path.name}: unexpected size"
                assert image.getchannel("A").getextrema() == (0, 255), f"{path.name}: invalid alpha"
        assert export_path.read_bytes() == runtime_path.read_bytes(), f"{archetype_id}: runtime copy differs"


if __name__ == "__main__":
    validate()
    print("INDUSTRIAL_TOXIC_ENEMY_ROSTER_VALIDATION: PASS")
