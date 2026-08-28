# Manifeste des assets

Chaque bitmap publié possède une origine, une intention et un statut. Les
sources et fichiers maîtres vivent dans `pipeline/assets/`, hors de l'importeur
Godot. Les planches de concept ne doivent pas devenir des sprites gameplay ;
elles restent toutefois des livrables runtime pour la galerie interne.

## Planches de direction artistique

| Fichier | Origine | Usage | Statut |
|---|---|---|---|
| `concepts/da-01-master-board.png` | imagegen intégré | autorité de style générale | référence |
| `concepts/da-02-characters.png` | imagegen intégré, dérivé de DA-01 | héros et anciennes silhouettes ennemies | référence partielle |
| `concepts/da-03-environment-destruction.png` | imagegen intégré | Côte toxique et destruction | référence |
| `concepts/da-04-weapons-vfx.png` | imagegen intégré | armes, projectiles et impacts | référence |
| `concepts/da-05-ui-flow.png` | imagegen intégré | Boot, Start et HUD | référence |
| `concepts/da-06-enemies-vacuum-divers.png` | imagegen intégré | coques aspirateurs-scaphandres | référence canonique |
| `concepts/da-07-enemy-pilot-lifecycle.png` | imagegen intégré | éjection et pilotes | référence canonique |

## Côte toxique — assets runtime v001

| Fichier | Création | Intention | Intégration |
|---|---|---|---|
| `maps/toxic_coast/toxic-coast-far-background-v001.png` | imagegen intégré ; prompt : panorama 8:3, ciel, océan et forteresse lointaine, aucun gameplay | fond opaque | `Visual/FarBackground` |
| `maps/toxic_coast/toxic-coast-midground-v001.png` | imagegen intégré ; prompt : jungle industrielle intermédiaire sur alpha transparent | parallaxe lente | `Visual/MidgroundParallax` |
| `maps/toxic_coast/toxic-coast-foreground-v001.png` | imagegen intégré ; prompt : tuyaux, végétation et débris aux bords sur alpha transparent | parallaxe rapide | `Visual/ForegroundParallax` |
| `terrain/toxic_coast/toxic-soil-shallow-v001.png` | dérivé ImageMagick de la source maître | couche haute | `toxic_coast_terrain.tres` |
| `terrain/toxic_coast/toxic-soil-main-v001.png` | dérivé ImageMagick de la source maître | matière centrale | `toxic_coast_terrain.tres` |
| `terrain/toxic_coast/toxic-soil-deep-v001.png` | dérivé ImageMagick de la source maître | matière profonde | `toxic_coast_terrain.tres` |
| `terrain/toxic_coast/toxic-surface-intact-v001.png` | dérivé ImageMagick de la source maître | bord intact | `toxic_coast_terrain.tres` |
| `terrain/toxic_coast/toxic-surface-fresh-v001.png` | dérivé ImageMagick de la source maître | bord de cratère | `toxic_coast_terrain.tres` |

Source maître hors Godot :
`pipeline/assets/sources/imagegen/toxic_coast/toxic-soil-master-v001.png`.
Recette : `pipeline/assets/recipes/toxic_coast_v001.md`.

## Côte toxique — kit de Ground Pieces v001

| Fichier | Création | Intention | Intégration |
|---|---|---|---|
| `terrain/pieces/toxic_coast/natural/natural-ledge-medium-v001.png` | imagegen intégré, extraction alpha puis normalisation 768 × 384 | première plateforme illustrée utilisable en Permanent, Carvable ou Breakable | `natural_ledge_medium.tres` → scène glissable |
| `terrain/pieces/toxic_coast/natural/damage_states/natural-ledge-medium-damaged-v001.png` | édition ImageGen approuvée, extraction du fond puis normalisation 768 × 384 | état sous le seuil de vie cassable | `GroundPieceDefinition.damaged_texture` |
| `terrain/pieces/toxic_coast/natural/damage_states/natural-ledge-medium-destroyed-v001.png` | édition ImageGen approuvée, extraction du fond puis normalisation 768 × 384 | ruine finale sans collision | `GroundPieceDefinition.destroyed_texture` |
| `terrain/pieces/toxic_coast/military/military-bunker-block-medium-v001.png` | ImageGen intégré puis normalisation pipeline 768 × 384 | bloc bunker glissable | `military_bunker_block_medium.tres` |
| `terrain/pieces/toxic_coast/metal/industrial-catwalk-medium-v001.png` | ImageGen intégré puis normalisation pipeline 768 × 384 | passerelle glissable | `industrial_catwalk_medium.tres` |
| `terrain/pieces/toxic_coast/pipes/toxic-pipe-bridge-medium-v001.png` | ImageGen intégré puis normalisation pipeline 768 × 384 | pont-tuyau glissable | `toxic_pipe_bridge_medium.tres` |
| `terrain/hazards/toxic_coast/toxic-acid-sump-medium-v001.png` | ImageGen intégré puis normalisation pipeline 768 × 384 | bassin acide dangereux | `toxic_acid_sump_medium.tres` |
| `props/toxic_coast/explosive-barrel-v001.png` | ImageGen intégré puis normalisation pipeline 256 × 320 | baril destructible explosif | `toxic_explosive_barrel.tres` |
| `props/toxic_coast/military-supply-crate-closed-v001.png` | ImageGen intégré puis normalisation pipeline 384 × 320 | état fermé de la caisse | `military_supply_crate.tres` |
| `props/toxic_coast/military-supply-crate-open-v001.png` | édition ImageGen de la caisse fermée, extraction alpha puis normalisation 384 × 320 | état ouvert vide de la caisse | `military_supply_crate.tres` |

Pivot de surface : `[384, 64]`. Empreinte SHA-256 :
`607940a9670b9121b4158f807749c89545ad513428a9f93e08f9d1aff1f7ed57`.
Recette, manifeste, provenance et QA :
`pipeline/assets/{recipes,manifests,provenance,working}`.

Les états de dégâts ont été approuvés le 2026-08-26. Leur lot dédié est
`natural_ledge_damage_states_v001`.

Le lot de contenu industriel est produit par
`pipeline/assets/tools/process_toxic_coast_content_pack.py`. Sources, exports et
rapport QA restent sous `pipeline/assets/`; les sept PNG de cette table sont les
copies runtime publiées. La caisse ouverte a été générée avec l'outil ImageGen
intégré à partir de la caisse fermée, puis passée par une extraction alpha.

## Joueur — assets runtime v001

| Fichier | Création | Intention | Intégration |
|---|---|---|---|
| `characters/player/player-body-key-poses-v001.png` | imagegen intégré puis extraction alpha, canevas fixe et atlas 4 × 3 déterministes | 12 poses clés du corps sans arme | `player_visual_frames.tres` → `Presentation/BodySprite` |
| `weapons/player/player-primary-cannon-v001.png` | imagegen intégré puis normalisation 768 × 384 | canon modulaire séparé du corps | `Visuals/AimPivot/WeaponSprite` |

Lot approuvé le 2026-08-25. Sources, prompts, profil, manifeste, provenance et
QA : `pipeline/assets/{sources,recipes,profiles,manifests,provenance,working}`.
Les poses clés sont intégrées ; leur continuité temporelle reste provisoire et
sera affinée frame par frame.

## Ennemis — Vacuum Trooper v001

| Fichier | Création | Intention | Intégration |
|---|---|---|---|
| `characters/enemies/vacuum_trooper/vacuum-trooper-walk-4x2-256-v001.png` | ImageGen intégré, concepts DA-06/DA-07, marche Teal comme référence biomécanique, normalisation déterministe | cycle de marche 8 poses du premier aspirateur-scaphandre | `vacuum_trooper_frames.tres` → `Presentation/BodySprite` |
| `characters/enemies/vacuum_trooper/vacuum-trooper-hit-death-4x2-256-v001.png` | ImageGen intégré puis reconstruction déterministe des débordements source et normalisation | quatre poses d'impact/récupération et quatre poses de mort avec éjection du pilote | animations non bouclées `hit` et `death` dans `vacuum_trooper_frames.tres` |
| `characters/enemies/vacuum_trooper/vacuum-trooper-toxic-attack-4x2-256-v001.png` | ImageGen intégré, passe alpha réelle et normalisation déterministe | télégraphe complet en huit phases de l'attaque toxique | `vacuum_trooper_attack_frames.tres` → `Components/Attack/AttackSprite` |
| `weapons/projectiles/toxic_pressure/toxic-pressure-projectile-4x1-96-v001.png` | ImageGen intégré puis normalisation 4 × 1 | projectile lent évitable de pression toxique | `toxic_pressure_frames.tres` → `ToxicPressure2D/Visual` |
| `effects/toxic_pressure/toxic-pressure-impact-3x2-192x160-v001.png` | ImageGen intégré puis normalisation 3 × 2 | confirmation visuelle d'impact toxique | `toxic_pressure_impact_frames.tres` → `ToxicPressureImpact2D/Visuals` |

Lot approuvé le 2026-08-27. Atlas 1024 × 384, cellules 256 × 192, root
`[128, 180]`, huit poses de 160 ms. SHA-256 :
`d885176606cb70d76e98df81044c3a6683afaac370d1a4c0bb14c5086b19a9e3`.
Source, prompt, profil, manifeste, provenance et QA sous `pipeline/assets/`.

Lot impact/mort approuvé le 2026-08-27. Atlas 1024 × 384, cellules 256 ×
192, root `[128, 180]`. SHA-256 :
`54b6342c11b1c3354c316d685b74fd0f56eeae44de3cb489b91b5d493f934ed2`.

Lot attaque toxique approuvé le 2026-08-27. Atlas d'attaque 1024 × 384,
cellules 256 × 192, root `[128, 180]`, SHA-256 :
`f6a2a0fbc7ef375c4c507218f4d8a7e63520541a2bb7ec977c55d8b81ee8a1c3`.
Projectile 384 × 64, impact 576 × 320. Profils, recettes, manifestes,
provenance et QA sous `pipeline/assets/`.

## Ennemis — roster industriel toxique v001

| Fichier | Création | Intention | Intégration |
|---|---|---|---|
| `enemies/industrial_toxic/vacuum-grunt-animation-4x4-v001.png` | ImageGen intégré depuis le Siphoner, extraction cyan et normalisation déterministe | marche, attaque toxique, impact et mort du Grunt | `vacuum_grunt_frames.tres` → scène `VacuumGrunt2D` |
| `enemies/industrial_toxic/vacuum-flying-animation-4x4-v001.png` | ImageGen intégré depuis le Scout Drone, extraction cyan et normalisation déterministe | vol, tir, impact et destruction du Drone | `vacuum_flying_frames.tres` → scène `VacuumFlying2D` |
| `enemies/industrial_toxic/vacuum-boss-animation-4x4-v001.png` | ImageGen intégré depuis la Brute, extraction cyan et normalisation déterministe | marche lourde, blast, impact et mort du Boss | `vacuum_boss_frames.tres` → scène `VacuumBoss2D` |
| `enemies/industrial_toxic/vacuum-pilot-saboteur-animation-4x4-v001.png` | ImageGen intégré depuis le Hatchling, extraction cyan et normalisation déterministe | sprint, charge suicide, impact et mort du Saboteur | `vacuum_pilot_saboteur_frames.tres` → scène `VacuumPilotSaboteur2D` |

Lot approuvé le 2026-08-27 : 64 poses sur alpha réel. Les quatre sources,
prompts, atlas candidats, revues, aperçus, manifeste, provenance et QA sont
conservés sous `pipeline/assets/`.

## Ennemis — bestiaire animé v002

| Fichier | Création | Intention | Intégration |
|---|---|---|---|
| `characters/enemies/vacuum_trooper/vacuum-trooper-walk-4x2-256-v002.png` | édition ImageGen depuis l'identité Trooper, deux bandes de quatre phases, normalisation 256 × 192 | marche complète à huit poses avec appuis alternés | `vacuum_trooper_frames.tres` |
| `characters/enemies/vacuum_trooper/vacuum-trooper-toxic-attack-4x2-256-v002.png` | édition ImageGen, anticipation/charge/actif/récupération sur huit poses | attaque toxique sans fragment intercellule | `vacuum_trooper_attack_frames.tres` |
| `characters/enemies/vacuum_trooper/vacuum-trooper-hit-death-4x2-256-v002.png` | édition ImageGen, quatre impacts et quatre morts | réaction non létale puis effondrement irréversible | `vacuum_trooper_frames.tres` |
| `enemies/industrial_toxic/vacuum-grunt-animation-4x4-v002.png` | quatre bandes ImageGen séparées puis pipeline déterministe | appuis, attaque toxique, hit et mort du Siphoner | `vacuum_grunt_frames.tres` |
| `enemies/industrial_toxic/vacuum-flying-animation-4x4-v002.png` | quatre bandes ImageGen ; mouvement/hit régénérés pour conserver deux turbines et deux dérives | vol, tir, stabilisation et crash cohérents | `vacuum_flying_frames.tres` |
| `enemies/industrial_toxic/vacuum-boss-animation-4x4-v002.png` | quatre bandes ImageGen ; attaque régénérée avec rayon court non coupé | marche lourde, télégraphe/beam, hit et effondrement du Boss | `vacuum_boss_frames.tres` |
| `enemies/industrial_toxic/vacuum-pilot-saboteur-animation-4x4-v002.png` | quatre bandes ImageGen séparées | sprint, armement/lunge, hit et burnout du Saboteur | `vacuum_pilot_saboteur_frames.tres` |

Lot approuvé le 2026-08-28 : cinq archétypes, 88 poses et sept atlas. Les
v001 restent versionnés mais ne sont plus référencés par les `SpriteFrames`.
Sources, prompt set final, trois générations rejetées, recette, provenance,
manifeste, revues, aperçus et QA : lot `enemy-animation-roster-v002` sous
`pipeline/assets/`. Validation :
`ENEMY_ANIMATION_ROSTER_V002_VALIDATION: PASS` et
`ENEMY_ANIMATION_ROSTER_V002_TEST: PASS`.

## Imports historiques non actifs

Les fichiers `soil-*.png` et `surface-*.png` sans préfixe `toxic-` proviennent
de `worms-revisite`. Ils ont servi à valider le pipeline initial mais ne sont
plus référencés par la Resource active. Ils pourront être archivés après
confirmation visuelle des textures v001.
