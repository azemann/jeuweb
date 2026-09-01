# Recette — famille d'explosions de barils v001

## Intention

Publier trois signatures immédiatement reconnaissables pour les petits,
standards et gros contenants explosifs. La progression porte à la fois sur la
puissance gameplay et sur la densité VFX : flash, feu, double onde, débris,
étincelles, projections toxiques et fumée persistante.

## Autorités

- ImageGen produit les trois sources artistiques 4 × 2 ;
- ce pipeline retire le damier incorporé des variantes éditées, normalise les
  cellules et publie les atlas ;
- `ExplosionData` possède les valeurs gameplay et la signature VFX ;
- `Explosion2D` possède l'assemblage et le timing ;
- `ExplosivePropData` choisit le profil sans recopier sa puissance.

## Prompt directeur

Planche stricte 4 × 2 de huit phases chronologiques d'une explosion de baril
toxique : ignition, flash, boule de feu, onde, maximum, effondrement, fumée et
dissipation. Style run-and-gun peint, olive, vert acide, orange et magenta,
centre et ancrage sol identiques, aucune grille, texte, scène ou baril.

Les variantes petite et lourde conservent cette composition. La petite réduit
rayon, fragments et persistance ; la lourde amplifie double onde, masse de feu,
fumée, débris et projections chimiques.

## Reproduction

```bash
python3 pipeline/assets/tools/process_barrel_explosion_family.py
```

Sortie : atlas 1152 × 768, huit cellules 288 × 384, alpha réel et huit cellules
occupées pour chaque variante.
