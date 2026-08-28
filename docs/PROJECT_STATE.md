# État courant du projet

Dernière mise à jour : 2026-08-28

## Vision stable

Run-and-gun 2D solo à visée arcade classique. Univers militaire criard et
extravagant, mélange de spectacle guerrier excessif et de comédie destructrice.
Les ennemis sont de petits extraterrestres vivants enfermés dans des coques
massives d'aspirateurs-scaphandres à longues trompes.

Le projet suit une architecture editor-first : scènes, Nodes, Resources,
Inspector, signaux et AnimationPlayer avant le code spécifique.
Le pipeline de fabrication des assets est isolé de Godot par `.gdignore` ;
seuls les livrables publiés sous `art/` entrent dans `res://`.
La doctrine complète est une instruction permanente du dépôt via `AGENTS.md`.
Elle impose une autorité unique par donnée et les quatre questions
autorité/auteur/correspondance/validation avant toute implémentation.
Le Transform du Node placé dans une scène maîtresse est souverain : les systèmes
dérivés suivent translation, rotation, échelle non uniforme et miroir.

## Fonctionnel dans Godot

- Boot Flow, Start Flow et navigation locale sans Autoload ;
- galerie des sept planches de direction artistique ;
- écran de mission prototype avec HUD ;
- cet écran consomme la carte canonique par `MissionMapDefinition` et
  `MissionMapHost2D` ; l'ancienne scène autonome `levels/prototype` a été
  retirée ;
- système de cartes par `MissionMapDefinition`, `MissionMapCatalog`,
  `MissionMapRoot2D` et `MissionMapHost2D` ;
- première carte canonique `toxic_coast`, dimensions 3840 × 720 ;
- arborescence auteur clarifiée : `Visual` et `Gameplay` portent le contenu
  placé, `Runtime` sépare Actors/Projectiles/Effects/DestructibleTerrain et
  `EditorPreview` regroupe uniquement les aides visibles dans l'éditeur ;
- dans `Gameplay`, `PlayerSpawnPoints`, `EncounterMarkers` et `CombatGates`
  remplacent les anciens noms ambigus ; l'écran regroupe ses cinq services sous
  `RuntimeSystems` ;
- trois segments auteurs visibles : débarquement, pont acide et fonderie ;
- spawns, rencontres, dangers, sorties et limites caméra visibles ;
- terrain destructible produit depuis les zones auteur ;
- quatre scènes modulaires de sol permanent dont le même contour alimente le
  visuel texturé et la collision ;
- scène canonique `GroundPiece2D` glissable avec modes Permanent, Carvable et
  Breakable visibles dans l'Inspector ;
- catalogue Côte toxique extensible pour l'édition des niveaux, avec quatre
  scènes Ground Pieces publiées aujourd'hui et résolues par `piece_id` stable ;
- corniche illustrée intégrée en mode Carvable sous
  `Gameplay/GroundPieces` ;
- pièces Carvable librement transformables dans l'éditeur ; couleur, masque et
  collisions suivent rotation, miroir et échelle non uniforme ;
- seconde corniche auteur restaurée à −35° dans Côte toxique ;
- profil Breakable externe de la corniche prêt à l'emploi ; une instance passée
  en Breakable reçoit les tirs, change d'image sous 35 % de PV puis conserve une
  ruine sans collision à zéro PV ;
- composition des PNG et masques de plusieurs Ground Pieces dans le terrain
  destructible global, avec cratères continus entre leurs raccords ;
- style de sol permanent partagé et réglable par Resource dans l'Inspector ;
- masque alpha et collisions par chunks de 128 px ;
- cratères locaux sans reconstruction du bitmap complet ;
- scène canonique `Explosion2D` orchestrée par `AnimationPlayer` ;
- `ExplosionData` éditable pour terrain, combat, timing et palette ;
- impact d'explosion relié au terrain, dégâts radiaux autonomes par
  `apply_damage` et événement `target_damaged` après acceptation ;
- joueur canonique contrôlable avec CharacterBody2D ;
- entrées unifiées clavier, souris, manette et téléphone via l'Input Map ;
- visée libre à la souris et au stick droit, sans casser la visée arcade ;
- commandes tactiles responsive visibles dans la scène d'écran et masquées
  automatiquement hors écran tactile ;
- composants Movement, Aim et Health visibles dans le SceneTree ;
- trois Resources-panneaux pour locomotion, visée arcade et intégrité ;
- spawn runtime depuis le marqueur auteur et HUD relié au HealthComponent ;
- corps joueur raster via AnimatedSprite2D et Resource SpriteFrames ;
- canon modulaire séparé via AimPivot, WeaponSprite et socket Muzzle ;
- canon de campagne jouable avec tir automatique sur `J` ou `X` ;
- les impacts du canon creusent localement les surfaces Carvable avec un rayon
  réglé dans `field_round.tres`, façon Worms ;
- `WeaponData`, `ProjectileData`, projectile Area2D rapide, flash de bouche et
  impact orchestré par AnimationPlayer ;
- correspondance d'explosion optionnelle dans `ProjectileData`, permettant à
  une future munition de choisir scène et style au point d'impact sans modifier
  la balle de campagne actuelle ;
- spawner de mission découplant le joueur du conteneur `Runtime/Projectiles` ;
- caméra de mission unique avec look-ahead, limites et progression irréversible
  vers la droite ;
- trois profondeurs de décor avec parallaxe distincte ;
- panoramas répétés à leur résolution native sur toute la progression ;
- arrière-plan, midground transparent, foreground transparent et matières de
  sol propres au projet intégrés à Côte toxique.
- cycle de marche du Vacuum Trooper publié en huit poses de 160 ms, normalisé
  sur frames 256 × 192 et root commun `[128, 180]` ;
- impacts et mort du Vacuum Trooper publiés sur huit frames 256 × 192 au même
  root que la marche ; `hit` suspend puis rend la patrouille, `death` ouvre la
  coque, éjecte le pilote et diffère la suppression jusqu'à sa dernière pose ;
- attaque toxique publiée en huit phases, projectile lent en quatre frames et
  impact en six frames ; la correspondance gameplay est portée par
  `Components/Attack` et `ProjectileData` ;
- bestiaire ennemi v002 publié pour les cinq scènes canoniques : Vacuum Trooper,
  Grunt Siphoner, Drone volant, Boss lourd et pilote Saboteur ; les quatre rôles
  industriels possèdent quatre poses biomécaniques par action et le Trooper
  conserve huit poses de marche et d'attaque, soit 88 poses sur sept atlas ;
- la patrouille comprend désormais un mode volant réglable par profil ; le
  Drone oscille verticalement sans dupliquer les règles dans sa scène ;
- l'attaque ennemie choisit projectile ou contact depuis son composant : le
  Grunt, le Drone et le Boss tirent, le Saboteur charge puis s'autodétruit ;
- le Vacuum Trooper éjecte réellement un `vacuum_pilot_saboteur` autonome à sa
  mort via son composant `Ejection` visible dans le SceneTree ;
- scène canonique `EnemyCharacter2D` composée de Patrol, Health et Animation,
  profil et catalogue Resources éditables dans l'Inspector ;
- chaîne de cadence Resource-first publiée : `EnemySpawnPatternData` décrit une
  formation, `WaveData` son beat et sa transition, `EncounterData` compose les
  vagues, puis `MapEncounterMarker2D` possède uniquement placement et activation ;
- `MissionEncounterController` déroule actuellement quatre occurrences, neuf
  vagues et quinze apparitions sur Côte toxique, dont `LandingCadence2`
  non bloquante ajoutée dans la scène auteur ; le spawner ne fait plus que
  traduire chaque archétype en scène canonique ;
- courbe jouable : pression puis respiration au débarquement, Gauntlet avec
  escalade terrestre/aérienne au pont, pression puis payoff Boss à la fonderie ;
- trois `MissionCombatGate2D` visibles sous `Gameplay/CombatGates` bloquent
  physiquement chaque frontière et s'ouvrent à la résolution correspondante ;
- le HUD annonce rencontre, beat et numéro de vague actifs ; les formations
  possèdent aussi un aperçu coloré dans l'éditeur ;
- la Brute/Boss possède une Hurtbox élargie conforme à sa coque visible : les
  tirs sur le bord supérieur et la trompe ne traversent plus la silhouette ;
  une barre de Boss reliée à `EnemyHealthComponent` confirme chaque dégât ;
- joueur et ennemis partagent `ActorGroundingComponent`, avec GroundAnchor,
  GroundProbe et ombre projetée sur le vrai collider World ;
- deux sondes d'appui mesurent chaque pente et `SlopeAlignment` incline le
  sprite autour du root des pieds sans incliner collision, arme ou visée ;
- les collisions d'acteurs rejoignent GroundAnchor par un point inférieur
  central ; les larges rectangles qui font flotter les pieds sont interdits ;
- la corniche naturelle utilise un contour auteur dont le bord marchable est
  visible en vert dans l'éditeur ; ses pieds suivent désormais la pente peinte ;
- trois nouvelles Ground Pieces Côte toxique glissables : bloc bunker,
  passerelle industrielle et pont-tuyau, chacune réglable par instance en
  Permanent, Carvable ou Breakable ;
- bassin acide glissable piloté par `HazardData`, avec zone et dégâts réglables ;
- baril explosif glissable piloté par `ExplosivePropData`, destructible au tir
  et relié à la scène d'explosion canonique ;
- caisse militaire glissable avec états fermé/ouvert, vide pour cette première
  version, ouvrable au tir ou par `player_interact` (`F` / manette Y) selon son
  `SupplyCrateData` ;
- `MissionActorSpawner2D` recrée le joueur après sa mort avec délai configurable
  et `respawn_spawn_id`, tandis que `PlayerHealthComponent.reset_health()` reste
  l'autorité unique des PV réinitialisés ;
- deux `MissionCheckpoint2D` visibles sous `Gameplay/Interactions` font évoluer
  le spawn de reprise vers le pont puis la fonderie ;
- `MissionRunController` suit les rencontres auteur obligatoires, verrouille la
  sortie jusqu'à leur élimination puis affiche le résultat de victoire lorsque
  le joueur atteint `MissionEnd` ;
- `ActorStateMachineComponent` est maintenant présente sur le joueur et les
  ennemis avec les états communs `IDLE`, `RUN`, `ATTACK`, `SHOOT`, `JUMP`,
  `FALL`, `HURT`, `DEAD` et
  `RESPAWN` ; les placeholders futurs devront reprendre cette brique ;

## Autorités actuelles

- identité et contrat d'une carte : `MissionMapDefinition.tres` ;
- placement final : scène maîtresse de carte ;
- matière destructible initiale : `Gameplay/DestructibleZones` ;
- matière runtime : masque alpha de `DestructibleTerrain2D` ;
- apparence du terrain : `DestructibleTerrainProfile.tres` ;
- définition visuelle et géométrique d'une pièce : `GroundPieceDefinition.tres` ;
- liste extensible des pièces proposées aux auteurs de niveaux : tableau
  `pieces` de `GroundKitCatalog.tres` ; le nombre actuel d'entrées n'est pas un
  contrat et augmentera avec les futurs kits et niveaux ;
- mode et placement d'une pièce : son instance `GroundPiece2D` dans la scène
  maîtresse, y compris son Transform complet ; état creusé :
  `DestructibleTerrain2D` ;
- forme d'un sol permanent : `GroundModule2D.outline` dans la scène maîtresse ;
- matières d'un sol permanent : `PermanentGroundStyle.tres` ;
- paramètres d'une explosion : `ExplosionData.tres` ;
- timing et représentation d'une explosion : `Explosion2D.tscn` ;
- définition d'un bassin dangereux : sa `HazardData.tres` ; placement final :
  instance de sa scène dans la map ;
- définition du baril explosif : `toxic_explosive_barrel.tres` ; état runtime :
  son `ExplosiveProp2D` ; origine de détonation : `ExplosionOrigin` dans sa
  scène ; style : `ExplosionData` injectée ;
- définition et modes d'ouverture de la caisse : `military_supply_crate.tres` ;
  état fermé/ouvert : instance `SupplyCrate2D` ; futur contenu : système de loot
  séparé, encore absent ;
- locomotion du joueur : `PlayerMovementProfile.tres` ;
- visée arcade : `PlayerAimProfile.tres` et `PlayerAimComponent` au runtime ;
- correspondance périphériques → actions : Input Map de `project.godot` ;
- disposition tactile : `ui/mobile/mobile_controls.tscn` ; visibilité runtime :
  `MobileControls` selon `DisplayServer` ;
- vie courante : `PlayerHealthComponent` ; maximum et invulnérabilité :
  `PlayerHealthProfile.tres` ;
- placement du joueur : `MapSpawnPoint2D` ; correspondance d'instanciation :
  `MissionActorSpawner2D` ;
- progression du respawn : `MissionCheckpoint2D` placé dans la scène maîtresse
  et son `spawn_id` correspondant ; état courant : `respawn_spawn_id` du
  `MissionActorSpawner2D` ;
- objectifs de victoire : `enabled` du `MapEncounterMarker2D` et
  `blocks_mission_exit` de son `EncounterData`, plus le `Marker2D` de sortie ;
  état runtime : `MissionEncounterController`, puis `MissionRunController` ;
- cadence : `EnemySpawnPatternData → WaveData → EncounterData` sous
  `maps/encounters/data/` ; placement : Marker de la scène maîtresse ; état des
  populations et vagues : `MissionEncounterController` ;
- définition du canon : `primary_field_cannon.tres` ; définition de sa munition :
  `field_round.tres` ; cadence runtime : `PlayerWeaponComponent` ;
- origine du tir : `Visuals/AimPivot/Muzzle` ; correspondance vers la map :
  `MissionProjectileSpawner2D` ;
- comportement caméra : `RunAndGunCameraProfile.tres` ; progression runtime :
  `MissionCameraRig2D` ; limites : `MissionMapRoot2D.camera_bounds` ;
- vitesse relative d'un plan visuel : son Node `Parallax2D` dans la scène de map ;
- ordre des planches : `GalleryCatalog.tres` ;
- provenance des bitmaps : `art/ASSET_MANIFEST.md` ;
- sources, recettes et intermédiaires d'assets : `pipeline/assets/` ;
- identité, marche, impacts et mort publiés du Vacuum Trooper : atlas sous
  `art/`, sources, profils d'animation et QA des lots dédiés sous
  `pipeline/assets/` ;
- attaque, projectile et impact toxiques publiés du Vacuum Trooper : atlas sous
  `art/`, sources, profils, recettes, QA et revues sous `pipeline/assets/` ;
- réglages d'un ennemi : sa Resource `EnemyArchetypeProfile` sous
  `characters/enemies/data/` ; correspondance du marqueur vers les cinq scènes
  publiées : `enemy_catalog.tres` ; placement et formation :
  `MapEncounterMarker2D` dans la scène maîtresse ;
- pose active et timings : `SpriteFrames` de chaque scène ; déclenchement et
  effet de l'attaque : `EnemyAttackComponent` ; éjection du Trooper :
  `EnemyEjectionComponent` et sa `PackedScene` de pilote ;
- root des pieds, projection et ombre : `ActorGroundingComponent` dans chaque
  scène canonique ; Permanent/Breakable : contour et surface de marche de la
  `GroundPieceDefinition` ; Carvable : masque et collisions runtime ;
- frontière pipeline/runtime : `docs/assets/ASSET_PIPELINE_CONTRACT.md` ;
- doctrine d'intégration Godot :
  `docs/architecture/GODOT_EDITOR_FIRST_RESOURCE_FIRST.md` ;
- vocabulaire des classes et suffixes :
  `docs/architecture/GLOSSARY_CLASSES_AND_VOCABULARY.md` ;
- décisions issues de la recherche d'architecture :
  `docs/research/GAME_ARCHITECTURE_RESEARCH.md`.

## Projection validée des catalogues publiés

Cette liste est une projection documentaire, jamais une seconde autorité. Les
Resources `.tres` restent souveraines ; le test de contrat compare
dynamiquement leurs identifiants avec ce bloc afin qu'un ajout ou un retrait de
contenu impose la mise à jour de la mémoire du projet sans figer la taille des
catalogues.

<!-- CATALOG_PROJECTION_BEGIN -->
- `mission_maps` : `toxic_coast`
- `enemy_archetypes` : `vacuum_boss`, `vacuum_flying`, `vacuum_grunt`, `vacuum_pilot_saboteur`, `vacuum_trooper`
- `ground_pieces/toxic_coast` : `industrial_catwalk_medium`, `military_bunker_block_medium`, `natural_ledge_medium`, `toxic_pipe_bridge_medium`
<!-- CATALOG_PROJECTION_END -->

## Protection opérationnelle

- dépôt Git initialisé sur la branche `main` ;
- dépôt distant de référence : `https://github.com/azemann/jeuweb.git` ;
- caches Godot, états locaux Codex, captures, exports et journaux exclus par
  `.gitignore` ;
- état animation contrôlé par le validateur raster v002 et son contrat headless
  dédié ; la suite globale actuelle de 26 contrats est verte après migration de
  l'arborescence auteur et prise en compte de `LandingCadence2`.

## Limites connues

- vitesse, portée, dégâts et collision du projectile toxique sont portés par sa
  `ProjectileData`, tandis que la cadence et la portée de déclenchement restent
  réglées sur `EnemyAttackComponent` ; leur équilibrage gameplay reste à faire ;
- les checkpoints n'ont encore aucun feedback visuel ou sonore au passage ;
- l'écran de victoire propose uniquement le retour au menu : score, temps,
  récompenses et enchaînement vers une mission suivante restent absents ;
- la patrouille ne tremble plus : ses origines 700/840 sont fixées avant
  `_ready()` et ses demi-tours ne peuvent plus alterner chaque frame ;
- le Boss réutilise encore le projectile toxique commun malgré sa pose de blast
  magenta ; un projectile lourd dédié reste à produire ;
- les pilotes éjectés sont des acteurs hostiles autonomes mais ne comptent pas
  parmi les objectifs obligatoires de la mission ; aucune règle de récompense
  n'est encore définie ;
- les types `Kill Room`, `Arena` et `Set Piece` sont nommés et configurables,
  mais leurs verrous caméra et orchestrations audiovisuelles restent à publier ;
- le premier canon n'a encore ni audio, ni recul du corps, ni secousse caméra ;
- la munition de campagne utilise un petit impact dédié, pas l'explosion lourde
  canonique réservée aux obus et éléments explosifs ;
- l'impulsion radiale est publiée avec `target_damaged`, mais les acteurs ne
  possèdent pas encore de contrat commun pour la consommer physiquement ;
- les poses v002 sont découpées proprement et structurées en phases lisibles ;
  leur continuité jouée à taille réelle doit encore être revue sur la cadence
  actuelle de quinze apparitions ;
- `LandingCadence` et `LandingCadence2` possèdent actuellement de grands seuils
  d'activation proches du départ : leur démarrage quasi simultané est valide
  techniquement mais doit être confirmé ou rééquilibré en jeu ;
- les quatre `TileMapLayer` de Côte toxique sont prêts mais sans TileSet ;
- le catalogue Côte toxique publie actuellement quatre pièces réutilisables :
  corniche naturelle, bloc bunker, passerelle industrielle et pont-tuyau ; ce
  recensement décrit uniquement l'état présent et doit s'enrichir pour
  l'édition des futurs niveaux ; le bassin acide, le baril explosif et la caisse
  restent des scènes glissables séparées du catalogue de terrain ;
- les premiers modules de sol permanent réutilisent encore les textures
  génériques du terrain ; le pont et la fonderie n'ont pas encore leurs styles
  ou scènes d'architecture spécifiques ;
- les trois segments utilisent encore les mêmes panoramas répétés ; le pont et
  la fonderie n'ont pas encore leurs modules visuels distinctifs ;
- les anciens fichiers de texture empruntés à `worms-revisite` restent présents
  dans le dossier mais ne sont plus référencés par le profil actif ;
- aucun titre définitif, aucun logo définitif, aucun audio ;
- les commandes téléphone sont fonctionnelles et responsive, mais leur confort
  sur appareils physiques et les safe areas doivent encore être validés sur un
  panel Android/iOS réel ;

## Prochaine tranche recommandée

Jouer la cadence actuelle de quinze apparitions et décider si
`LandingCadence2` constitue une vraie seconde rencontre ou seulement un essai de
placement. Ajuster ensuite ses seuils et offsets depuis l'Inspector/Resources,
puis reprendre la stabilisation runtime du terrain destructible et des
références de projectiles avant le Set Piece du Boss.


## Validations à exécuter

```bash
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/foundation_smoke_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/map_contract_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/destructible_terrain_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/explosion_integration_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/asset_pipeline_contract_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/player_contract_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/player_input_contract_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/player_asset_integration_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/mission_camera_progression_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/mission_run_contract_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/encounter_cadence_contract_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/permanent_ground_module_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/weapon_projectile_integration_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/class_glossary_contract_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/project_state_catalog_contract_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/enemy_animation_roster_v002_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --quit-after 240
python3 pipeline/assets/tools/validate_vacuum_trooper_hit_death_candidate.py
python3 pipeline/assets/tools/validate_vacuum_trooper_attack_candidate.py
python3 pipeline/assets/tools/validate_toxic_pressure_candidates.py
python3 pipeline/assets/tools/validate_industrial_toxic_enemy_roster.py
python3 pipeline/assets/tools/validate_enemy_animation_roster_v002.py
```

Dernière validation complète : 2026-08-28, les 26 contrats headless passent
après la migration des branches auteur/runtime et des scènes de personnages.
`LandingCadence2` est valide, non bloquante et comprise dynamiquement dans le
contrat de cadence.
Capture OpenGL réelle contrôlée sur `NaturalLedgeMedium` après 90 frames
d'atterrissage : marche, impact, éjection et épave suivent la pente.
