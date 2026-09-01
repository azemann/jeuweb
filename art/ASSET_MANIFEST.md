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
| `concepts/da-08-abyssal-mission.png` | ImageGen intégré, références DA-01/DA-03 et pack abyssal `e2b81a5` | Mission 2, ruines techno-abyssales et kit de structures | référence |

La planche DA-08 reste une référence de style et de vocabulaire. Elle ne doit
pas être découpée directement en sprites gameplay ; les pièces publiées passent
par `pipeline/assets/` puis par `GroundPieceDefinition`.

## Côte toxique — assets runtime v001

| Fichier | Création | Intention | Intégration |
|---|---|---|---|
| `maps/toxic_coast/toxic-coast-far-background-v001.png` | imagegen intégré ; prompt : panorama 8:3, ciel, océan et forteresse lointaine, aucun gameplay | fond opaque historique | non référencé depuis backgrounds v002 |
| `maps/toxic_coast/toxic-coast-midground-v001.png` | imagegen intégré ; prompt : jungle industrielle intermédiaire sur alpha transparent | plan intermédiaire commun | `Visual/MidgroundParallax/IndustrialJungle` |
| `maps/toxic_coast/toxic-coast-foreground-v001.png` | imagegen intégré ; prompt : tuyaux, végétation et débris aux bords sur alpha transparent | parallaxe historique | non référencé depuis backgrounds v002 |
| `maps/toxic_coast/toxic-coast-foreground-v002.png` | édition ImageGen lisible du cadre v001, alpha transparent | cadre proche commun | `Visual/ForegroundParallax/EdgeFraming` |
| `terrain/toxic_coast/toxic-soil-shallow-v001.png` | dérivé ImageMagick de la source maître | couche haute | `toxic_coast_terrain.tres` |
| `terrain/toxic_coast/toxic-soil-main-v001.png` | dérivé ImageMagick de la source maître | matière centrale | `toxic_coast_terrain.tres` |
| `terrain/toxic_coast/toxic-soil-deep-v001.png` | dérivé ImageMagick de la source maître | matière profonde | `toxic_coast_terrain.tres` |
| `terrain/toxic_coast/toxic-surface-intact-v001.png` | dérivé ImageMagick de la source maître | bord intact | `toxic_coast_terrain.tres` |
| `terrain/toxic_coast/toxic-surface-fresh-v001.png` | dérivé ImageMagick de la source maître | bord de cratère | `toxic_coast_terrain.tres` |

Source maître hors Godot :
`pipeline/assets/sources/imagegen/toxic_coast/toxic-soil-master-v001.png`.
Recette : `pipeline/assets/recipes/toxic_coast_v001.md`.

## HUD — Toxic Commando v001

| Fichier | Origine | Intention | Intégration |
|---|---|---|---|
| `ui/hud/toxic_commando/frames/player-status-frame-v001.png` | découpe normalisée de la planche HUD Toxic Commando | portrait, vie, armure et slots de statut | `MissionHUD/PlayerStatus` |
| `ui/hud/toxic_commando/frames/weapon-status-frame-v001.png` | même lot | arme équipée et munitions | `MissionHUD/WeaponStatus` |
| `ui/hud/toxic_commando/frames/objective-frame-v001.png` | même lot | objectif et beat courant | `MissionHUD/ObjectiveStatus` |
| `ui/hud/toxic_commando/frames/boss-health-frame-v001.png` | même lot | intégrité du Boss | `MissionHUD/BossStatus` |
| `ui/hud/toxic_commando/frames/overdrive-frame-v001.png` | même lot | durée de surcharge | `MissionHUD/OverdriveStatus` |
| `ui/hud/toxic_commando/frames/notification-frame-v001.png` | même lot | résultat et notification | `MissionHUD/ResultPanel` |
| `ui/hud/toxic_commando/portraits/player-portrait-v001.png` | dérivé de la pose idle canonique joueur | identité du joueur dans le grand cercle | `MissionHUDTheme.player_portrait` |
| `ui/hud/toxic_commando/icons/health-icon-v001.png` | normalisation 160 × 160 de la planche d'icônes | repère vie | `MissionHUDTheme.health_icon` |
| `ui/hud/toxic_commando/icons/armor-icon-v001.png` | même lot | repère armure | `MissionHUDTheme.armor_icon` |
| `ui/hud/toxic_commando/icons/ammo-icon-v001.png` | même lot | repère munitions | `MissionHUDTheme.ammo_icon` |
| `ui/hud/toxic_commando/icons/overdrive-icon-v001.png` | même lot | vocabulaire surcharge réutilisable | `MissionHUDTheme.overdrive_icon` |
| `ui/hud/toxic_commando/icons/grenade-icon-v001.png` | même lot | vocabulaire grenade futur | `MissionHUDTheme` |
| `ui/hud/toxic_commando/icons/objective-icon-v001.png` | même lot | repère objectif | `MissionHUDTheme.objective_icon` |
| `ui/hud/toxic_commando/icons/boss-icon-v001.png` | même lot | vocabulaire Boss réutilisable hors cadre intégré | `MissionHUDTheme.boss_icon` |
| `ui/hud/toxic_commando/icons/checkpoint-icon-v001.png` | même lot | vocabulaire checkpoint futur | `MissionHUDTheme` |
| `ui/hud/toxic_commando/icons/weapon-icon-v001.png` | même lot | vocabulaire équipement futur | `MissionHUDTheme` |
| `ui/hud/toxic_commando/icons/poison-icon-v001.png` | même lot | futur statut poison | `MissionHUDTheme` |
| `ui/hud/toxic_commando/icons/electric-icon-v001.png` | même lot | futur statut électrique | `MissionHUDTheme` |
| `ui/hud/toxic_commando/icons/fire-icon-v001.png` | même lot | futur statut feu | `MissionHUDTheme` |

Sources immuables, outil de découpe, recette, manifeste, provenance et planche
de contrôle : lot `toxic-commando-hud-v001` sous `pipeline/assets/`.

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

## Mission 2 — kit de Ground Pieces abyssal v001

| Fichier | Création | Intention | Intégration |
|---|---|---|---|
| `terrain/pieces/abyssal/black-coral-platform-medium-v001.png` | pack source abyssal `e2b81a5`, nettoyage alpha puis normalisation pipeline 768 × 384 | plateforme principale du blockout Mission 2 | `abyssal_black_coral_platform_medium.tres` → scène glissable |
| `terrain/pieces/abyssal/black-coral-slope-connector-v001.png` | dérivé pipeline de la plateforme de corail noir | raccord incliné pour tester pentes et transitions | `abyssal_black_coral_slope_connector.tres` → scène glissable |
| `terrain/pieces/abyssal/tide-engine-bridge-medium-v001.png` | pack source abyssal `e2b81a5`, nettoyage alpha puis normalisation pipeline 768 × 384 | passerelle techno-abyssale de Mission 2 | `abyssal_tide_engine_bridge_medium.tres` → scène glissable |
| `terrain/pieces/abyssal/destructible-pearl-wall-medium-v001.png` | pack source abyssal `e2b81a5`, nettoyage alpha puis normalisation pipeline 768 × 384 | mur nacré destructible pour portes, secrets et tests Breakable | `abyssal_destructible_pearl_wall_medium.tres` → scène glissable |

Lot publié le 2026-09-01 depuis le pack candidat
`jeuweb-abyssal-asset-pack-v001`, branche `agent/ajoute-serre-mecanique`,
commit `e2b81a5`. Sources locales, recette, manifeste, provenance et QA :
lot `abyssal-ground-kit-v001` sous `pipeline/assets/`. Statut : intégré pour
blockout auteur ; les contours, pivots et raccords restent à ajuster après
test direct dans l'éditeur.

### Mission 2 — kit de Ground Pieces abyssal v002

| Famille | Fichiers publiés | Intégration Godot |
|---|---|---|
| Sols corail | `black-coral-platform-small-v002.png`, `black-coral-platform-large-v002.png`, `black-coral-floor-cap-left-v002.png`, `black-coral-floor-cap-right-v002.png` | quatre `GroundPieceDefinition` et scènes glissables |
| Raccords | `black-coral-slope-up-v002.png`, `black-coral-slope-down-v002.png`, `black-coral-step-low-v002.png`, `black-coral-step-high-v002.png` | quatre scènes de parcours pour pentes et marches |
| Structures | `tide-engine-bridge-short-v002.png`, `tide-engine-bridge-long-v002.png`, `tide-engine-support-pillar-v002.png`, `abyssal-temple-arch-large-v002.png`, `abyssal-temple-column-intact-v002.png`, `abyssal-temple-column-broken-v002.png` | six scènes de ponts, supports et ruines |
| Destructibles | `destructible-pearl-wall-small-v002.png`, `destructible-pearl-wall-large-v002.png` | deux scènes Breakable avec profils externes |

Lot publié le 2026-09-01 par
`pipeline/assets/tools/process_abyssal_ground_kit.py`. Les 16 sorties v002
étendent le catalogue abyssal à 20 pièces et servent au blockout deux actes de
Mission 2. Statut : intégré pour level design ; revue visuelle et ajustement
fin des contours à faire dans l'éditeur.

### Mission 2 — grands socles générés v004

| Fichier | Création | Intention | Intégration |
|---|---|---|---|
| `terrain/pieces/abyssal/v004_large_structures/generated-coral-machine-slab-v004.png` | ImageGen intégré puis normalisation pipeline | grand sol principal corail-machine | `abyssal_generated_coral_machine_slab.tres` |
| `terrain/pieces/abyssal/v004_large_structures/generated-tide-engine-floor-v004.png` | ImageGen intégré puis normalisation pipeline | plancher moteur de marée | `abyssal_generated_tide_engine_floor.tres` |
| `terrain/pieces/abyssal/v004_large_structures/generated-black-coral-slab-v004.png` | ImageGen intégré puis normalisation pipeline | grand socle corail noir | `abyssal_generated_black_coral_slab.tres` |
| `terrain/pieces/abyssal/v004_large_structures/generated-ruin-engine-slab-v004.png` | ImageGen intégré puis normalisation pipeline | socle ruine mécanique | `abyssal_generated_ruin_engine_slab.tres` |
| `terrain/pieces/abyssal/v004_large_structures/generated-right-coral-engine-slab-v004.png` | ImageGen intégré puis normalisation pipeline | socle moteur de fin d'acte | `abyssal_generated_right_coral_engine_slab.tres` |

Lot publié le 2026-09-01 par
`pipeline/assets/tools/process_abyssal_generated_large_structures.py`. Il
remplace la v003 refusée : l'extraction directe de DA-08 créait plusieurs
hauteurs de sol visibles dans une même pièce. Les grands socles v004 portent la
base game art/level design de Mission 2 ; les pièces v002 restent des raccords
et compléments.

## Joueur — assets runtime v001

| Fichier | Création | Intention | Intégration |
|---|---|---|---|
| `characters/player/player-body-key-poses-v001.png` | imagegen intégré puis extraction alpha, canevas fixe et atlas 4 × 3 déterministes | 12 poses clés du corps sans arme | `player_visual_frames.tres` → `Presentation/BodySprite` |
| `weapons/player/player-primary-cannon-v001.png` | imagegen intégré puis normalisation 768 × 384 | canon modulaire séparé du corps | `Visuals/AimPivot/WeaponSprite` |

Lot approuvé le 2026-08-25. Sources, prompts, profil, manifeste, provenance et
QA : `pipeline/assets/{sources,recipes,profiles,manifests,provenance,working}`.
Les poses clés sont intégrées ; leur continuité temporelle reste provisoire et
sera affinée frame par frame.

## Canon de campagne — projectile et impact v001

| Fichier | Création | Intention | Intégration |
|---|---|---|---|
| `weapons/projectiles/field/field-round-v001.png` | ImageGen intégré puis normalisation pipeline 384 × 192 | munition bitmap du canon de campagne, orientée vers la droite | `field_round.tres` → `FieldRound2D/Visual` |
| `effects/weapons/field/field-round-impact-3x2-v001.png` | ImageGen intégré puis découpe 3 × 2 en cellules 256 × 256 | impact animé court de la munition de campagne | `field_round_impact_frames.tres` → `FieldRoundImpact2D` |

Lot approuvé le 2026-08-31 à partir des candidates techniques du lot
`projectile-impact-lot-v001`. SHA-256 publiés :
`0b5a8814905e6e8710667d9c52e34372b7fee63655e49112d7bd23f290d6b2cd` et
`6e25618ecc70bb78fae1f9295fea9d2fdc05e5b3a27f9a80106a056493fb4e9c`.
Sources, recette, manifeste, provenance, exports et QA restent sous
`pipeline/assets/`.

## Pickups — soin v001

| Fichier | Création | Intention | Intégration |
|---|---|---|---|
| `pickups/health-injector-v001.png` | candidate du megapack industriel toxique, sélection puis normalisation déterministe 192 × 192 | injecteur de soin immédiatement identifiable sur alpha réel | `health_injector.tres` → `HealthInjector2D` |

Lot publié le 2026-08-29. Source, recette, processeur, manifeste, provenance et
QA : lot `health-injector-pickup-v001` sous `pipeline/assets/`. La scène
canonique et son `PickupData` sont validées par
`pickup_interaction_contract_test.gd`.

## Expansion industrielle toxique v001

Le megapack contient 38 candidats. La matrice d'intégration en exclut 11 déjà
intégrés ou supplantés et publie exactement 27 sorties inédites.

| Famille | Fichiers publiés | Intégration Godot |
|---|---|---|
| Architecture (5) | `acid-bridge-abutment-v001.png`, `destructible-military-wall-v001.png`, `guard-tower-module-v001.png`, `vacuum-foundry-platform-v001.png`, `walk-under-pipe-arch-v001.png` | cinq `GroundPieceDefinition` et scènes glissables |
| Props (7) | `ammo-resupply-locker-v001.png`, `field-medical-station-v001.png`, `military-floodlight-v001.png`, `portable-barricade-v001.png`, `proximity-blast-mine-v001.png`, `radio-relay-antenna-v001.png`, `toxic-pressure-vent-v001.png` | stations, WorldProps, Ground Piece Breakable, mine et Hazard |
| Pickups (3) | `ammo-drum-v001.png`, `armor-plate-v001.png`, `overdrive-vacuum-core-v001.png` | trois `PickupData` consommées par CombatInventory |
| Armes (4) | `acid-sprayer-v001.png`, `electric-coil-rifle-v001.png`, `vacuum-imploder-cannon-v001.png`, `demolition-launcher-v001.png` | quatre `WeaponData` équipables par armurerie |
| Projectiles (4) | `acid-capsule-v001.png`, `electric-coil-bolt-v001.png`, `vacuum-implosion-core-v001.png`, `demolition-rocket-v001.png` | quatre `ProjectileData` et scènes texturées |
| Impacts (4) | atlas `acid`, `electric`, `vacuum-implosion` et `demolition`, chacun en 3 × 2 | quatre SpriteFrames et scènes `AnimatedProjectileImpact2D` |

Lot publié le 2026-08-30 par
`pipeline/assets/tools/process_industrial_toxic_expansion.py`. Matrice 11/27,
recette, manifeste, provenance, exports et QA sont conservés sous
`pipeline/assets/`. La validation Godot est portée par
`industrial_toxic_expansion_contract_test.gd` ; aucun des 11 doublons exclus
n'a produit une seconde autorité runtime.

## Côte toxique — backgrounds segmentés v002

| Fichier | Intention | Intégration |
|---|---|---|
| `maps/toxic_coast/backgrounds/landing-zone-background-v002.png` | côte militaire occupée, radar et flotte aspirante | `Visual/SegmentBackgrounds/LandingZoneBackground` |
| `maps/toxic_coast/backgrounds/acid-bridge-background-v002.png` | ravin industriel, pont rompu et cascades acides | `Visual/SegmentBackgrounds/AcidBridgeBackground` |
| `maps/toxic_coast/backgrounds/vacuum-foundry-background-v002.png` | fonderie monumentale et réacteur d'implosion | `Visual/SegmentBackgrounds/VacuumFoundryBackground` |
| `maps/toxic_coast/backgrounds/transitions/landing-to-bridge-transition-v002.png` | raccord déterministe côte → ravin | frontière x=2560 |
| `maps/toxic_coast/backgrounds/transitions/bridge-to-foundry-transition-v002.png` | raccord déterministe ravin → fonderie | frontière x=5120 |

Sources générées avec l'outil ImageGen intégré le 2026-08-30, puis cadrées,
redimensionnées et assombries sous le couloir jouable par
`process_toxic_coast_segment_backgrounds.py`. Chaque sortie fait exactement
2560 × 720 et correspond à un acte sans répétition ; deux bandes 384 × 720
adoucisent les frontières. Recette, manifeste,
provenance, exports, contact sheet et QA : lot
`toxic-coast-segment-backgrounds-v002` sous `pipeline/assets/`.

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

## Boot et Start Flow — Industrial Toxic v001

| Famille | Fichiers publiés | Intégration |
|---|---|---|
| Backgrounds | `boot-radio-outpost-background-v001.png`, `loading-vacuum-turbine-background-v001.png`, `title-fortress-assault-background-v001.png`, `mission-select-archipelago-map-v001.png` | Boot, Start, loading de mission et futur Mission Select |
| Identité et cadres | `vacuum-faction-emblem-v001.png`, `blank-armored-title-plaque-v001.png`, `vertical-main-menu-frame-v001.png` | `BootStartFlowTheme` → scènes Boot/Start |
| Ornements | `previous-inactive-v001.png`, `previous-active-v001.png`, `locked-v001.png`, `divider-v001.png`, `lime-status-lamp-v001.png`, `magenta-status-lamp-v001.png` | flèche active reliée au focus ; autres éléments réservés aux états futurs réels |
| Marqueurs | `landing-marker-v001.png`, `pipeline-marker-v001.png`, `foundry-marker-v001.png`, `fortress-marker-v001.png`, `elite-marker-v001.png`, `completed-marker-v001.png` | vocabulaire publié du futur Mission Select, sans logique runtime fictive |

Lot ImageGen publié le 2026-08-30 par
`pipeline/assets/tools/process_boot_start_flow.py`. Les quatre backgrounds sont
préservés ; les éléments alpha sont normalisés et les deux planches 3 × 2 sont
découpées en douze livrables. Manifeste, provenance, recette, exports et planche
de revue : lot `industrial-toxic-boot-start-flow-v001` sous `pipeline/assets/`.
Tout texte visible reste natif Godot et n'est jamais peint dans ces images.

## Effets — explosions de barils v001

| Fichier | Intention | Intégration |
|---|---|---|
| `effects/explosions/barrel/barrel-small-explosion-4x2-v001.png` | détonation compacte, rapide et peu persistante | `barrel_small_explosion.tres` |
| `effects/explosions/barrel/barrel-standard-explosion-4x2-v001.png` | signature courante du baril toxique | `barrel_standard_explosion.tres` → `toxic_explosive_barrel.tres` |
| `effects/explosions/barrel/barrel-heavy-explosion-4x2-v001.png` | énorme volume de feu, double onde et longue fumée | `barrel_heavy_explosion.tres` |

Lot ImageGen publié le 2026-08-31. Chaque atlas mesure 1152 × 768, contient
huit cellules 288 × 384 sur alpha réel et alimente la scène canonique composée
`Explosion2D`. Recette, sources, exports, provenance, manifeste et QA : lot
`barrel-explosion-family-v001` sous `pipeline/assets/`.

## Imports historiques non actifs

Les fichiers `soil-*.png` et `surface-*.png` sans préfixe `toxic-` proviennent
de `worms-revisite`. Ils ont servi à valider le pipeline initial mais ne sont
plus référencés par la Resource active. Ils pourront être archivés après
confirmation visuelle des textures v001.
