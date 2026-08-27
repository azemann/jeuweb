# Recette — projectile et impact de pression toxique v001

## Intention

Ce lot fournit le projectile lent et évitable de la première attaque du Vacuum
Trooper, ainsi que sa confirmation d'impact. Vitesse, trajectoire, collision et
dégâts ne sont pas contenus dans les bitmaps : leur autorité appartiendra à
`ProjectileData` et à la scène projectile.

## Génération et prompts finaux

- outil : ImageGen intégré à Codex ;
- projectile : source RGBA 2172 × 724, planche 4 × 1 ;
- impact : source RGBA 1536 × 1024, planche 3 × 2.

Prompt projectile : planche stricte 4 × 1 sur alpha réel d'un unique projectile
lent de pression toxique, quatre phases cohérentes vers la droite, cœur vert
acide lumineux, gouttes jaune-vert et vapeur olive sombre, sans personnage,
texte, bordure ni décor.

Prompt impact : planche stricte 3 × 2 sur alpha réel du même projectile :
étincelle de contact, compression, éclaboussure, nuage en expansion, gouttes en
dissipation, vapeur finale ; même palette, sans personnage, texte, bordure ni
décor.

## Normalisation déterministe

```bash
python3 pipeline/assets/tools/process_toxic_pressure_candidates.py
python3 pipeline/assets/tools/validate_toxic_pressure_candidates.py
```

Le projectile produit quatre cellules 96 × 64 autour du pivot `[48, 32]`.
L'impact produit six cellules 192 × 160 autour du pivot `[96, 80]`.

## Statut

Les deux planches sont `candidate` et `technical: passed`. Elles restent hors
de `art/` et de Godot jusqu'à validation visuelle et temporelle explicite.
