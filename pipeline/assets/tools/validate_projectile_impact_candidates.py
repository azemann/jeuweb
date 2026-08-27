#!/usr/bin/env python3
"""Valide les contraintes techniques du lot projectile/impact candidat."""

from __future__ import annotations

import json
from pathlib import Path

from PIL import Image


PROJECT_ROOT = Path(__file__).resolve().parents[3]
QA_PATH = PROJECT_ROOT / "pipeline/assets/working/weapons/field-round-lot-v001-qa.json"


def validate_rgba(path: Path, expected_size: tuple[int, int]) -> None:
    image = Image.open(path)
    assert image.mode == "RGBA", f"{path}: mode {image.mode}, RGBA attendu"
    assert image.size == expected_size, f"{path}: taille {image.size}"
    alpha_min, alpha_max = image.getchannel("A").getextrema()
    assert alpha_min == 0 and alpha_max == 255, f"{path}: alpha incomplet"


def main() -> None:
    qa = json.loads(QA_PATH.read_text(encoding="utf-8"))
    projectile = PROJECT_ROOT / qa["projectile"]["output"]
    impact = PROJECT_ROOT / qa["impact"]["output"]
    validate_rgba(projectile, (384, 192))
    validate_rgba(impact, (768, 512))
    assert len(qa["impact"]["frames"]) == 6
    for frame in qa["impact"]["frames"]:
        left, top, right, bottom = frame["runtime_bbox"]
        assert 0 < left < right < 256, frame
        assert 0 < top < bottom < 256, frame
        assert frame["edge_alpha_max"] == 0, frame
    print("Projectile/impact candidates: technical validation passed")


if __name__ == "__main__":
    main()
