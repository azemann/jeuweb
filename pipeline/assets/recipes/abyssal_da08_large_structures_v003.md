# Abyssal DA-08 Large Structures v003

## Intention

Extraire les grands socles de sol visibles dans la rangée basse de DA-08. Ces
pièces portent le level design principal de Mission 2 ; les petits modules v002
servent plutôt aux raccords, caps, marches et supports.

## Référence de méthode

La recherche externe confirme trois règles utiles :

- Unity décrit un flux `Sprite -> Tile -> Palette -> Brush -> Tilemap`, où
  l'art devient d'abord une palette éditable avant d'être peint dans le niveau ;
- Godot 4 met l'accent sur `TileSet`, couches `TileMap`, terrains et placement
  de scènes depuis l'éditeur ;
- les workflows de kits modulaires recommandent de verrouiller module, pivot
  et pièces proxy/finales pour éviter de reconstruire le niveau pendant l'art
  pass.

Dans ce projet, l'équivalent reste :

```text
DA-08 source -> pipeline -> PNG runtime -> GroundPieceDefinition -> scène glissable -> Mission 2
```

## Sorties

- `da08-massive-coral-machine-slab-v003.png`
- `da08-broken-machine-floor-v003.png`
- `da08-rotor-slope-floor-v003.png`
- `da08-tide-bridge-foundation-v003.png`
- `da08-right-engine-slab-v003.png`

Chaque sortie est normalisée sur canevas 1024 x 320 avec pivot de marche et
contour auteur définis côté `GroundPieceDefinition`.
