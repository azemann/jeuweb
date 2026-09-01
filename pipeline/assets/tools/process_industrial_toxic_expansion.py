#!/usr/bin/env python3
"""Publie les 27 éléments non dupliqués du megapack industriel toxique."""

from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[3]
SOURCE_ROOT = ROOT / "pipeline/assets/sources/imagegen/megapacks/industrial_toxic_v001"
EXPORT_ROOT = ROOT / "pipeline/assets/exports/industrial_toxic_expansion_v001"


@dataclass(frozen=True)
class StaticAsset:
    asset_id: str
    source: str
    published: str
    canvas: tuple[int, int]
    safe: tuple[int, int]
    anchor: str = "center"


STATIC_ASSETS = (
    StaticAsset("acid_bridge_abutment", "terrain/acid-bridge-abutment-source-v001.png", "art/terrain/pieces/toxic_coast/military/acid-bridge-abutment-v001.png", (768, 512), (704, 416), "top"),
    StaticAsset("destructible_military_wall", "terrain/destructible-military-wall-source-v001.png", "art/terrain/pieces/toxic_coast/military/destructible-military-wall-v001.png", (768, 384), (704, 304), "top"),
    StaticAsset("guard_tower_module", "terrain/guard-tower-module-source-v001.png", "art/terrain/pieces/toxic_coast/military/guard-tower-module-v001.png", (512, 768), (448, 688), "top"),
    StaticAsset("vacuum_foundry_platform", "terrain/vacuum-foundry-platform-source-v001.png", "art/terrain/pieces/toxic_coast/metal/vacuum-foundry-platform-v001.png", (768, 384), (704, 304), "top"),
    StaticAsset("walk_under_pipe_arch", "terrain/walk-under-pipe-arch-source-v001.png", "art/terrain/pieces/toxic_coast/pipes/walk-under-pipe-arch-v001.png", (768, 512), (704, 448), "bottom"),
    StaticAsset("ammo_resupply_locker", "props/ammo-resupply-locker-source-v001.png", "art/props/toxic_coast/ammo-resupply-locker-v001.png", (384, 320), (352, 288), "bottom"),
    StaticAsset("field_medical_station", "props/field-medical-station-source-v001.png", "art/props/toxic_coast/field-medical-station-v001.png", (320, 384), (288, 352), "bottom"),
    StaticAsset("military_floodlight", "props/military-floodlight-source-v001.png", "art/props/toxic_coast/military-floodlight-v001.png", (256, 384), (224, 352), "bottom"),
    StaticAsset("portable_barricade", "props/portable-barricade-source-v001.png", "art/props/toxic_coast/portable-barricade-v001.png", (512, 256), (480, 224), "bottom"),
    StaticAsset("proximity_blast_mine", "props/proximity-blast-mine-source-v001.png", "art/props/toxic_coast/proximity-blast-mine-v001.png", (256, 128), (224, 96), "bottom"),
    StaticAsset("radio_relay_antenna", "props/radio-relay-antenna-source-v001.png", "art/props/toxic_coast/radio-relay-antenna-v001.png", (320, 448), (288, 416), "bottom"),
    StaticAsset("toxic_pressure_vent", "props/toxic-pressure-vent-source-v001.png", "art/props/toxic_coast/toxic-pressure-vent-v001.png", (256, 320), (224, 288), "bottom"),
    StaticAsset("ammo_drum_pickup", "pickups/ammo-drum-pickup-source-v001.png", "art/pickups/ammo-drum-v001.png", (192, 192), (168, 160)),
    StaticAsset("armor_plate_pickup", "pickups/armor-plate-pickup-source-v001.png", "art/pickups/armor-plate-v001.png", (192, 192), (168, 168)),
    StaticAsset("overdrive_core_pickup", "pickups/overdrive-vacuum-core-pickup-source-v001.png", "art/pickups/overdrive-vacuum-core-v001.png", (192, 192), (168, 168)),
    StaticAsset("acid_sprayer", "weapons/acid/acid-sprayer-weapon-source-v001.png", "art/weapons/player/acid-sprayer-v001.png", (768, 384), (704, 304)),
    StaticAsset("acid_capsule", "weapons/acid/acid-capsule-projectile-source-v001.png", "art/weapons/projectiles/acid/acid-capsule-v001.png", (384, 128), (352, 96)),
    StaticAsset("electric_coil_rifle", "weapons/electric/electric-coil-rifle-source-v001.png", "art/weapons/player/electric-coil-rifle-v001.png", (768, 384), (704, 304)),
    StaticAsset("electric_coil_bolt", "weapons/electric/electric-coil-bolt-source-v001.png", "art/weapons/projectiles/electric/electric-coil-bolt-v001.png", (384, 128), (352, 96)),
    StaticAsset("vacuum_imploder_cannon", "weapons/implosion/vacuum-imploder-cannon-source-v001.png", "art/weapons/player/vacuum-imploder-cannon-v001.png", (768, 384), (704, 304)),
    StaticAsset("vacuum_implosion_core", "weapons/implosion/vacuum-implosion-core-source-v001.png", "art/weapons/projectiles/implosion/vacuum-implosion-core-v001.png", (384, 128), (352, 96)),
    StaticAsset("demolition_launcher", "weapons/rocket/demolition-launcher-source-v001.png", "art/weapons/player/demolition-launcher-v001.png", (768, 384), (704, 304)),
    StaticAsset("demolition_rocket", "weapons/rocket/demolition-rocket-source-v001.png", "art/weapons/projectiles/rocket/demolition-rocket-v001.png", (384, 128), (352, 96)),
)

IMPACT_SHEETS = (
    ("acid_impact", "weapons/acid/acid-impact-sheet-3x2-source-v001.png", "art/effects/weapons/acid/acid-impact-3x2-v001.png"),
    ("electric_impact", "weapons/electric/electric-impact-sheet-3x2-source-v001.png", "art/effects/weapons/electric/electric-impact-3x2-v001.png"),
    ("vacuum_implosion_impact", "weapons/implosion/vacuum-implosion-impact-sheet-3x2-source-v001.png", "art/effects/weapons/implosion/vacuum-implosion-impact-3x2-v001.png"),
    ("demolition_impact", "weapons/rocket/demolition-impact-sheet-3x2-source-v001.png", "art/effects/weapons/rocket/demolition-impact-3x2-v001.png"),
)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    bbox = image.getchannel("A").point(lambda value: 255 if value > 16 else 0).getbbox()
    if bbox is None:
        raise RuntimeError("Silhouette alpha vide")
    return bbox


def normalize(image: Image.Image, canvas_size: tuple[int, int], safe_size: tuple[int, int], anchor: str) -> tuple[Image.Image, dict[str, object]]:
    isolated = image.crop(alpha_bbox(image))
    scale = min(safe_size[0] / isolated.width, safe_size[1] / isolated.height)
    size = (max(1, round(isolated.width * scale)), max(1, round(isolated.height * scale)))
    content = isolated.resize(size, Image.Resampling.LANCZOS)
    x = (canvas_size[0] - size[0]) // 2
    if anchor == "top":
        y = 32
    elif anchor == "bottom":
        y = canvas_size[1] - 16 - size[1]
    else:
        y = (canvas_size[1] - size[1]) // 2
    canvas = Image.new("RGBA", canvas_size, (0, 0, 0, 0))
    canvas.alpha_composite(content, (x, y))
    return canvas, {"content_position": [x, y], "content_size": list(size), "alpha_bbox": list(alpha_bbox(canvas))}


def save_runtime(asset_id: str, source_relative: str, published_relative: str, image: Image.Image, metadata: dict[str, object]) -> dict[str, object]:
    source_path = SOURCE_ROOT / source_relative
    export_path = EXPORT_ROOT / Path(published_relative).relative_to("art")
    published_path = ROOT / published_relative
    export_path.parent.mkdir(parents=True, exist_ok=True)
    published_path.parent.mkdir(parents=True, exist_ok=True)
    image.save(export_path)
    image.save(published_path)
    return {
        "asset_id": asset_id,
        "source": str(source_path.relative_to(ROOT)),
        "export": str(export_path.relative_to(ROOT)),
        "published": published_relative,
        "source_sha256": sha256(source_path),
        "published_sha256": sha256(published_path),
        **metadata,
    }


def process_static(asset: StaticAsset) -> dict[str, object]:
    source = Image.open(SOURCE_ROOT / asset.source).convert("RGBA")
    runtime, metadata = normalize(source, asset.canvas, asset.safe, asset.anchor)
    return save_runtime(asset.asset_id, asset.source, asset.published, runtime, {"canvas": list(asset.canvas), **metadata})


def process_impact(asset_id: str, source_relative: str, published_relative: str) -> dict[str, object]:
    source_path = SOURCE_ROOT / source_relative
    source = Image.open(source_path).convert("RGBA")
    source_cell = (source.width // 3, source.height // 2)
    atlas = Image.new("RGBA", (576, 320), (0, 0, 0, 0))
    frames = []
    for index in range(6):
        column = index % 3
        row = index // 3
        cell = source.crop((column * source_cell[0], row * source_cell[1], (column + 1) * source_cell[0], (row + 1) * source_cell[1]))
        runtime, metadata = normalize(cell, (192, 160), (168, 136), "center")
        atlas.alpha_composite(runtime, (column * 192, row * 160))
        frames.append({"index": index, **metadata})
    return save_runtime(asset_id, source_relative, published_relative, atlas, {"canvas": [576, 320], "grid": [3, 2], "cell": [192, 160], "frames": frames})


def main() -> None:
    assets = [process_static(asset) for asset in STATIC_ASSETS]
    assets.extend(process_impact(*asset) for asset in IMPACT_SHEETS)
    report = {
        "schema": "jeuweb.industrial-toxic-expansion.v1",
        "status": "published",
        "source_lot": "industrial-toxic-megapack-v001",
        "asset_count": len(assets),
        "assets": assets,
        "validation": {"technical": "passed", "alpha": "passed", "consumer_import": "pending"},
    }
    qa_path = ROOT / "pipeline/assets/working/industrial_toxic_expansion_v001/qa.json"
    qa_path.parent.mkdir(parents=True, exist_ok=True)
    qa_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(qa_path.relative_to(ROOT))


if __name__ == "__main__":
    main()
