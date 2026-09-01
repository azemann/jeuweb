# Contrat auteur des armes et projectiles

## Autorités

- `WeaponData` possède identité, scène de projectile, cadence, mode auto,
  coût en munitions et bitmap d'arme ;
- `WeaponData` possède aussi les amplitudes de recul corporel et de secousse
  caméra propres à l'arme ;
- `ProjectileData` possède vitesse, durée de vie, dégâts, rayon de creusement,
  représentation et correspondance d'explosion optionnelle ;
- `PlayerAimComponent` possède la direction ;
- `Marker2D Muzzle` possède l'origine finale du tir dans la scène joueur ;
- `PlayerLoadoutProfile` possède l'arsenal autorisé et l'arme de départ ;
- `PlayerLoadoutComponent` possède l'arme équipée runtime ;
- `WeaponWheelOverlay` peut demander une sélection temporaire pour tester les
  armes autorisées, mais ne possède ni arsenal ni inventaire ;
- `PlayerWeaponComponent` possède uniquement cooldown et demande runtime ;
- `MissionProjectileSpawner2D` possède la correspondance demande → instance ;
- `Projectile2D` possède son vol et la résolution d'un impact particulier ;
- `AnimationPlayer` possède le timing du flash et de l'impact.
- `PlayerCombatInventoryComponent` possède la réserve partagée et le
  multiplicateur de cadence Overdrive ;
- `ServiceStationData.granted_weapon` relie une armurerie à une `WeaponData`.
- `AuthorPreview` dans les scènes de projectile et d'armurerie projette les
  identifiants branchés pour l'auteur, sans devenir autorité.

## Arbres canoniques

```text
Player/Components/Weapon
└── FireCooldown (Timer)

Player/Components/Loadout
└── PlayerLoadoutProfile

MissionHUD
└── WeaponWheel (WeaponWheelOverlay)

Projectile2D (Area2D)
├── CollisionShape2D
├── Visual (Sprite2D optionnel)
├── Tracer
├── Core
├── Lifetime (Timer)
└── AuthorPreview (Label, éditeur)

Mission
├── RuntimeSystems/ProjectileSpawner
└── Map/Runtime/Projectiles
```

## Contrat runtime

L'action `player_fire` demande le tir. `PlayerWeaponComponent` consomme
l'arme équipée par `PlayerLoadoutComponent`, vérifie le Timer, joue le feedback
et émet `projectile_requested`. Le spawner de mission instancie la PackedScene
hors du joueur. Le projectile avance selon sa Resource et combine les signaux
`Area2D` avec un rayon entre deux frames pour empêcher le tunneling des
munitions rapides.

Les appels directs représentent les commandes (`fire_once`, `apply_damage`) ;
les signaux représentent les événements (`projectile_requested`, `impacted`).
Le signal `fired` alimente séparément `PlayerRecoilComponent` et
`MissionCameraRig2D` : ni le projectile ni Health ne deviennent autorités des
feedbacks de tir.

La référence runtime `shooter` n'est jamais une autorité de durée de vie. Un
projectile peut survivre à l'acteur qui l'a tiré ; il valide donc cette référence
avec `is_instance_valid()` avant toute exclusion physique ou recherche d'enfant,
puis l'oublie silencieusement lorsque l'acteur a été libéré.

Avant le spawn, le projectile vérifie le segment entre l'origine interne du
canon (`AimPivot`) et le `Muzzle`. Si le canon visuel traverse une paroi à bout
portant, l'impact est résolu sur cette première paroi : la balle ne peut jamais
naître derrière le bord ou au milieu du terrain.

Lorsqu'une munition active `Affects Destructible Terrain`, son impact appelle
le `DestructibleTerrain2D` du groupe natif et retire un disque de matière à sa
position. Ce creusement ne touche que les surfaces `Carvable` déjà composées
dans le masque global. Les pièces `Permanent` et `Breakable` restent autonomes.

Une munition explosive assigne ensemble `Explosion Scene` et `Explosion Data`
dans sa `ProjectileData`. Au point de collision mondial, `Projectile2D` injecte
la Resource, place la scène sans hériter de son échelle, puis appelle
`detonate()`. L'explosion remplace alors les dégâts directs et le petit cratère
du projectile afin de ne jamais appliquer deux autorités de dégâts ou de
terrain au même impact. `Impact Scene` peut rester assignée comme feedback
visuel de contact indépendant.

Une arme choisit indirectement son style explosif par sa scène de projectile :

```text
WeaponData → ProjectileData → ExplosionData → Explosion2D
```

Les quatre familles spéciales publiées suivent la même chaîne et partagent la
réserve autoritaire du joueur : acide, électrique, implosion et démolition.
Leur équipement passe par une station d'armurerie configurée dans l'Inspector.
Une armurerie demande l'équipement au `PlayerLoadoutComponent`, qui refuse les
armes absentes du profil d'arsenal au lieu d'enregistrer une arme cachée dans
la station ou dans le composant de tir.

La roquette de démolition possède son `ExplosionData` de munition
`demolition_rocket_burst`, séparé des explosions de barils et de l'ancien
profil générique d'obus de campagne. Le canon de campagne reste une munition
directe : son petit impact animé n'est pas une explosion radiale.

## Contrat auteur

- changer cadence ou projectile dans `WeaponData`, jamais dans le composant ;
- changer Body Recoil Distance, Camera Shake Strength et Camera Shake Duration
  dans `WeaponData` ; régler la courbe temporelle du corps dans
  `Components/Recoil/RecoilAnimationPlayer` ;
- conserver la secousse à zéro pour les armes automatiques de base ; la réserver
  aux armes lourdes et événements dont la lisibilité justifie le déplacement du
  viewport ;
- changer vitesse, dégâts, durée, couleurs, rayon de cratère ou explosion
  optionnelle dans `ProjectileData` ;
- déplacer le Muzzle dans la scène joueur avec le canon ;
- régler les timings de flash et d'impact dans leurs AnimationPlayer ;
- conserver `Runtime/Projectiles` dans toute scène maîtresse de mission ;
- activer `Uses Special Ammo` et fixer `Ammo Cost` dans la `WeaponData` ;
- assigner `Weapon Texture` et `Weapon Visual Scale` dans la Resource, jamais
  dans une branche conditionnelle du joueur ;
- créer les variantes d'armurerie par `ServiceStationData`, sans dupliquer le
  bitmap du casier ni les valeurs de la `WeaponData` ;
- ajouter ou retirer une arme jouable dans `PlayerLoadoutProfile`, puis placer
  les armureries correspondantes dans la scène de mission ; ne pas créer de
  liste codée dans `PlayerWeaponComponent` ou le HUD ;
- maintenir `player_weapon_wheel` comme commande de test rapide : maintenir
  `Tab` ou l'épaule gauche de manette, choisir un segment au pointeur ou stick
  droit, puis relâcher pour équiper ; si `refill_special_ammo_on_select` reste
  actif, une arme spéciale remplit la réserve partagée afin que son projectile
  puisse être testé immédiatement ;
- lire `AuthorPreview` dans la scène pour vérifier rapidement
  `projectile_id`, impact, explosion éventuelle, station et arme accordée ;
  modifier ensuite la Resource correspondante dans l'Inspector.

## Validation

`weapon_projectile_integration_test.gd` vérifie Resources, demande découplée,
conteneur runtime, spawn exact au Muzzle, cooldown, direction horizontale et
verticale, déplacement indépendant, collision avec un obstacle World et tir à
bout portant bloqué entre `AimPivot` et `Muzzle`. Il libère aussi un tireur
temporaire avant le projectile et protège l'absence de référence invalide.
`projectile_carvable_integration_test.gd` vérifie qu'un impact rend le centre
du cratère traversable sans retirer la matière située hors de son petit rayon.
Le contrat vérifie aussi qu'une `ProjectileData` explosive instancie
`Explosion2D` au point d'impact avec la Resource choisie, sans modifier la
munition de campagne actuelle.
Il protège aussi le bitmap et l'impact animé publiés du canon de campagne, le
profil d'explosion dédié de la roquette de démolition et les `AuthorPreview`
des projectiles et armureries.
`industrial_toxic_expansion_contract_test.gd` vérifie le profil d'arsenal, les
quatre WeaponData, leurs projectiles texturés, leurs impacts animés et leurs
armureries.
