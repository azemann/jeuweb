#!/usr/bin/env python3

from __future__ import annotations

import hashlib
import json
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[3]
LOT_ID = "industrial-toxic-boot-start-flow-v001"
SOURCE_DIR = ROOT / "pipeline/assets/sources/imagegen/flows/industrial_toxic_boot_start_v001"
WORKING_DIR = ROOT / "pipeline/assets/working/flows/industrial_toxic_boot_start_v001"
EXPORT_DIR = ROOT / "pipeline/assets/exports/ui/flows/industrial_toxic_v001"
RUNTIME_DIR = ROOT / "art/ui/flows/industrial_toxic"
MANIFEST_PATH = ROOT / "pipeline/assets/manifests/industrial_toxic_boot_start_flow_v001.json"
PROVENANCE_PATH = ROOT / "pipeline/assets/provenance/industrial_toxic_boot_start_flow_v001.json"

BACKGROUND_SOURCES = {
    "backgrounds/boot-radio-outpost-background-v001.png": SOURCE_DIR / "boot/backgrounds/boot-radio-outpost-background-source-v001.png",
    "backgrounds/loading-vacuum-turbine-background-v001.png": SOURCE_DIR / "boot/backgrounds/loading-vacuum-turbine-background-source-v001.png",
    "backgrounds/title-fortress-assault-background-v001.png": SOURCE_DIR / "start/backgrounds/title-fortress-assault-background-source-v001.png",
    "backgrounds/mission-select-archipelago-map-v001.png": SOURCE_DIR / "start/backgrounds/mission-select-archipelago-map-source-v001.png",
}

TRANSPARENT_SOURCES = {
    "branding/vacuum-faction-emblem-v001.png": (
        SOURCE_DIR / "shared/branding/vacuum-faction-emblem-source-v001.png",
        (512, 512),
    ),
    "frames/blank-armored-title-plaque-v001.png": (
        SOURCE_DIR / "shared/frames/blank-armored-title-plaque-source-v001.png",
        (768, 256),
    ),
    "frames/vertical-main-menu-frame-v001.png": (
        SOURCE_DIR / "shared/frames/vertical-main-menu-frame-source-v001.png",
        (512, 768),
    ),
}

MENU_ORNAMENTS = [
    ("ornaments/previous-inactive-v001.png", (192, 192)),
    ("ornaments/previous-active-v001.png", (192, 192)),
    ("ornaments/locked-v001.png", (192, 192)),
    ("ornaments/divider-v001.png", (320, 96)),
    ("ornaments/lime-status-lamp-v001.png", (160, 160)),
    ("ornaments/magenta-status-lamp-v001.png", (160, 160)),
]

MISSION_MARKERS = [
    "markers/landing-marker-v001.png",
    "markers/pipeline-marker-v001.png",
    "markers/foundry-marker-v001.png",
    "markers/fortress-marker-v001.png",
    "markers/elite-marker-v001.png",
    "markers/completed-marker-v001.png",
]


def alpha_trim(image: Image.Image, padding: int = 8) -> Image.Image:
    alpha = image.getchannel("A")
    bbox = alpha.point(lambda value: 255 if value >= 8 else 0).getbbox()
    if bbox is None:
        raise ValueError("La zone ne contient aucun pixel visible.")
    trimmed = image.crop(bbox)
    output = Image.new("RGBA", (trimmed.width + padding * 2, trimmed.height + padding * 2))
    output.alpha_composite(trimmed, (padding, padding))
    return output


def fit_transparent(image: Image.Image, size: tuple[int, int]) -> Image.Image:
    trimmed = alpha_trim(image)
    scale = min(size[0] / trimmed.width, size[1] / trimmed.height)
    resized = trimmed.resize(
        (max(1, round(trimmed.width * scale)), max(1, round(trimmed.height * scale))),
        Image.Resampling.LANCZOS,
    )
    output = Image.new("RGBA", size)
    output.alpha_composite(resized, ((size[0] - resized.width) // 2, (size[1] - resized.height) // 2))
    return output


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def publish(image: Image.Image, relative_path: str) -> dict[str, object]:
    export_path = EXPORT_DIR / relative_path
    runtime_path = RUNTIME_DIR / relative_path
    export_path.parent.mkdir(parents=True, exist_ok=True)
    runtime_path.parent.mkdir(parents=True, exist_ok=True)
    image.save(export_path, compress_level=6)
    image.save(runtime_path, compress_level=6)
    return {
        "path": str(Path("art/ui/flows/industrial_toxic") / relative_path),
        "width": image.width,
        "height": image.height,
        "sha256": sha256(runtime_path),
    }


def slice_sheet(path: Path) -> list[Image.Image]:
    sheet = Image.open(path).convert("RGBA")
    cell_width = sheet.width // 3
    cell_height = sheet.height // 2
    return [
        sheet.crop((column * cell_width, row * cell_height, (column + 1) * cell_width, (row + 1) * cell_height))
        for row in range(2)
        for column in range(3)
    ]


def build_contact_sheet(outputs: list[tuple[str, Image.Image]]) -> None:
    columns = 3
    cell_width = 400
    cell_height = 250
    rows = (len(outputs) + columns - 1) // columns
    sheet = Image.new("RGB", (columns * cell_width, rows * cell_height), (20, 22, 20))
    draw = ImageDraw.Draw(sheet)
    for index, (name, image) in enumerate(outputs):
        preview = image.copy()
        preview.thumbnail((370, 205), Image.Resampling.LANCZOS)
        column = index % columns
        row = index // columns
        x = column * cell_width + (cell_width - preview.width) // 2
        y = row * cell_height + 8 + (205 - preview.height) // 2
        sheet.paste(preview, (x, y), preview if preview.mode == "RGBA" else None)
        draw.text((column * cell_width + 12, row * cell_height + 220), name, fill=(235, 226, 191))
    WORKING_DIR.mkdir(parents=True, exist_ok=True)
    sheet.save(WORKING_DIR / "published-contact-sheet-v001.jpg", quality=92)


def main() -> None:
    records: list[dict[str, object]] = []
    previews: list[tuple[str, Image.Image]] = []

    for relative_path, source_path in BACKGROUND_SOURCES.items():
        output = Image.open(source_path).convert("RGB")
        records.append(publish(output, relative_path))
        previews.append((Path(relative_path).name, output))

    for relative_path, (source_path, size) in TRANSPARENT_SOURCES.items():
        output = fit_transparent(Image.open(source_path).convert("RGBA"), size)
        records.append(publish(output, relative_path))
        previews.append((Path(relative_path).name, output))

    menu_sheet = SOURCE_DIR / "shared/sheets/menu-ornaments-sheet-3x2-source-v001.png"
    for (relative_path, size), cell in zip(MENU_ORNAMENTS, slice_sheet(menu_sheet), strict=True):
        output = fit_transparent(cell, size)
        records.append(publish(output, relative_path))
        previews.append((Path(relative_path).name, output))

    marker_sheet = SOURCE_DIR / "shared/sheets/mission-markers-sheet-3x2-source-v001.png"
    for relative_path, cell in zip(MISSION_MARKERS, slice_sheet(marker_sheet), strict=True):
        output = fit_transparent(cell, (192, 192))
        records.append(publish(output, relative_path))
        previews.append((Path(relative_path).name, output))

    build_contact_sheet(previews)
    source_paths = sorted(SOURCE_DIR.rglob("*.png"))
    MANIFEST_PATH.write_text(
        json.dumps(
            {
                "schemaVersion": "1.0.0",
                "lotId": LOT_ID,
                "status": "published",
                "sources": [
                    {
                        "path": str(path.relative_to(ROOT)),
                        "width": Image.open(path).width,
                        "height": Image.open(path).height,
                        "sha256": sha256(path),
                    }
                    for path in source_paths
                ],
                "outputs": records,
                "outputCount": len(records),
            },
            indent=2,
            ensure_ascii=False,
        )
        + "\n",
        encoding="utf-8",
    )
    PROVENANCE_PATH.write_text(
        json.dumps(
            {
                "schemaVersion": "1.0.0",
                "lotId": LOT_ID,
                "origin": "/home/evan/Dev/Dev-github/my-space/projets/jeuweb-boot-start-flow-assets-v001",
                "generator": "OpenAI built-in imagegen",
                "publicationStatus": "published",
                "transformations": [
                    "copie contrôlée des neuf sources candidates",
                    "préservation des quatre arrière-plans opaques",
                    "trim alpha et normalisation des trois éléments transparents autonomes",
                    "découpe déterministe 3x2 des ornements et marqueurs",
                    "normalisation sur canevas transparents stables",
                    "publication versionnée sous art/ui/flows/industrial_toxic",
                ],
            },
            indent=2,
            ensure_ascii=False,
        )
        + "\n",
        encoding="utf-8",
    )
    print(f"BOOT_START_FLOW_PIPELINE: PASS outputs={len(records)}")


if __name__ == "__main__":
    main()
