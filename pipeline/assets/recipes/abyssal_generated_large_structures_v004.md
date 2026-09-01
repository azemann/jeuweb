# Abyssal Generated Large Structures v004

## Objectif

Remplacer le lot v003 extrait de DA-08 par de vrais sprites de grands sols
générés pour le gameplay. Chaque pièce doit posséder une seule hauteur de sol
lisible, un fond transparent et un bord de marche clair.

## Erreur corrigée

La v003 a été refusée : elle découpait la rangée basse d'une planche de DA, qui
fonctionne comme ambiance mais pas comme sprite gameplay. Certaines pièces
montraient deux hauteurs de sol ou des plans décoratifs trop proches du bord
marchable.

## Source

ImageGen intégré, génération dédiée d'un grand module horizontal abyssal :
corail noir, nacre, cuivre oxydé, machines de marée et énergie cyan.

Source conservée :

`pipeline/assets/sources/terrain_kits/abyssal/generated_large_structures/abyssal-large-ground-structures-source-v004.png`

## Pipeline

Le script `pipeline/assets/tools/process_abyssal_generated_large_structures.py`
publie cinq fenêtres larges du module généré :

- `generated-coral-machine-slab-v004.png`
- `generated-tide-engine-floor-v004.png`
- `generated-black-coral-slab-v004.png`
- `generated-ruin-engine-slab-v004.png`
- `generated-right-coral-engine-slab-v004.png`

Chaque sortie est normalisée sur un canevas `1024 x 320`, avec pivot
`[512, 82]` et surface de marche simple portée par `GroundPieceDefinition`.

## Règle pour les prochains lots

Une planche de DA peut inspirer un lot, mais un sol jouable doit être généré ou
dessiné comme sprite de terrain. Le critère de refus immédiat est : deux
hauteurs de sol visibles dans une seule pièce sans intention de level design
explicite.
