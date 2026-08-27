# Recette Côte toxique v001

## Sources imagegen

- panorama lointain 8:3 : ciel acide, océan, forteresse d'artillerie distante,
  sans plateforme de gameplay au premier plan ;
- midground transparent : jungle industrielle et structures militaires ;
- foreground transparent : tuyaux, végétation et débris cadrant les bords ;
- sol maître carré : coupe de matière toxique industrielle répétable.

La source maître du sol est conservée dans
`sources/imagegen/toxic_coast/toxic-soil-master-v001.png`.

## Dérivations runtime

Les cinq textures publiées ont été dérivées avec ImageMagick :

- `toxic-soil-shallow-v001.png` — 512 × 512 ;
- `toxic-soil-main-v001.png` — 512 × 512 ;
- `toxic-soil-deep-v001.png` — 512 × 512 ;
- `toxic-surface-intact-v001.png` — 1024 × 96 ;
- `toxic-surface-fresh-v001.png` — 1024 × 96.

Les livrables publiés sont dans `res://art/terrain/toxic_coast/`. La Resource
Godot `res://terrain/profiles/toxic_coast_terrain.tres` ne connaît que ces
livrables, jamais la source maître.

