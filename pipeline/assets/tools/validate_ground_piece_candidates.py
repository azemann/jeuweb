#!/usr/bin/env python3
"""Porte technique des candidats Ground Piece Côte toxique."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

from PIL import Image


PROJECT_ROOT = Path(__file__).resolve().parents[3]
EXPORT = PROJECT_ROOT / "pipeline/assets/exports/terrain_kits/toxic_coast/natural/natural-ledge-medium-768x384-v001.png"
QA = PROJECT_ROOT / "pipeline/assets/working/terrain_kits/toxic_coast/natural-ledge-medium-v001-qa.json"
MANIFEST = PROJECT_ROOT / "pipeline/assets/manifests/toxic_coast_ground_kit_v001.json"
PROVENANCE = PROJECT_ROOT / "pipeline/assets/provenance/toxic_coast_ground_kit_v001.json"
EXPECTED_SIZE = (768, 384)
EXPECTED_PIVOT = [384, 64]


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> None:
    assert EXPORT.is_file(), f"Candidate absente: {EXPORT.relative_to(PROJECT_ROOT)}"
    assert QA.is_file(), f"Rapport QA absent: {QA.relative_to(PROJECT_ROOT)}"
    report = json.loads(QA.read_text(encoding="utf-8"))
    image = Image.open(EXPORT)
    assert image.mode == "RGBA", f"Mode {image.mode}; RGBA attendu"
    assert image.size == EXPECTED_SIZE, f"Taille {image.size}; {EXPECTED_SIZE} attendue"
    alpha = image.getchannel("A")
    assert alpha.getextrema() == (0, 255), f"Alpha incomplet: {alpha.getextrema()}"
    assert alpha.getbbox() is not None, "La zone alpha est vide"
    width, height = image.size
    edges = [
        alpha.crop((0, 0, width, 1)),
        alpha.crop((0, height - 1, width, height)),
        alpha.crop((0, 0, 1, height)),
        alpha.crop((width - 1, 0, width, height)),
    ]
    assert all(edge.getextrema()[1] == 0 for edge in edges), "Un bord du canevas contient de l'alpha"
    assert report["pivot_px"] == EXPECTED_PIVOT, f"Pivot inattendu: {report['pivot_px']}"
    assert 0 <= EXPECTED_PIVOT[0] < width and 0 <= EXPECTED_PIVOT[1] < height
    assert report["export_sha256"] == sha256(EXPORT), "Empreinte export incohérente"
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    export_asset = None
    runtime_asset = None
    for asset in manifest["assets"]:
        if asset["path"] == str(EXPORT.relative_to(PROJECT_ROOT)):
            asset["sha256"] = report["export_sha256"]
            export_asset = asset
        if asset["role"] == "godot-runtime-ground-piece":
            runtime_asset = asset
    provenance = json.loads(PROVENANCE.read_text(encoding="utf-8"))
    approval_is_current = (
        manifest["status"] == "integrated"
        and export_asset is not None
        and export_asset["status"] == "validated"
        and runtime_asset is not None
        and runtime_asset["status"] == "integrated"
        and runtime_asset["sha256"] == report["export_sha256"]
        and provenance["validation"]["humanApproval"] == "passed"
    )
    report["validation"]["technical"] = "passed"
    if approval_is_current:
        report["status"] = "integrated"
        report["validation"]["visual"] = "passed"
        report["validation"]["human_approval"] = "passed"
        report["validation"]["consumer_import"] = provenance["validation"]["consumerImport"]
    QA.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    MANIFEST.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    provenance["validation"]["technical"] = "passed"
    PROVENANCE.write_text(json.dumps(provenance, indent=2) + "\n", encoding="utf-8")
    print("GROUND_PIECE_CANDIDATE_VALIDATION: PASS")


if __name__ == "__main__":
    main()
