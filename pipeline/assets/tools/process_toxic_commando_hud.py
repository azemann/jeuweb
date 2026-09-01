#!/usr/bin/env python3

from __future__ import annotations

import hashlib
import json
from collections import deque
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[3]
SOURCE_DIR = ROOT / "pipeline/assets/sources/ui/hud/toxic_commando_v001"
WORKING_DIR = ROOT / "pipeline/assets/working/ui/hud/toxic_commando_v001"
EXPORT_DIR = ROOT / "pipeline/assets/exports/ui/hud/toxic_commando_v001"
RUNTIME_DIR = ROOT / "art/ui/hud/toxic_commando"
MANIFEST_PATH = ROOT / "pipeline/assets/manifests/toxic_commando_hud_v001.json"
PROVENANCE_PATH = ROOT / "pipeline/assets/provenance/toxic_commando_hud_v001.json"
PLAYER_PORTRAIT_SOURCE = ROOT / "pipeline/assets/working/player/body-canonical-384/00-idle.png"

FRAME_REGIONS = {
    "player-status-frame-v001.png": ((0, 0, 1020, 350), 640),
    "weapon-status-frame-v001.png": ((1000, 0, 1536, 350), 384),
    "objective-frame-v001.png": ((280, 295, 1260, 585), 640),
    "boss-health-frame-v001.png": ((0, 535, 1536, 830), 1024),
    "overdrive-frame-v001.png": ((0, 770, 950, 1024), 640),
    "notification-frame-v001.png": ((930, 770, 1536, 1024), 384),
}

ICON_NAMES = [
    "health-icon-v001.png",
    "armor-icon-v001.png",
    "ammo-icon-v001.png",
    "overdrive-icon-v001.png",
    "grenade-icon-v001.png",
    "objective-icon-v001.png",
    "boss-icon-v001.png",
    "checkpoint-icon-v001.png",
    "weapon-icon-v001.png",
    "poison-icon-v001.png",
    "electric-icon-v001.png",
    "fire-icon-v001.png",
]


def alpha_trim(image: Image.Image, padding: int = 8) -> Image.Image:
    alpha = image.getchannel("A")
    mask = alpha.point(lambda value: 255 if value >= 8 else 0)
    bbox = mask.getbbox()
    if bbox is None:
        raise ValueError("La zone ne contient aucun pixel visible.")
    trimmed = image.crop(bbox)
    output = Image.new("RGBA", (trimmed.width + padding * 2, trimmed.height + padding * 2))
    output.alpha_composite(trimmed, (padding, padding))
    return output


def isolate_primary_component(image: Image.Image, threshold: int = 16) -> Image.Image:
    alpha = image.getchannel("A")
    width, height = image.size
    pixels = alpha.load()
    visited = bytearray(width * height)
    largest: list[tuple[int, int]] = []
    for y in range(height):
        for x in range(width):
            index = y * width + x
            if visited[index] or pixels[x, y] < threshold:
                continue
            visited[index] = 1
            queue = deque([(x, y)])
            component: list[tuple[int, int]] = []
            while queue:
                current_x, current_y = queue.popleft()
                component.append((current_x, current_y))
                for next_x, next_y in (
                    (current_x - 1, current_y),
                    (current_x + 1, current_y),
                    (current_x, current_y - 1),
                    (current_x, current_y + 1),
                ):
                    if next_x < 0 or next_y < 0 or next_x >= width or next_y >= height:
                        continue
                    next_index = next_y * width + next_x
                    if visited[next_index] or pixels[next_x, next_y] < threshold:
                        continue
                    visited[next_index] = 1
                    queue.append((next_x, next_y))
            if len(component) > len(largest):
                largest = component
    if not largest:
        raise ValueError("La zone ne contient aucun composant alpha principal.")
    keep = Image.new("L", image.size)
    keep_pixels = keep.load()
    for x, y in largest:
        keep_pixels[x, y] = 255
    keep = keep.filter(ImageFilter.MaxFilter(15))
    isolated = image.copy()
    isolated.putalpha(Image.composite(alpha, Image.new("L", image.size), keep))
    return isolated


def resize_to_width(image: Image.Image, width: int) -> Image.Image:
    height = max(1, round(image.height * width / image.width))
    return image.resize((width, height), Image.Resampling.LANCZOS)


def normalize_icon(image: Image.Image, size: int = 160) -> Image.Image:
    trimmed = alpha_trim(isolate_primary_component(image), 4)
    scale = min((size - 8) / trimmed.width, (size - 8) / trimmed.height)
    resized = trimmed.resize(
        (max(1, round(trimmed.width * scale)), max(1, round(trimmed.height * scale))),
        Image.Resampling.LANCZOS,
    )
    output = Image.new("RGBA", (size, size))
    output.alpha_composite(resized, ((size - resized.width) // 2, (size - resized.height) // 2))
    return output


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    digest.update(path.read_bytes())
    return digest.hexdigest()


def publish(image: Image.Image, relative_path: Path) -> dict[str, object]:
    export_path = EXPORT_DIR / relative_path
    runtime_path = RUNTIME_DIR / relative_path
    export_path.parent.mkdir(parents=True, exist_ok=True)
    runtime_path.parent.mkdir(parents=True, exist_ok=True)
    image.save(export_path, optimize=True)
    image.save(runtime_path, optimize=True)
    return {
        "path": str(Path("art/ui/hud/toxic_commando") / relative_path),
        "width": image.width,
        "height": image.height,
        "sha256": sha256(runtime_path),
    }


def build_contact_sheet(outputs: list[tuple[str, Image.Image]]) -> None:
    thumb_size = (320, 190)
    columns = 3
    rows = (len(outputs) + columns - 1) // columns
    sheet = Image.new("RGB", (columns * thumb_size[0], rows * 230), (18, 20, 22))
    draw = ImageDraw.Draw(sheet)
    for index, (name, image) in enumerate(outputs):
        column = index % columns
        row = index // columns
        preview = image.copy()
        preview.thumbnail((300, 174), Image.Resampling.LANCZOS)
        x = column * thumb_size[0] + (thumb_size[0] - preview.width) // 2
        y = row * 230 + 4 + (174 - preview.height) // 2
        sheet.paste(preview, (x, y), preview)
        draw.text((column * thumb_size[0] + 10, row * 230 + 186), name, fill=(230, 224, 196))
    WORKING_DIR.mkdir(parents=True, exist_ok=True)
    sheet.save(WORKING_DIR / "toxic-commando-hud-contact-sheet-v001.jpg", quality=92)


def main() -> None:
    frame_sheet = Image.open(SOURCE_DIR / "hud-frames-source-v001.png").convert("RGBA")
    icon_sheet = Image.open(SOURCE_DIR / "gameplay-icons-source-v001.png").convert("RGBA")
    records: list[dict[str, object]] = []
    previews: list[tuple[str, Image.Image]] = []

    for filename, (region, target_width) in FRAME_REGIONS.items():
        isolated = isolate_primary_component(frame_sheet.crop(region))
        output = resize_to_width(alpha_trim(isolated), target_width)
        records.append(publish(output, Path("frames") / filename))
        previews.append((filename, output))

    cell_width = icon_sheet.width // 4
    row_edges = [0, 341, 682, icon_sheet.height]
    for index, filename in enumerate(ICON_NAMES):
        column = index % 4
        row = index // 4
        region = (
            column * cell_width,
            row_edges[row],
            (column + 1) * cell_width,
            row_edges[row + 1],
        )
        output = normalize_icon(icon_sheet.crop(region))
        records.append(publish(output, Path("icons") / filename))
        previews.append((filename, output))

    portrait_source = Image.open(PLAYER_PORTRAIT_SOURCE).convert("RGBA")
    portrait_crop = portrait_source.crop((62, 20, 326, 250))
    portrait = normalize_icon(portrait_crop, 192)
    records.append(publish(portrait, Path("portraits/player-portrait-v001.png")))
    previews.append(("player-portrait-v001.png", portrait))

    build_contact_sheet(previews)
    source_records = [
        {
            "path": str(path.relative_to(ROOT)),
            "sha256": sha256(path),
            "width": Image.open(path).width,
            "height": Image.open(path).height,
        }
        for path in sorted(SOURCE_DIR.glob("*.png"))
    ]
    source_records.append(
        {
            "path": str(PLAYER_PORTRAIT_SOURCE.relative_to(ROOT)),
            "sha256": sha256(PLAYER_PORTRAIT_SOURCE),
            "width": Image.open(PLAYER_PORTRAIT_SOURCE).width,
            "height": Image.open(PLAYER_PORTRAIT_SOURCE).height,
            "role": "dérivé canonique joueur utilisé pour le portrait HUD",
        }
    )
    MANIFEST_PATH.parent.mkdir(parents=True, exist_ok=True)
    MANIFEST_PATH.write_text(
        json.dumps(
            {
                "lot": "toxic-commando-hud-v001",
                "sources": source_records,
                "outputs": records,
                "output_count": len(records),
                "status": "published",
            },
            indent=2,
            ensure_ascii=False,
        )
        + "\n",
        encoding="utf-8",
    )
    PROVENANCE_PATH.parent.mkdir(parents=True, exist_ok=True)
    PROVENANCE_PATH.write_text(
        json.dumps(
            {
                "lot": "toxic-commando-hud-v001",
                "origin": "/home/evan/Dev/Dev-github/my-space/projets/jeuweb-hud-asset-themes-v001",
                "selected_theme": "toxic_commando",
                "transformations": [
                    "copie immuable des trois planches sources",
                    "découpe déterministe par régions",
                    "trim alpha à seuil 8",
                    "normalisation des icônes sur canevas 160x160",
                    "portrait 192x192 dérivé de la pose idle canonique du joueur",
                    "redimensionnement Lanczos des cadres",
                    "publication versionnée sous art/ui/hud/toxic_commando",
                ],
            },
            indent=2,
            ensure_ascii=False,
        )
        + "\n",
        encoding="utf-8",
    )
    print(f"TOXIC_COMMANDO_HUD_PIPELINE: PASS outputs={len(records)}")


if __name__ == "__main__":
    main()
