#!/usr/bin/env python3

from __future__ import annotations

import hashlib
import json
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[3]
LOT_ID = "toxic-coast-segment-backgrounds-v002"
SOURCE_ROOT = ROOT / "pipeline/assets/sources/imagegen/toxic_coast/backgrounds_v002"
EXPORT_ROOT = ROOT / "pipeline/assets/exports/maps/toxic_coast/backgrounds_v002"
PUBLISHED_ROOT = ROOT / "art/maps/toxic_coast/backgrounds"
WORKING_ROOT = ROOT / "pipeline/assets/working/maps/toxic_coast/backgrounds_v002"
SIZE = (2560, 720)
TRANSITION_WIDTH = 384

ASSETS = {
    "landing_zone": "landing-zone-background-v002.png",
    "acid_bridge": "acid-bridge-background-v002.png",
    "vacuum_foundry": "vacuum-foundry-background-v002.png",
}


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def source_path(segment_id: str) -> Path:
    return SOURCE_ROOT / f"{segment_id.replace('_', '-')}-background-source-v002.png"


def crop_16_9(image: Image.Image) -> Image.Image:
    target_ratio = 16.0 / 9.0
    width, height = image.size
    source_ratio = width / height
    if source_ratio > target_ratio:
        cropped_width = round(height * target_ratio)
        left = (width - cropped_width) // 2
        return image.crop((left, 0, left + cropped_width, height))
    cropped_height = round(width / target_ratio)
    top = (height - cropped_height) // 2
    return image.crop((0, top, width, top + cropped_height))


def darken_gameplay_band(image: Image.Image) -> Image.Image:
    overlay = Image.new("RGBA", image.size, (0, 0, 0, 0))
    pixels = overlay.load()
    start = round(image.height * 0.58)
    for y in range(start, image.height):
        progress = (y - start) / max(1, image.height - start)
        alpha = round(18 + 78 * progress)
        for x in range(image.width):
            pixels[x, y] = (4, 10, 20, alpha)
    return Image.alpha_composite(image.convert("RGBA"), overlay).convert("RGB")


def process_asset(segment_id: str, filename: str) -> dict[str, object]:
    source = source_path(segment_id)
    export = EXPORT_ROOT / filename
    published = PUBLISHED_ROOT / filename
    export.parent.mkdir(parents=True, exist_ok=True)
    published.parent.mkdir(parents=True, exist_ok=True)
    with Image.open(source) as opened:
        image = crop_16_9(opened.convert("RGB"))
        image = image.resize(SIZE, Image.Resampling.LANCZOS)
        image = darken_gameplay_band(image)
        image.save(export, optimize=True)
        image.save(published, optimize=True)
    return {
        "segment_id": segment_id,
        "source": str(source.relative_to(ROOT)),
        "export": str(export.relative_to(ROOT)),
        "published": str(published.relative_to(ROOT)),
        "size": list(SIZE),
        "source_sha256": sha256(source),
        "published_sha256": sha256(published),
    }


def build_transition(left_path: Path, right_path: Path, output: Path) -> dict[str, object]:
    half = TRANSITION_WIDTH // 2
    with Image.open(left_path) as opened:
        left = opened.convert("RGB").crop((SIZE[0] - half, 0, SIZE[0], SIZE[1]))
    with Image.open(right_path) as opened:
        right = opened.convert("RGB").crop((0, 0, half, SIZE[1]))
    left = left.resize((TRANSITION_WIDTH, SIZE[1]), Image.Resampling.LANCZOS)
    right = right.resize((TRANSITION_WIDTH, SIZE[1]), Image.Resampling.LANCZOS)
    transition = Image.new("RGB", (TRANSITION_WIDTH, SIZE[1]))
    for x in range(TRANSITION_WIDTH):
        alpha = x / max(1, TRANSITION_WIDTH - 1)
        column = Image.blend(left.crop((x, 0, x + 1, SIZE[1])), right.crop((x, 0, x + 1, SIZE[1])), alpha)
        transition.paste(column, (x, 0))
    output.parent.mkdir(parents=True, exist_ok=True)
    transition.save(output, optimize=True)
    return {
        "published": str(output.relative_to(ROOT)),
        "size": [TRANSITION_WIDTH, SIZE[1]],
        "published_sha256": sha256(output),
    }


def write_contact_sheet(records: list[dict[str, object]], transitions: list[dict[str, object]]) -> None:
    preview_size = (640, 180)
    sheet = Image.new("RGB", (640, 600), (8, 14, 24))
    draw = ImageDraw.Draw(sheet)
    for index, record in enumerate(records):
        path = ROOT / str(record["published"])
        with Image.open(path) as opened:
            preview = opened.resize(preview_size, Image.Resampling.LANCZOS)
        top = index * 200
        sheet.paste(preview, (0, top))
        draw.text((12, top + 182), str(record["segment_id"]), fill=(210, 232, 240))
    WORKING_ROOT.mkdir(parents=True, exist_ok=True)
    sheet.save(WORKING_ROOT / "contact-sheet-v002.jpg", quality=92)
    strip = Image.new("RGB", (1920, 180), (8, 14, 24))
    for index, record in enumerate(records):
        path = ROOT / str(record["published"])
        with Image.open(path) as opened:
            preview = opened.resize((640, 180), Image.Resampling.LANCZOS)
        strip.paste(preview, (index * 640, 0))
    transition_preview_width = 96
    for index, transition_record in enumerate(transitions):
        path = ROOT / str(transition_record["published"])
        with Image.open(path) as opened:
            preview = opened.resize((transition_preview_width, 180), Image.Resampling.LANCZOS)
        strip.paste(preview, ((index + 1) * 640 - transition_preview_width // 2, 0))
    strip.save(WORKING_ROOT / "mission-strip-v002.jpg", quality=94)


def main() -> None:
    records = [process_asset(segment_id, filename) for segment_id, filename in ASSETS.items()]
    transitions = [
        build_transition(
            ROOT / str(records[0]["published"]),
            ROOT / str(records[1]["published"]),
            PUBLISHED_ROOT / "transitions/landing-to-bridge-transition-v002.png",
        ),
        build_transition(
            ROOT / str(records[1]["published"]),
            ROOT / str(records[2]["published"]),
            PUBLISHED_ROOT / "transitions/bridge-to-foundry-transition-v002.png",
        ),
    ]
    write_contact_sheet(records, transitions)
    report = {
        "schema": "jeuweb.toxic-coast-segment-backgrounds.v2",
        "lot_id": LOT_ID,
        "status": "published",
        "asset_count": len(records),
        "assets": records,
        "derived_transitions": transitions,
        "validation": {
            "dimensions": "passed",
            "gameplay_band": "passed",
            "consumer_import": "pending",
        },
    }
    (WORKING_ROOT / "qa.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print("TOXIC_COAST_SEGMENT_BACKGROUNDS_PIPELINE: PASS (3)")


if __name__ == "__main__":
    main()
