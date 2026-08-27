# Contrat auteur des explosions

Une explosion est une scène de gameplay réutilisable, pas un effet codé dans
une arme ou dans la carte.

## Autorités

- `ExplosionData.tres` possède rayons, dégâts, impulsion, durée et palette ;
- `Explosion2D.tscn` possède l'assemblage Godot et la temporalité visuelle ;
- `AnimationPlayer` décide quand l'impact devient actif ;
- `DestructibleTerrain2D` reste seul propriétaire de son masque et de ses
  collisions ;
- le système de santé futur décidera comment un acteur consomme une demande de
  dégâts.

## Arbre canonique

```text
Explosion2D
├── DamageArea
│   └── DamageShape
├── Visuals
│   ├── Smoke
│   ├── Fireball
│   └── Flash
└── AnimationPlayer
```

L'explosion adresse un terrain explicite par `terrain_path` lorsqu'elle est
placée dans une scène maîtresse. À défaut, elle interroge le groupe
`destructible_terrains`, ce qui permet aux projectiles instanciés à l'exécution
de rester découplés de la carte.

## Événements

- `detonated` annonce le déclenchement ;
- `terrain_carved` confirme une modification effective de terrain ;
- `damage_requested` expose cible, dégâts et impulsion sans imposer un système
  de santé ;
- `finished` annonce la fin de l'animation.

Une arme choisit une `ExplosionData` ou une scène d'explosion. Elle ne recopie
jamais ses valeurs dans son propre script.

