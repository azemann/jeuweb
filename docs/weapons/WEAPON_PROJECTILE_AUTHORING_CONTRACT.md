# Contrat auteur des armes et projectiles

## Autorités

- `WeaponData` possède identité, scène de projectile, cadence et mode auto ;
- `ProjectileData` possède vitesse, durée de vie, dégâts, rayon de creusement et représentation ;
- `PlayerAimComponent` possède la direction ;
- `Marker2D Muzzle` possède l'origine finale du tir dans la scène joueur ;
- `PlayerWeaponComponent` possède uniquement cooldown et demande runtime ;
- `MissionProjectileSpawner2D` possède la correspondance demande → instance ;
- `Projectile2D` possède son vol et la résolution d'un impact particulier ;
- `AnimationPlayer` possède le timing du flash et de l'impact.

## Arbres canoniques

```text
Player/Components/Weapon
└── FireCooldown (Timer)

Projectile2D (Area2D)
├── CollisionShape2D
├── Tracer
├── Core
└── Lifetime (Timer)

Mission
├── ProjectileSpawner
└── Map/Actors/Projectiles
```

## Contrat runtime

L'action `player_fire` demande le tir. Le composant vérifie le Timer, joue le
feedback et émet `projectile_requested`. Le spawner de mission instancie la
PackedScene hors du joueur. Le projectile avance selon sa Resource et combine
les signaux `Area2D` avec un rayon entre deux frames pour empêcher le tunneling
des munitions rapides.

Les appels directs représentent les commandes (`fire_once`, `apply_damage`) ;
les signaux représentent les événements (`projectile_requested`, `impacted`).

Avant le spawn, le projectile vérifie le segment entre l'origine interne du
canon (`AimPivot`) et le `Muzzle`. Si le canon visuel traverse une paroi à bout
portant, l'impact est résolu sur cette première paroi : la balle ne peut jamais
naître derrière le bord ou au milieu du terrain.

Lorsqu'une munition active `Affects Destructible Terrain`, son impact appelle
le `DestructibleTerrain2D` du groupe natif et retire un disque de matière à sa
position. Ce creusement ne touche que les surfaces `Carvable` déjà composées
dans le masque global. Les pièces `Permanent` et `Breakable` restent autonomes.

## Contrat auteur

- changer cadence ou projectile dans `WeaponData`, jamais dans le composant ;
- changer vitesse, dégâts, durée, couleurs ou rayon de cratère dans `ProjectileData` ;
- déplacer le Muzzle dans la scène joueur avec le canon ;
- régler les timings de flash et d'impact dans leurs AnimationPlayer ;
- conserver `Actors/Projectiles` dans toute scène maîtresse de mission.

## Validation

`weapon_projectile_integration_test.gd` vérifie Resources, demande découplée,
conteneur runtime, spawn exact au Muzzle, cooldown, direction horizontale et
verticale, déplacement indépendant, collision avec un obstacle World et tir à
bout portant bloqué entre `AimPivot` et `Muzzle`.
`projectile_carvable_integration_test.gd` vérifie qu'un impact rend le centre
du cratère traversable sans retirer la matière située hors de son petit rayon.
