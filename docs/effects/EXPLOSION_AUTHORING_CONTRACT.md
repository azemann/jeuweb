# Contrat auteur des explosions

Une explosion est une scène de gameplay réutilisable, pas un effet codé dans
une arme ou dans la carte.

## Autorités

- `ExplosionData.tres` possède identité, famille, rayons, dégâts, impulsion,
  durée, animation peinte et intensités VFX ;
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
├── VisualScale
│   ├── VisualMotion
│   │   ├── ArtSprite
│   │   └── ProceduralFallback
│   ├── ShockwaveRoot
│   │   ├── ShockwavePrimary
│   │   └── ShockwaveSecondary
│   ├── FlashLight
│   ├── Sparks
│   ├── Debris
│   └── ToxicDroplets
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
La même scène expose aussi `AuthorPreview`, un label visible seulement dans
l'éditeur. Il affiche le `prop_id` de l'objet et le `explosion_id` réellement
déclenché afin que l'auteur sache ce qu'il vient d'assigner sur l'occurrence.
Ce label est une projection de lecture, jamais une seconde autorité.

La position du socket suit le Transform auteur complet, mais l'échelle du rayon
reste celle d'`ExplosionData` : redimensionner un baril ne crée pas une seconde
autorité implicite sur la puissance de son explosion. Un projectile utilise son
point d'impact mondial selon le même contrat.

Chaque famille choisit son style par Resource : baril, roquette, mine ou piège
peuvent partager `Explosion2D` tout en injectant des `ExplosionData` distinctes.
Le rayon de terrain et le rayon de dégâts sont deux autorités indépendantes
dans `ExplosionData` : une grosse charge peut ouvrir un large cratère sans
nécessairement appliquer des dégâts sur tout ce diamètre.

## Familles et paliers

Une famille est déclarée par `family_id`, jamais déduite d'un chemin ou du nom
du consommateur. Ses paliers sont des Resources réutilisables et non des
réglages recopiés dans chaque baril. Le lot baril v001 publie :

| Profil | Usage auteur | Rayon dégâts | Dégâts | Impulsion |
|---|---|---:|---:|---:|
| `barrel_small_explosion.tres` | petit récipient, charge légère | 68 px | 32 | 480 |
| `barrel_standard_explosion.tres` | baril toxique courant | 108 px | 60 | 900 |
| `barrel_heavy_explosion.tres` | grande cuve, set-piece | 164 px | 100 | 1480 |

Chaque profil possède également son atlas huit phases, sa durée, son échelle
visuelle, ses deux ondes, sa lumière et ses quantités de particules. Ces valeurs
visuelles n'altèrent jamais les rayons gameplay. L'auteur choisit le profil dans
`ExplosivePropData.explosion_data` ; il ne redimensionne pas la scène pour
simuler une puissance différente.

La surenchère VFX est volontaire, mais demeure locale : une explosion ne
possède aucun `Camera2D`, ne demande aucune secousse globale et ne rend jamais
le recul ou les changements de direction illisibles.

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
