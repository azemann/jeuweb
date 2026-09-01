#!/usr/bin/env python3
from collections import deque
from pathlib import Path
import json

from PIL import Image


ROOT = Path(__file__).resolve().parents[3]
SOURCE_DIR = ROOT / "pipeline/assets/sources/imagegen/effects/explosions/barrel_v001"
EXPORT_DIR = ROOT / "pipeline/assets/exports/effects/explosions/barrel_v001"
WORKING_DIR = ROOT / "pipeline/assets/working/effects/explosions/barrel_v001"
ART_DIR = ROOT / "art/effects/explosions/barrel"
CELL_SOURCE = (384, 512)
CELL_EXPORT = (288, 384)
VARIANTS = ("small", "standard", "heavy")


def is_checker_pixel(pixel: tuple[int, int, int]) -> bool:
    return min(pixel) >= 225 and max(pixel) - min(pixel) <= 18


def remove_connected_checker(image: Image.Image) -> Image.Image:
    rgb = image.convert("RGB")
    width, height = rgb.size
    pixels = rgb.load()
    background = bytearray(width * height)
    queue: deque[tuple[int, int]] = deque()

    def enqueue(x: int, y: int) -> None:
        index = y * width + x
        if background[index] or not is_checker_pixel(pixels[x, y]):
            return
        background[index] = 1
        queue.append((x, y))

    for x in range(width):
        enqueue(x, 0)
        enqueue(x, height - 1)
    for y in range(height):
        enqueue(0, y)
        enqueue(width - 1, y)

    while queue:
        x, y = queue.popleft()
        if x > 0:
            enqueue(x - 1, y)
        if x + 1 < width:
            enqueue(x + 1, y)
        if y > 0:
            enqueue(x, y - 1)
        if y + 1 < height:
            enqueue(x, y + 1)

    rgba = rgb.convert("RGBA")
    alpha = Image.new("L", (width, height), 255)
    alpha.putdata([0 if value else 255 for value in background])
    rgba.putalpha(alpha)
    return rgba


def normalized_sheet(source: Path) -> Image.Image:
    image = Image.open(source)
    if image.size != (CELL_SOURCE[0] * 4, CELL_SOURCE[1] * 2):
        raise ValueError(f"Unexpected source dimensions: {image.size}")
    if image.mode != "RGBA" or image.getextrema()[3][0] == image.getextrema()[3][1]:
        image = remove_connected_checker(image)
    else:
        image = image.convert("RGBA")

    sheet = Image.new("RGBA", (CELL_EXPORT[0] * 4, CELL_EXPORT[1] * 2))
    for frame_index in range(8):
        source_x = frame_index % 4 * CELL_SOURCE[0]
        source_y = frame_index // 4 * CELL_SOURCE[1]
        frame = image.crop((source_x, source_y, source_x + CELL_SOURCE[0], source_y + CELL_SOURCE[1]))
        frame = frame.resize(CELL_EXPORT, Image.Resampling.LANCZOS)
        alpha = frame.getchannel("A").point(lambda value: 0 if value <= 4 else value)
        frame.putalpha(alpha)
        target_x = frame_index % 4 * CELL_EXPORT[0]
        target_y = frame_index // 4 * CELL_EXPORT[1]
        sheet.alpha_composite(frame, (target_x, target_y))
    return sheet


def main() -> None:
    EXPORT_DIR.mkdir(parents=True, exist_ok=True)
    WORKING_DIR.mkdir(parents=True, exist_ok=True)
    ART_DIR.mkdir(parents=True, exist_ok=True)
    report = {"schemaVersion": "1.0.0", "frames": 8, "cell": list(CELL_EXPORT), "variants": {}}
    for variant in VARIANTS:
        source = SOURCE_DIR / f"barrel-{variant}-explosion-4x2-source-v001.png"
        sheet = normalized_sheet(source)
        export = EXPORT_DIR / f"barrel-{variant}-explosion-4x2-v001.png"
        runtime = ART_DIR / export.name
        sheet.save(export, optimize=True)
        sheet.save(runtime, optimize=True)
        alpha = sheet.getchannel("A")
        occupied_frames = 0
        for frame_index in range(8):
            x = frame_index % 4 * CELL_EXPORT[0]
            y = frame_index // 4 * CELL_EXPORT[1]
            if alpha.crop((x, y, x + CELL_EXPORT[0], y + CELL_EXPORT[1])).getbbox() is not None:
                occupied_frames += 1
        report["variants"][variant] = {
            "source": str(source.relative_to(ROOT)),
            "export": str(export.relative_to(ROOT)),
            "runtime": str(runtime.relative_to(ROOT)),
            "size": list(sheet.size),
            "occupiedFrames": occupied_frames,
            "transparentCorners": all(alpha.getpixel(point) == 0 for point in ((0, 0), (sheet.width - 1, 0), (0, sheet.height - 1), (sheet.width - 1, sheet.height - 1))),
        }
    (WORKING_DIR / "barrel-explosion-family-v001-qa.json").write_text(
        json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )


if __name__ == "__main__":
    main()
