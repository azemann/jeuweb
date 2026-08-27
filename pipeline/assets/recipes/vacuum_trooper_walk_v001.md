# Recette Vacuum Trooper — marche v001

## Filiation

- identité : planches `da-06-enemies-vacuum-divers` et
  `da-07-enemy-pilot-lifecycle` ;
- mouvement : cycle teal 2,5D de `arene`, huit poses de 160 ms ;
- contrat : `myspace-animation-v1`, frames sur canevas fixe et pivot entre les
  appuis ;
- consommateur prévu : `AnimatedSprite2D` et `SpriteFrames` Godot, déplacement
  appartenant au moteur.

Le fighter teal sert uniquement de référence temporelle et biomécanique. Son
identité humaine, ses vêtements et sa représentation ne sont jamais copiés.

## Cycle demandé

La planche source comporte exactement huit poses, grille 4 × 2, toutes orientées
vers la droite :

1. contact A ;
2. compression A ;
3. passage A ;
4. montée A ;
5. contact B ;
6. compression B ;
7. passage B ;
8. montée B.

Les quatre pattes alternent ; la coque oscille légèrement et la trompe suit avec
retard. Coque, hublot, pilote et réservoir restent identiques.

## Prompt final de génération

Outil ImageGen intégré, références locales explicites :

> Create one exact 8-pose walk-cycle spritesheet for the project-owned Vacuum
> Trooper shown in the two concept references. Compact four-legged vacuum-diver
> machine, worn brass and olive shell, small purple alien pilot, short flexible
> trunk, pink porthole and magenta tank, facing right. Use the Teal fighter
> montage only as a biomechanical and timing reference. Strict 4 x 2 reading
> order: contact A, compression A, passing A, rise A, contact B, compression B,
> passing B, rise B. Keep identity, camera, scale and ground root stable;
> alternate all four legs, add a subtle shell bob and delayed trunk
> follow-through. True transparent background, clean separated cells, no text,
> no labels, no painted grid, no shadows, no effects.

## Normalisation

```bash
python3 pipeline/assets/tools/process_vacuum_trooper_walk_candidate.py
```

Le processeur découpe les cellules, détecte l'alpha utile, applique une échelle
commune, aligne les huit poses sur le root canonique `[256, 360]`, produit les
frames runtime 256 × 192, l'atlas 4 × 2, la feuille de revue et la boucle WebP.

```bash
python3 pipeline/assets/tools/validate_vacuum_trooper_walk_candidate.py
```

Le validateur protège la source, les huit durées, les dimensions, l'alpha, les
marges et le root fixe. Le lot a été approuvé le 2026-08-27 puis publié sous
`art/characters/enemies/vacuum_trooper/` et intégré à un `SpriteFrames` Godot.
