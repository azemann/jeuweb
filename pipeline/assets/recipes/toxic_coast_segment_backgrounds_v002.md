# Recette des backgrounds segmentés Côte toxique v002

## Intention

Remplacer le panorama unique répété par trois identités visuelles alignées sur
les actes auteurs de 2560 px : débarquement côtier, ravin du pont acide et
fonderie aspirante. Aucun panorama ne porte de plateforme de gameplay, de texte
ou de personnage.

## Sources et prompts

Les trois sources ont été générées avec l'outil ImageGen intégré le 2026-08-30,
en style concept peint 2D militaire toxique. Les prompts complets imposent une
vue latérale 16:9, des silhouettes lisibles, une palette navy/lime/cyan/orange
avec accents magenta et une partie basse réservée au gameplay.

- `landing_zone` : côte acide occupée, radar, tours et flotte aspirante ;
- `acid_bridge` : gorge industrielle, pont rompu, conduites et cascades acides ;
- `vacuum_foundry` : réacteur d'implosion, turbines et fours monumentaux.

## Transformation déterministe

`process_toxic_coast_segment_backgrounds.py` centre chaque source sur un cadrage
16:9, redimensionne en 2560 × 720 avec Lanczos et applique un dégradé sombre
reproductible sous 58 % de hauteur pour préserver les silhouettes jouables.
Deux bandes dérivées de 384 × 720 croisent les bords adjacents et sont placées
sur les frontières de segments pour éviter une coupe visuelle brutale.

```bash
python3 pipeline/assets/tools/process_toxic_coast_segment_backgrounds.py
```

Les sources restent sous `pipeline/`; seules les trois copies publiées sous
`art/maps/toxic_coast/backgrounds/` sont référencées par Godot.
