# Matrice d'intégration — Industrial Toxic Megapack v001

Cette matrice interdit toute republication d'une fonction déjà couverte. Une
source `superseded` reste une provenance visuelle mais ne devient jamais un
second runtime concurrent.

## Déjà couverts ou supplantés — 11

| Source | Statut | Autorité runtime |
|---|---|---|
| industrial catwalk | integrated | `industrial_catwalk_medium.tres` |
| military bunker block | integrated | `military_bunker_block_medium.tres` |
| toxic acid sump | integrated | `toxic_acid_sump_medium.tres` |
| toxic pipe bridge | integrated | `toxic_pipe_bridge_medium.tres` |
| explosive barrel | integrated | `toxic_explosive_barrel.tres` |
| military supply crate | integrated | `military_supply_crate.tres` |
| vacuum siphoner | superseded | `VacuumGrunt2D` et atlas v002 |
| vacuum scout drone | superseded | `VacuumFlying2D` et atlas v002 |
| vacuum brute | superseded | `VacuumBoss2D` et atlas v002 |
| alien hatchling saboteur | superseded | `VacuumPilotSaboteur2D` et atlas v002 |
| health injector | integrated | `health_injector.tres` → `Pickup2D` |

## Nouvelles candidates retenues — 27

| Famille | Sources retenues | Contrat cible |
|---|---|---|
| architecture | acid bridge abutment, destructible military wall, guard tower, vacuum foundry platform, walk-under pipe arch | Ground Piece ou scène architecturale composée |
| props | ammo locker, medical station, floodlight, barricade, proximity mine, radio relay, toxic vent | scène dédiée + Resource selon fonction |
| pickups | ammo drum, armor plate, overdrive core | `PickupData` + autorité joueur correspondante |
| acid | sprayer, capsule, impact 3×2 | `WeaponData` + `ProjectileData` + impact |
| electric | coil rifle, bolt, impact 3×2 | `WeaponData` + `ProjectileData` + impact |
| implosion | imploder cannon, core, impact 3×2 | `WeaponData` + `ProjectileData` + impact |
| rocket | demolition launcher, rocket, impact 3×2 | `WeaponData` + `ProjectileData` + impact |

## Règle de publication

Le lot source global reste `candidate` et `integrationAllowed=false`. Les 27
éléments retenus sont publiés par le lot dérivé
`industrial-toxic-expansion-v001`, puis deviennent intégrables uniquement avec
leur Resource, leur scène, leur correspondance Inspector et leur validation.
