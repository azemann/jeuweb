#!/usr/bin/env python3
"""Porte technique des états de dégâts de la corniche Côte toxique."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

from PIL import Image


PROJECT_ROOT = Path(__file__).resolve().parents[3]
QA = PROJECT_ROOT / "pipeline/assets/working/terrain_kits/toxic_coast/natural-ledge-medium-damage-states-v001-qa.json"
EXPECTED_SIZE = (768, 384)
EXPECTED_PIVOT = [384, 64]


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> None:
    report = json.loads(QA.read_text(encoding="utf-8"))
    assert report["pivot_px"] == EXPECTED_PIVOT
    assert len(report["states"]) == 2
    for state in report["states"]:
        path = PROJECT_ROOT / state["output"]
        image = Image.open(path)
        assert image.mode == "RGBA", f"{path}: RGBA attendu"
        assert image.size == EXPECTED_SIZE, f"{path}: taille inattendue"
        alpha = image.getchannel("A")
        assert alpha.getextrema() == (0, 255), f"{path}: alpha incomplet"
        width, height = image.size
        edges = (
            alpha.crop((0, 0, width, 1)), alpha.crop((0, height - 1, width, height)),
            alpha.crop((0, 0, 1, height)), alpha.crop((width - 1, 0, width, height)),
        )
        assert all(edge.getextrema()[1] == 0 for edge in edges), f"{path}: alpha sur un bord"
        assert sha256(path) == state["export_sha256"], f"{path}: empreinte incohérente"
    report["validation"]["technical"] = "passed"
    QA.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print("GROUND_PIECE_DAMAGE_STATES_VALIDATION: PASS")


if __name__ == "__main__":
    main()
