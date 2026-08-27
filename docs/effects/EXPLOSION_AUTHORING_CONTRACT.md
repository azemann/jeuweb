# Contrat auteur des explosions

Une explosion est une scène de gameplay réutilisable, pas un effet codé dans
une arme ou dans la carte.

## Autorités

- `ExplosionData.tres` possède rayons, dégâts, impulsion, durée et palette ;
- `Explosion2D.tscn` possède l'assemblage Godot et la temporalité visuelle ;
- `AnimationPlayer` décide quand l'impact devient actif ;
- `DestructibleTerrain2D` reste seul propriétaire de son masque et de ses
  collisions ;
- chaque objet déclencheur choisit sa scène et son `ExplosionData` ;
- un socket auteur tel que `Marker2D ExplosionOrigin`, ou le point de collision
  d'un projectile, possède l'origine mondiale de la détonation ;
- le système de santé de chaque cible reste propriétaire de son état et décide
  s'il accepte la commande `apply_damage`.

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

## Déclencheurs et origine

Un baril ou autre objet placé expose un `Marker2D ExplosionOrigin` visible dans
sa scène canonique. Ce socket suit nativement translation, rotation, échelle et
miroir de l'instance. Le déclencheur ajoute l'explosion au conteneur runtime,
copie la `global_position` du socket, puis appelle `detonate()` ;
`detonate_on_ready` reste désactivé pour interdire un impact avant placement.

La position du socket suit le Transform auteur complet, mais l'échelle du rayon
reste celle d'`ExplosionData` : redimensionner un baril ne crée pas une seconde
autorité implicite sur la puissance de son explosion. Un projectile utilise son
point d'impact mondial selon le même contrat.

Chaque famille choisit son style par Resource : baril, roquette, mine ou piège
peuvent partager `Explosion2D` tout en injectant des `ExplosionData` distinctes.

## Événements

- `detonated` annonce le déclenchement ;
- `terrain_carved` confirme une modification effective de terrain ;
- `target_damaged` confirme qu'une cible unique a accepté `apply_damage` et
  expose l'impulsion radiale aux futurs systèmes de réaction ;
- `finished` annonce la fin de l'animation.

Appliquer les dégâts est une commande directe. Le signal décrit ensuite un
résultat réel ; aucun parent ne doit rebrancher une demande de dégâts. Une cible
détectée à la fois par son Body et sa Hurtbox n'est traitée qu'une fois après
résolution de son Damage Receiver.

Une arme choisit une `ExplosionData` ou une scène d'explosion. Elle ne recopie
jamais ses valeurs dans son propre script.
