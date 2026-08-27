# Recette foreground Côte toxique v002

## Intention

Remplacer la bordure v001, trop haute et mal raccordée, par un foreground
plein alpha adapté au niveau de 3840 × 720 px : centre jouable dégagé, petites
silhouettes aux bords et répétition discrète.

## Référence

`art/maps/toxic_coast/toxic-coast-foreground-v001.png` sert uniquement de
référence pour palette, encrage et matériaux. Sa composition n'est pas à
préserver.

## Prompt condensé

- overlay de jeu 2D transparent au format 8:3 ;
- jungle militaire toxique peinte, contours noirs, vert acide, métal huileux,
  rouille et accents magenta ;
- couloir central largement transparent ;
- intrusion basse limitée, décor supérieur court, amas hauts réservés aux
  extrémités ;
- masses latérales basses et discontinues afin que la répétition ne forme plus
  de mur vertical ;
- aucun sol jouable, personnage, texte, voile, fond opaque ou watermark.

## Résultat technique

La première sortie reste conservée comme candidate rejetée parce que son damier
était peint dans une image RGB opaque. Une extraction dédiée a ensuite produit
un véritable canal alpha : minimum 0, maximum 0,996, centre jouable quasiment
entièrement transparent.

Candidate rejetée :
`sources/imagegen/toxic_coast/toxic-coast-foreground-readable-v002-opaque-candidate.png`

Source validée :
`sources/imagegen/toxic_coast/toxic-coast-foreground-readable-v002.png`

Export pipeline :
`exports/maps/toxic_coast/toxic-coast-foreground-v002.png`

Livrable Godot :
`art/maps/toxic_coast/toxic-coast-foreground-v002.png`
