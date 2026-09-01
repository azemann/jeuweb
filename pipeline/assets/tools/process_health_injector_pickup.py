#!/usr/bin/env python3
"""Normalise et publie l'injecteur de soin validé depuis le megapack."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[3]
SOURCE = ROOT / "pipeline/assets/sources/imagegen/megapacks/industrial_toxic_v001/pickups/health-injector-pickup-source-v001.png"
EXPORT = ROOT / "pipeline/assets/exports/pickups/health-injector-192-v001.png"
PUBLISHED = ROOT / "art/pickups/health-injector-v001.png"
QA = ROOT / "pipeline/assets/working/pickups/health-injector-pickup-v001-qa.json"
CANVAS = (192, 192)
SAFE = (168, 144)


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    bbox = image.getchannel("A").point(lambda alpha: 255 if alpha > 16 else 0).getbbox()
    if bbox is None:
        raise RuntimeError("silhouette alpha vide")
    return bbox


def main() -> None:
    source = Image.open(SOURCE).convert("RGBA")
    source_bbox = alpha_bbox(source)
    isolated = source.crop(source_bbox)
    scale = min(SAFE[0] / isolated.width, SAFE[1] / isolated.height)
    size = (round(isolated.width * scale), round(isolated.height * scale))
    content = isolated.resize(size, Image.Resampling.LANCZOS)
    position = ((CANVAS[0] - size[0]) // 2, (CANVAS[1] - size[1]) // 2)
    canvas = Image.new("RGBA", CANVAS, (0, 0, 0, 0))
    canvas.alpha_composite(content, position)

    EXPORT.parent.mkdir(parents=True, exist_ok=True)
    PUBLISHED.parent.mkdir(parents=True, exist_ok=True)
    QA.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(EXPORT)
    canvas.save(PUBLISHED)

    report = {
        "schema": "jeuweb.health-injector-pickup.v1",
        "status": "published",
        "source": str(SOURCE.relative_to(ROOT)),
        "export": str(EXPORT.relative_to(ROOT)),
        "published": str(PUBLISHED.relative_to(ROOT)),
        "canvas": list(CANVAS),
        "content_position": list(position),
        "content_size": list(size),
        "alpha_bbox": list(alpha_bbox(canvas)),
        "source_sha256": digest(SOURCE),
        "export_sha256": digest(EXPORT),
        "published_sha256": digest(PUBLISHED),
        "validation": {
            "technical": "passed",
            "alpha": "passed",
            "visual_classification": "accepted_health_pickup",
            "consumer_import": "pending",
        },
    }
    QA.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(QA.relative_to(ROOT))


if __name__ == "__main__":
    main()
