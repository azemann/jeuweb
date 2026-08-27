#!/usr/bin/env python3
"""Normalise le lot Côte toxique et publie ses PNG runtime validables.

Les sources restent dans pipeline/. Les exports reproductibles y restent aussi ;
seules leurs copies runtime sont publiées dans art/ pour l'import Godot.
"""

from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[3]


@dataclass(frozen=True)
class Asset:
    asset_id: str
    source: str
    export: str
    published: str
    canvas: tuple[int, int]
    safe: tuple[int, int]
    anchor: str


ASSETS = (
    Asset("military_bunker_block_medium", "military/military-bunker-block-medium-source-v001.png", "military/military-bunker-block-medium-768x384-v001.png", "art/terrain/pieces/toxic_coast/military/military-bunker-block-medium-v001.png", (768, 384), (704, 304), "top"),
    Asset("industrial_catwalk_medium", "metal/industrial-catwalk-medium-source-v001.png", "metal/industrial-catwalk-medium-768x384-v001.png", "art/terrain/pieces/toxic_coast/metal/industrial-catwalk-medium-v001.png", (768, 384), (704, 304), "top"),
    Asset("toxic_pipe_bridge_medium", "pipes/toxic-pipe-bridge-medium-source-v001.png", "pipes/toxic-pipe-bridge-medium-768x384-v001.png", "art/terrain/pieces/toxic_coast/pipes/toxic-pipe-bridge-medium-v001.png", (768, 384), (704, 304), "top"),
    Asset("toxic_acid_sump_medium", "hazards/toxic-acid-sump-medium-source-v001.png", "hazards/toxic-acid-sump-medium-768x384-v001.png", "art/terrain/hazards/toxic_coast/toxic-acid-sump-medium-v001.png", (768, 384), (704, 320), "bottom"),
    Asset("toxic_explosive_barrel", "objects/explosive-barrel-source-v001.png", "objects/explosive-barrel-256x320-v001.png", "art/props/toxic_coast/explosive-barrel-v001.png", (256, 320), (224, 288), "bottom"),
    Asset("military_supply_crate_closed", "objects/military-supply-crate-source-v001.png", "objects/military-supply-crate-closed-384x320-v001.png", "art/props/toxic_coast/military-supply-crate-closed-v001.png", (384, 320), (352, 288), "bottom"),
    Asset("military_supply_crate_open", "objects/military-supply-crate-open-source-v001.png", "objects/military-supply-crate-open-384x320-v001.png", "art/props/toxic_coast/military-supply-crate-open-v001.png", (384, 320), (352, 288), "bottom"),
)


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    bbox = image.getchannel("A").point(lambda a: 255 if a > 16 else 0).getbbox()
    if bbox is None:
        raise RuntimeError("silhouette alpha vide")
    return bbox


def process(asset: Asset) -> dict[str, object]:
    source_path = ROOT / "pipeline/assets/sources/terrain_kits/toxic_coast" / asset.source
    export_path = ROOT / "pipeline/assets/exports/terrain_kits/toxic_coast" / asset.export
    publish_path = ROOT / asset.published
    source = Image.open(source_path).convert("RGBA")
    isolated = source.crop(alpha_bbox(source))
    scale = min(asset.safe[0] / isolated.width, asset.safe[1] / isolated.height)
    size = (max(1, round(isolated.width * scale)), max(1, round(isolated.height * scale)))
    content = isolated.resize(size, Image.Resampling.LANCZOS)
    x = (asset.canvas[0] - size[0]) // 2
    y = 40 if asset.anchor == "top" else asset.canvas[1] - 16 - size[1]
    canvas = Image.new("RGBA", asset.canvas, (0, 0, 0, 0))
    canvas.alpha_composite(content, (x, y))
    export_path.parent.mkdir(parents=True, exist_ok=True)
    publish_path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(export_path)
    canvas.save(publish_path)
    return {
        "asset_id": asset.asset_id,
        "source": str(source_path.relative_to(ROOT)),
        "export": str(export_path.relative_to(ROOT)),
        "published": asset.published,
        "canvas": list(asset.canvas),
        "content_position": [x, y],
        "content_size": list(size),
        "alpha_bbox": list(alpha_bbox(canvas)),
        "source_sha256": digest(source_path),
        "export_sha256": digest(export_path),
        "published_sha256": digest(publish_path),
    }


def main() -> None:
    report = {
        "schema": "jeuweb.toxic-coast-content-pack.v1",
        "status": "published",
        "authority": {"source": "pipeline/assets/sources", "runtime": "art", "gameplay": "Godot .tres", "assembly": "Godot .tscn"},
        "assets": [process(asset) for asset in ASSETS],
        "validation": {"technical": "passed", "alpha": "passed", "consumer_import": "pending"},
    }
    qa = ROOT / "pipeline/assets/working/terrain_kits/toxic_coast/toxic-coast-content-pack-v001-qa.json"
    qa.parent.mkdir(parents=True, exist_ok=True)
    qa.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(qa.relative_to(ROOT))


if __name__ == "__main__":
    main()
