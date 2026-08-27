# Recette projectile et impact — lot v001

## Intention

Créer la signature visuelle du premier canon : une munition de campagne lourde,
lisible à grande vitesse, puis un impact extravagant en six temps. Le projectile
reste orienté vers la droite ; le retournement appartient à la scène Godot.

## Autorités

- ImageGen produit les sources artistiques candidates ;
- ce pipeline produit les dérivés normalisés ;
- `ProjectileData` possède l'échelle, la vitesse et les paramètres gameplay ;
- `Projectile2D` possède l'instance runtime ;
- `AnimationPlayer` possède la temporalité de l'impact.

## Prompts ImageGen

### Projectile

Un seul projectile 2D de profil, pointant strictement vers la droite, conçu
pour le canon de campagne du commando. Munition lourde et courte en métal olive
huileux et anthracite, cerclage magenta, nez vert acide, petite propulsion
orange. Silhouette immédiatement lisible, contours noirs épais et peinture
criarde cohérente avec la planche d'armes/VFX. Fond transparent natif, aucun
texte, personnage, sol, ombre portée ni autre objet.

### Impact

Planche d'animation 3 × 2, six images chronologiques d'un unique impact de
projectile : étincelle de contact, étoile comprimée, éclatement principal,
anneau et débris, dissipation, dernières étincelles. Même centre et même caméra
dans chaque case, style cartoon militaire toxique noir/olive, vert acide,
orange et magenta. Cases régulières sans séparation visible, fond transparent
natif, aucun texte, décor, personnage ou ombre portée.

Références : `art/concepts/da-04-weapons-vfx.png` et
`art/weapons/player/player-primary-cannon-v001.png`.

## Normalisation reproductible

```bash
python3 pipeline/assets/tools/process_projectile_impact_candidates.py
python3 pipeline/assets/tools/validate_projectile_impact_candidates.py
```

La source d'impact conserve volontairement son faible voile alpha. Seul le
dérivé retire les alpha inférieurs ou égaux à 16/255, cellule par cellule. Les
sorties restent candidates et ne sont jamais copiées automatiquement sous
`art/`.
