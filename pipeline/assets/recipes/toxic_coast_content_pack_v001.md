# Recette — lot de contenu Côte toxique v001

## Autorités et sens du flux

```text
pipeline/assets/sources
        ↓ process_toxic_coast_content_pack.py
pipeline/assets/exports
        ↓ publication validée
art/ (PNG runtime)
        ↓ références
.tres (définition gameplay)
        ↓ assemblage
.tscn (scène glissable)
```

Les sources et exports ne sont jamais chargés par Godot. Les PNG publiés ne
contiennent ni PV, ni dégâts, ni décision de collision.

## Sources reçues

- bloc bunker militaire ;
- passerelle industrielle ;
- pont-tuyau toxique ;
- bassin acide ;
- baril explosif ;
- caisse militaire fermée.

Toutes les sources sont des PNG RGBA détourés, en vue latérale pure, dans la DA
run-and-gun peinte Côte toxique.

## État ouvert de la caisse

Outil : ImageGen intégré de Codex, mode édition, cible
`military-supply-crate-source-v001.png`.

Prompt final de création :

> Transform this exact closed military supply crate into its clearly open
> state. Raise the full lid upward on rear hinges so the empty dark metal
> interior is visible. The crate is empty: no weapon, no loot, no light beam.
> Preserve the original hand-painted comic run-and-gun style, olive and dark
> steel, rust, magenta paint and lime corrosion. Pure side view, entire object,
> no scenery, shadow, text or watermark, genuinely transparent background.

Une seconde édition `background-extraction` a supprimé le damier peint et créé
un vrai canal alpha, sans modifier l'objet.

## Normalisation reproductible

Exécuter :

```bash
python3 pipeline/assets/tools/process_toxic_coast_content_pack.py
```

- Ground Pieces et bassin : canevas 768 × 384 ;
- baril : canevas 256 × 320, origine au sol `[128, 304]` ;
- caisse fermée/ouverte : canevas commun 384 × 320, origine `[192, 304]` ;
- marges transparentes obligatoires ;
- copies runtime publiées sous `art/` seulement par ce processeur.

## Correspondances Godot

- bunker, passerelle, pont-tuyau → `GroundPieceDefinition` + scène héritée de
  `GroundPiece2D`, mode par instance ;
- bassin → `HazardData` + `DamageHazard2D` ;
- baril → `ExplosivePropData` + `ExplosiveProp2D` + `Explosion2D` ;
- caisse → `SupplyCrateData` + `SupplyCrate2D`, vide en v001.

Validation consommateur : `tests/toxic_coast_content_pack_test.gd`.
