# Run-and-Gun Player Kit

Ce document décrit ce que le joueur peut faire. Il ne remplace pas les
contrats auteur des composants Godot : il sert à décider quoi garder, créer ou
reporter avant de produire de nouvelles armes, munitions ou animations.

## Vocabulaire

- `Run-and-Gun Player Kit` : actions et capacités disponibles pour le joueur ;
- `Player Controller` : traduction des inputs en actions ;
- `Player Feel` : sensation clavier/manette, incluant accélération, saut,
  anticipation, recul, cadence, réponse et animations ;
- `Run-and-Gun HUD Layout` : informations montrées au joueur.

L'arsenal est donc une partie du Player Kit, pas le Player Kit complet.

## Kit v001 à garder

| Domaine | Capacité | Statut | Autorité Godot |
|---|---|---|---|
| Movement | Run | Garder | `PlayerMovementComponent` + `arcade_movement.tres` |
| Movement | Jump | Garder | `PlayerMovementComponent` + `arcade_movement.tres` |
| Aim | Left / Right | Garder | `PlayerAimComponent` + Input Map |
| Aim | Up / Down | Garder | `PlayerAimComponent` + Input Map |
| Aim | Diagonal | Garder | `PlayerAimProfile` |
| Aim | Pointer aim | Garder pour PC | `PlayerAimComponent` |
| Combat | Shoot | Garder | `PlayerWeaponComponent` + `WeaponData` |
| Combat | Hold Fire | Garder pour armes automatiques | `WeaponData.automatic` |
| Weapons | Equip | Garder | `PlayerLoadoutComponent` |
| Weapons | Pickup via armory | Garder | `ServiceStationData` + `ServiceStation2D` |
| Survival | Take Damage | Garder | `PlayerHealthComponent` |
| Survival | I-Frames | Garder | `PlayerHealthProfile` |
| Survival | Death | Garder | `AnimationPlayer` + `PlayerHealthComponent` |
| Survival | Respawn | Garder | `MissionActorSpawner2D` |
| Interaction | Pickup Health | Garder | `PickupData` + `PlayerHealthComponent` |
| Interaction | Pickup Ammo / Armor / Overdrive | Garder | `PickupData` + `PlayerCombatInventoryComponent` |
| Interaction | Activate | Garder | `PlayerInteractionComponent` |

## Capacités à ne pas créer maintenant

| Domaine | Capacité | Décision | Raison |
|---|---|---|---|
| Movement | Crouch | Reporter | aucun besoin vérifié dans Côte toxique v001 |
| Movement | Drop-through | Reporter | nécessite plateformes traversables et lecture dédiée |
| Movement | Dash / Slide | Reporter | change fortement niveaux, ennemis et caméra |
| Aim | Aim Lock | Reporter | utile seulement si le combat l'exige au playtest |
| Combat | Melee | Reporter | nécessite hitbox, animation et rôle d'ennemis proches |
| Combat | Grenade | Reporter | empiète sur les armes explosives déjà présentes |
| Combat | Special Attack hors arme | Reporter | Overdrive accélère déjà la cadence |
| Weapons | Swap multi-slot | Reporter | le gameplay possède une seule arme équipée |
| Weapons | Drop | Reporter | aucun système de loot au sol ou économie d'arme |
| Interaction | Rescue | Hors v001 | aucun allié ou objectif de sauvetage publié |

Ces capacités ne sont pas interdites. Elles exigent simplement une tranche
dédiée avec niveau, ennemis, animation, HUD et validation correspondants.

## Arsenal v001 à garder

| Arme | Rôle recherché | Munition | Décision |
|---|---|---|---|
| Canon de campagne | arme primaire gratuite, lisible, fiable | `field_round` | Garder |
| Pulvérisateur acide | pression courte/moyenne, grignotage terrain | `acid_capsule` | Garder mais équilibrer |
| Fusil à bobine électrique | tir rapide et précis, faible dégâts par coup | `electric_coil_bolt` | Garder mais équilibrer |
| Canon imploseur | tir lourd lent, impact spectaculaire | `vacuum_implosion_core` | Garder mais équilibrer |
| Lanceur de démolition | explosif lisible, coût élevé | `demolition_rocket` | Garder mais relier à une vraie famille d'explosion de munition |

La prochaine création d'armes ne doit pas ajouter un sixième rôle tant que ces
cinq armes ne sont pas jouées, lisibles et différenciées dans Côte toxique.

## Ce qu'il faut créer ensuite côté armes

1. Une famille d'explosions de munitions distincte des explosions de barils.
   Le lanceur de démolition doit utiliser une `ExplosionData` de munition, pas
   une explosion de prop.
2. Une revue des `WeaponData` et `ProjectileData` existantes : cadence, coût,
   vitesse, dégâts, rayon terrain, recul et secousse.
3. Des règles de disponibilité dans la mission : où le joueur obtient chaque
   arme, combien de munitions il reçoit, et quel problème de combat l'arme
   résout.
4. Seulement après playtest, décider si une arme doit être supprimée, fusionnée
   ou remplacée.

## Player Feel à mesurer

- délai entre input et mouvement ;
- vitesse maximale et distance d'arrêt ;
- hauteur et arc du saut ;
- réponse de la visée en mouvement ;
- lisibilité du recul ;
- stabilité caméra pendant tirs rapides ;
- poids ressenti des armes lourdes ;
- temps nécessaire pour comprendre une nouvelle arme ;
- fréquence de manque de munitions pendant un beat.

## Validation attendue

- les actions du kit v001 restent présentes dans Input Map ou scènes visibles ;
- chaque capacité gardée possède une autorité unique ;
- aucune capacité reportée ne reçoit un faux affichage HUD ;
- chaque arme gardée a une `WeaponData`, une `ProjectileData`, une scène de
  projectile, un feedback d'impact et un point d'obtention auteur ;
- les munitions explosives utilisent une `ExplosionData` de munition distincte
  des profils de barils.
