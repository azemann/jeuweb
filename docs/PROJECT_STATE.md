# État courant du projet

Dernière mise à jour : 2026-09-01

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

- Boot Flow et Start Flow illustrés par la peau `industrial_toxic`, avec
  backgrounds dédiés, emblème, plaque de titre native, cadre de menu et
  indicateur magenta suivant réellement le focus clavier/manette ;
- navigation locale sans Autoload ;
- hiérarchie typographique commune portée par `game_ui_theme.tres` pour titres,
  légendes, boutons, valeurs HUD, objectifs, notifications et contrôles tactiles ;
- menu Start revu dans le renderer OpenGL réel en 1280 × 720 : cadre vertical au
  ratio 2:3, verre sombre local, boutons sans cartouches génériques et colonnes
  stables quand le focus change ;
- galerie des huit planches de direction artistique, dont DA-08 pour la Mission
  2 abyssale ;
- écran de mission prototype avec scène canonique `MissionHUD` ;
- cet écran consomme la carte canonique par `MissionMapDefinition` et
  `MissionMapHost2D` ; l'ancienne scène autonome `levels/prototype` a été
  retirée ;
- système de cartes par `MissionMapDefinition`, `MissionMapCatalog`,
  `MissionMapRoot2D` et `MissionMapHost2D` ;
- première carte canonique `toxic_coast`, dimensions 7680 × 720, composée en
  trois actes de 2560 px ;
- arborescence auteur clarifiée : `Visual` et `Gameplay` portent le contenu
  placé, `Runtime` sépare Actors/Projectiles/Effects/DestructibleTerrain et
  `EditorPreview` regroupe uniquement les aides visibles dans l'éditeur ;
- dans `Gameplay`, `PlayerSpawnPoints` et `EncounterMarkers` rendent la
  progression visible sans branche de porte physique ; l'écran regroupe ses cinq services sous
  `RuntimeSystems` ;
- trois segments auteurs visibles : débarquement, pont acide et fonderie ;
- spawns, rencontres, dangers, sorties et limites caméra visibles ;
- terrain destructible produit depuis les zones auteur ;
- quatre scènes modulaires de sol permanent dont le même contour alimente le
  visuel texturé et la collision ;
- scène canonique `GroundPiece2D` glissable avec modes Permanent, Carvable et
  Breakable visibles dans l'Inspector ;
- catalogue Côte toxique extensible pour l'édition des niveaux, avec dix scènes
  Ground Pieces publiées et résolues par `piece_id` stable ;
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
- cratères locaux sans reconstruction du bitmap complet ; masque et rendu sont
  immédiats, tandis que les chunks physiques sales sont dédupliqués puis
  reconstruits par un unique flush différé après la requête physique ; leurs
  contours concaves sont triangulés explicitement en formes convexes solides ;
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
- spawn runtime depuis le marqueur auteur et HUD relié aux composants Health,
  Weapon, Loadout et CombatInventory sans posséder leurs données ;
- thème `toxic_commando` choisi par `MissionMapDefinition`, avec portrait joueur,
  aperçu réel de l'arme, vie, armure, munitions, objectif, Boss et Overdrive ;
- chargement de mission recomposé avec turbine illustrée, ombre de contraste,
  plaque et texte Godot centré au lieu de l'ancien aplat noir ;
- signalétique de chargement validée en capture réelle : titre lime
  `DÉPLOIEMENT`, sous-état crème et zone sûre intérieure au cadre ;
- les cinq WeaponData publiées changent automatiquement visuel, nom et compteur
  du panneau arme via `weapon_changed`, sans condition sur leur identifiant ;
- `PlayerLoadoutProfile` décrit l'arsenal jouable standard : canon principal
  gratuit, acide, électrique, implosion et démolition ; `Components/Loadout`
  possède l'arme équipée runtime et refuse une WeaponData hors profil ;
- `MissionHUD/WeaponWheel` permet de tester rapidement les cinq armes du
  Loadout : maintenir `Tab` ou l'épaule gauche manette, viser un segment au
  pointeur ou stick droit, puis relâcher pour équiper ; les armes spéciales
  remplissent la réserve partagée en mode test pour pouvoir tirer tout de suite
  leurs projectiles ;
- `RUN_AND_GUN_PLAYER_KIT.md` sépare Player Kit, Controller, Feel, HUD et
  Arsenal afin de décider quelles capacités garder avant de créer de nouvelles
  armes ;
- le bouton Retour reste masqué pendant l'action et ne réapparaît qu'en erreur
  ou après victoire, avant son remplacement par le futur menu Pause/Options ;
- corps joueur raster via AnimatedSprite2D et Resource SpriteFrames ;
- dégâts joueur lisibles : pose `hurt`, flash et secousse orchestrés par
  `AnimationPlayer`, puis retour automatique vers l'état de locomotion courant ;
- mort joueur visible par une animation de disparition de 0,75 s qui laisse au
  spawner de mission l'autorité du remplacement après 0,8 s ;
- recul de tir directionnel appliqué ensemble au corps et au canon par un
  composant visible, avec courbe réglable dans son AnimationPlayer ;
- commande de secousse optionnelle bornée dans le profil caméra et appliquée
  via `Camera2D.offset` sans perturber la progression ; le canon automatique
  courant la règle explicitement à zéro pour préserver la lisibilité ;
- canon modulaire séparé via AimPivot, WeaponSprite et socket Muzzle ;
- canon de campagne jouable avec tir automatique sur `J` ou `X` ;
- les impacts du canon creusent localement les surfaces Carvable avec un rayon
  réglé dans `field_round.tres`, façon Worms ;
- le canon de campagne consomme maintenant son projectile bitmap publié et un
  impact animé compact `FieldRoundImpact2D`, tous deux issus du lot
  `projectile-impact-lot-v001` approuvé ;
- `WeaponData`, `ProjectileData`, projectile Area2D rapide, flash de bouche et
  impact orchestré par AnimationPlayer ;
- les projectiles peuvent survivre à leur tireur : toute exclusion physique
  valide la référence de l'acteur et l'oublie lorsqu'il a été libéré ;
- correspondance d'explosion optionnelle dans `ProjectileData`, permettant à
  une future munition de choisir scène et style au point d'impact sans modifier
  la balle de campagne actuelle ;
- spawner de mission découplant le joueur du conteneur `Runtime/Projectiles` ;
- caméra de mission unique, sans déplacement au demi-tour, avec limites et suivi réversible ;
- trois backgrounds opaques v002 de 2560 × 720, centrés sur les actes
  débarquement, pont acide et fonderie sans répétition ni étirement ;
- deux bandes de raccord 384 × 720 dérivées par pipeline et centrées sur les
  frontières des actes empêchent une coupe brute entre leurs identités ;
- midground transparent historique restauré à vitesse lente et foreground
  transparent v002 restauré au plan proche via deux `Parallax2D` décoratifs ;
- trois `EnvironmentFX2D` profilés rendent les actes vivants : fumée et nappe
  toxique partout, orage plus dense au pont, étincelles dans la fonderie ; les
  frappes sont orchestrées par `AnimationPlayer` et restent sans gameplay ;
- arrière-plan, profondeur atmosphérique et matières de sol propres au projet
  sont intégrés à Côte toxique.
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
- composition canonique `enemy_components.tscn` instanciée par les cinq scènes
  `EnemyCharacter2D`, avec Patrol, Health, Attack, StateMachine et Animation
  définis une seule fois ; profils, variantes et catalogue restent éditables
  dans l'Inspector ;
- chaîne de cadence Resource-first publiée : `EnemySpawnPatternData` décrit une
  formation, `WaveData` son beat et sa transition, `EncounterData` compose les
  vagues, puis `MapEncounterMarker2D` possède uniquement placement et activation ;
- les trois recettes `EncounterData` restent des `.tres` externes assignables
  aux Markers ; toutes leurs Waves et Patterns actuellement mono-usage sont
  intégrés comme sous-resources, sans faux partage de fichiers ;
- `MissionEncounterController` déroule exactement trois occurrences, huit
  vagues et treize apparitions explicites sur Côte toxique ; le spawner ne fait
  plus que traduire chaque archétype en scène canonique ;
- partition jouable v001 : découverte de la caisse, pression puis respiration
  au débarquement ; terrain-arme, chevauchement aérien et pince au pont ;
  pression, déplacement aérien puis payoff Boss à la fonderie ;
- mode Flux Libre : aucune Combat Gate physique ; Landing et Pont sont
  facultatifs, tandis que la finale Boss seule conditionne la victoire ;
- le HUD thémé annonce rencontre, beat et numéro de vague actifs ; les formations
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
- objet explosif glissable piloté par `ExplosivePropData`, destructible au tir
  et relié à la scène d'explosion canonique ; le Pont utilise
  `toxic_standard_explosive_barrel`, la Fonderie utilise
  `toxic_heavy_explosive_barrel` ;
- caisse militaire glissable avec états fermé/ouvert, ouvrable au tir ou par
  `player_interact` (`F` / manette Y / bouton tactile) selon son
  `SupplyCrateData`, et première occurrence placée au débarcadère ;
- injecteur de soin publié par le pipeline, piloté par `PickupData`, instancié
  au `ContentsOrigin` de la caisse puis collecté via
  `PlayerHealthComponent.heal()` sans autorité de vie parallèle ;
- inventaire de combat visible dans le SceneTree : réserve spéciale, armure et
  Overdrive réglés par `standard_combat_inventory.tres` ;
- pickups tambour, plaque d'armure et noyau Overdrive publiés et placés ;
- stations médicale, ravitaillement et quatre armureries configurables par
  `ServiceStationData`, sans duplication du bitmap du casier ;
- quatre armes spéciales jouables — acide, électrique, implosion et démolition
  — avec WeaponData, projectile texturé et impact animé propres ;
- lot industriel audité à 38 sources : 11 intégrées ou supplantées exclues et
  27 sorties inédites publiées par pipeline déterministe ;
- tour, arche traversable, culées, plateformes de fonderie, barricades et mur
  destructible composent désormais la géométrie proche des trois actes ;
- projecteur, relais radio, mine et évent toxique sont placés selon leurs
  contrats WorldProp, mine et Hazard existants ;
- `MissionActorSpawner2D` recrée le joueur après sa mort avec délai configurable
  et `respawn_spawn_id`, tandis que `PlayerHealthComponent.reset_health()` reste
  l'autorité unique des PV réinitialisés ;
- deux `MissionCheckpoint2D` visibles sous `Gameplay/Interactions` font évoluer
  le spawn de reprise vers le pont puis la fonderie ;
- `MissionRunController` suit uniquement la finale Boss obligatoire puis
  affiche le résultat de victoire lorsque
  le joueur atteint `MissionEnd` ;
- `ActorStateMachineComponent` est maintenant présente sur le joueur et les
  ennemis avec les états communs `IDLE`, `RUN`, `ATTACK`, `SHOOT`, `JUMP`,
  `FALL`, `HURT`, `DEAD` et
  `RESPAWN` ; les placeholders futurs devront reprendre cette brique ;
- Mission 2 possède une première scène maître `mission_2.tscn` conforme au
  contrat de carte, publiée comme `mission_2_abyssal` dans le catalogue de
  missions, avec un acte auteur de 2560 × 720 et un spawn joueur initial ;
- le plugin éditeur `Mission Authoring` expose un dock `Missions` qui lit
  `MissionMapCatalog`, ouvre la `MissionMapDefinition`, ouvre la scène maître
  et lance la scène de playtest déclarée par chaque mission ;
- le bouton `Mission` du menu principal ouvre maintenant
  `MissionTestSelectScreen`, qui lit `MissionMapCatalog` et lance chaque
  mission dans `PrototypeMissionScreen` avec le player, le HUD, les spawners et
  les projectiles canoniques ;
- le kit terrain abyssal publie désormais vingt-cinq scènes Ground Pieces
  glissables : socle v001, variantes v002 de raccords et cinq grands socles
  v004 générés pour une seule hauteur de sol lisible ; Mission 2 en place
  vingt-deux occurrences sous `Gameplay/GroundPieces` pour tester un premier
  parcours de deux actes ;
- DA-08 `da-08-abyssal-mission.png` fixe la direction Mission 2 : ruines
  techno-abyssales, corail noir, nacre cassable, cuivre oxydé et énergie
  cyan/violette ; son vocabulaire de production est détaillé dans
  `docs/assets/MISSION_2_ABYSSAL_ART_DIRECTION_AND_STRUCTURE_KIT.md` ;

## Autorités actuelles

- routage applicatif et fondus : `AppFlowConfig.tres` ; peau visuelle du Boot et
  du Start : `BootStartFlowTheme.tres` ; textes et composition : scènes
  `BootFlow`/`StartFlow` ; hiérarchie typographique : `game_ui_theme.tres` ;
- identité et contrat d'une carte : `MissionMapDefinition.tres` ;
- point d'entrée de test d'une carte :
  `MissionMapDefinition.playtest_scene_path` ;
- test runtime depuis le menu principal :
  `MissionTestSelectScreen`, qui route seulement le choix de mission vers
  `PrototypeMissionScreen` ;
- cockpit d'édition/test : plugin `addons/mission_authoring`, qui lit le
  catalogue sans posséder les missions ;
- placement final : scène maîtresse de carte ;
- matière destructible initiale : `Gameplay/DestructibleZones` ;
- matière runtime : masque alpha de `DestructibleTerrain2D` ;
- apparence du terrain : `DestructibleTerrainProfile.tres` ;
- définition visuelle et géométrique d'une pièce : `GroundPieceDefinition.tres` ;
- liste extensible des pièces proposées aux auteurs de niveaux : tableau
  `pieces` de `GroundKitCatalog.tres` ; le nombre actuel d'entrées n'est pas un
  contrat et augmentera avec les futurs kits et niveaux ;
- vocabulaire de Mission 2 : `terrain/kits/abyssal/abyssal_ground_kit.tres` ;
  ses sources locales et recettes restent sous `pipeline/assets/`, ses PNG
  runtime publiés sous `art/terrain/pieces/abyssal/` et le placement final dans
  `maps/missions/mission2/mission_2.tscn` ;
- mode et placement d'une pièce : son instance `GroundPiece2D` dans la scène
  maîtresse, y compris son Transform complet ; état creusé :
  `DestructibleTerrain2D` ;
- forme d'un sol permanent : `GroundModule2D.outline` dans la scène maîtresse ;
- matières d'un sol permanent : `PermanentGroundStyle.tres` ;
- paramètres d'une explosion : `ExplosionData.tres` ;
- timing et représentation d'une explosion : `Explosion2D.tscn` ;
- définition d'un bassin dangereux : sa `HazardData.tres` ; placement final :
  instance de sa scène dans la map ;
- définition de ce qui explose : `ExplosivePropData.prop_id` ; état runtime :
  `ExplosiveProp2D` ; origine de détonation : `ExplosionOrigin` dans sa scène ;
  style de détonation : `ExplosionData.explosion_id` injectée ;
- définition et modes d'ouverture de la caisse : `military_supply_crate.tres` ;
  contenu : `SupplyCrateData.contents_scene` ; état fermé/ouvert : instance
  `SupplyCrate2D` ; placement du contenu : `ContentsOrigin` ;
- définition du soin : `pickups/data/health_injector.tres` ; effet et quantité :
  `PickupData` ; occurrence runtime : `Pickup2D` ; vie courante :
  `PlayerHealthComponent` ;
- munitions spéciales, armure et Overdrive :
  `PlayerCombatInventoryComponent` ; capacités :
  `standard_combat_inventory.tres` ;
- arsenal autorisé et arme de départ : `standard_loadout.tres` ; arme équipée
  runtime : `PlayerLoadoutComponent` ; définition de chaque arme :
  `WeaponData.tres` ;
- layout du HUD : `ui/hud/mission_hud.tscn` ; cadres, portrait, icônes et
  couleurs : `MissionHUDTheme.tres` ; choix par mission :
  `MissionMapDefinition.hud_theme` ;
- service d'une station et éventuelle arme accordée : `ServiceStationData` ;
  occurrence et usages restants : `ServiceStation2D` ;
- sélection d'une cible proche : `PlayerInteractionComponent` ; contrat de
  correspondance : groupe `interaction_targets` et couche `Interactable` ;
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
- placement d'un background : `Visual/SegmentBackgrounds` dans la scène
  maîtresse ; bitmap et dimensions : livrable publié 2560 × 720 ;
- placement et emprise d'une atmosphère : instance `EnvironmentFX2D` sous
  `Visual/EnvironmentFX` ; intensités, couleurs et intervalles :
  `EnvironmentFXProfile.tres` ; timing bref d'éclair : `AnimationPlayer` ;
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
- cockpit d'édition/test des missions :
  `docs/architecture/MISSION_AUTHORING_COCKPIT_CONTRACT.md`.

## Projection validée des catalogues publiés

Cette liste est une projection documentaire, jamais une seconde autorité. Les
Resources `.tres` restent souveraines ; le test de contrat compare
dynamiquement leurs identifiants avec ce bloc afin qu'un ajout ou un retrait de
contenu impose la mise à jour de la mémoire du projet sans figer la taille des
catalogues.

<!-- CATALOG_PROJECTION_BEGIN -->
- `mission_maps` : `mission_2_abyssal`, `toxic_coast`
- `enemy_archetypes` : `vacuum_boss`, `vacuum_flying`, `vacuum_grunt`, `vacuum_pilot_saboteur`, `vacuum_trooper`
- `ground_pieces/abyssal` : `abyssal_black_coral_floor_cap_left`, `abyssal_black_coral_floor_cap_right`, `abyssal_black_coral_platform_large`, `abyssal_black_coral_platform_medium`, `abyssal_black_coral_platform_small`, `abyssal_black_coral_slope_connector`, `abyssal_black_coral_slope_down`, `abyssal_black_coral_slope_up`, `abyssal_black_coral_step_high`, `abyssal_black_coral_step_low`, `abyssal_destructible_pearl_wall_large`, `abyssal_destructible_pearl_wall_medium`, `abyssal_destructible_pearl_wall_small`, `abyssal_generated_black_coral_slab`, `abyssal_generated_coral_machine_slab`, `abyssal_generated_right_coral_engine_slab`, `abyssal_generated_ruin_engine_slab`, `abyssal_generated_tide_engine_floor`, `abyssal_temple_arch_large`, `abyssal_temple_column_broken`, `abyssal_temple_column_intact`, `abyssal_tide_engine_bridge_long`, `abyssal_tide_engine_bridge_medium`, `abyssal_tide_engine_bridge_short`, `abyssal_tide_engine_support_pillar`
- `ground_pieces/toxic_coast` : `acid_bridge_abutment`, `destructible_military_wall`, `guard_tower_module`, `industrial_catwalk_medium`, `military_bunker_block_medium`, `natural_ledge_medium`, `portable_barricade`, `toxic_pipe_bridge_medium`, `vacuum_foundry_platform`, `walk_under_pipe_arch`
<!-- CATALOG_PROJECTION_END -->

## Protection opérationnelle

- dépôt Git initialisé sur la branche `main` ;
- dépôt distant de référence : `https://github.com/azemann/jeuweb.git` ;
- caches Godot, états locaux Codex, captures, exports et journaux exclus par
  `.gitignore` ;
- état animation contrôlé par le validateur raster v002 et son contrat headless
  dédié ; `scripts/run-tests.sh structure` exécute actuellement 34 contrats et
  refuse toute sortie Godot `ERROR` ou `WARNING` ; le profil `content` protège
  séparément la partition auteur explicitement acceptée ;
- workflow GitHub Actions publié sous `.github/workflows/godot-tests.yml` avec
  Godot 4.7.1 et le même profil structurel qu'en local.

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
- le premier canon n'a encore aucun audio ; les bruitages sont volontairement
  reportés pendant la finalisation du gameplay ;
- la mort du joueur réutilise volontairement la pose `hurt` : aucun atlas de
  mort distinct n'est déclaré tant qu'une séquence raster validée n'est pas
  publiée par le pipeline ;
- la munition de campagne utilise un petit impact animé dédié, pas d'explosion
  radiale ; la roquette de démolition possède désormais son `ExplosionData`
  de munition séparé des barils et des obus génériques ;
- l'impulsion radiale est publiée avec `target_damaged`, mais les acteurs ne
  possèdent pas encore de contrat commun pour la consommer physiquement ;
- les poses v002 sont découpées proprement et structurées en phases lisibles ;
  leur continuité jouée à taille réelle doit encore être revue sur la cadence
  actuelle de treize apparitions explicites, auxquelles s'ajoutent les
  Saboteurs réellement éjectés ;
- la partition v001 est structurellement et fonctionnellement validée, mais ses
  seuils, respirations et densités doivent encore être équilibrés par une vraie
  session jouée avec métriques de dégâts et durée par beat ;
- les quatre `TileMapLayer` de Côte toxique sont prêts mais sans TileSet ;
- le chargement synchrone initial de Côte toxique coûte encore environ 3,57 s
  en headless ; l'écran montre désormais un état de chargement ou l'erreur
  réelle, mais une génération pré-calculée ou étalée du terrain reste à étudier ;
- le terrain 7680 px respecte un budget auteur de 144 corps de chunks et 960
  formes ; le chargement et les budgets doivent être remesurés sur machine de jeu ;
- les trois backgrounds, les deux parallaxes et les atmosphères sont intégrés,
  mais leurs raccords, leur contraste et la densité réelle des particules
  doivent être contrôlés dans le renderer interactif ; le headless ne produit
  pas de capture exploitable avec son renderer factice ;
- les anciens fichiers de texture empruntés à `worms-revisite` restent présents
  dans le dossier mais ne sont plus référencés par le profil actif ;
- aucun titre définitif, aucun logo définitif, aucun audio ;
- les commandes téléphone sont fonctionnelles et responsive, mais leur confort
  sur appareils physiques et les safe areas doivent encore être validés sur un
  panel Android/iOS réel ;
- l'arsenal possède désormais une autorité `PlayerLoadoutProfile`/Component,
  mais conserve volontairement une seule arme équipée et une réserve spéciale
  partagée ; les slots multiples et pools par famille attendent une tranche de
  gameplay dédiée avant toute représentation HUD ;
- la carte de sélection, ses six marqueurs, le cadenas et les lampes sont
  publiés dans `BootStartFlowTheme`, mais restent volontairement sans écran
  runtime jusqu'à la création d'un vrai catalogue de missions, de règles de
  déverrouillage et d'une progression sauvegardée ;
- Mission 2 n'a encore ni background final, ni ennemis, ni rencontres, ni
  checkpoint, ni sortie de victoire branchée dans un écran de mission ; ses
  deux actes de blockout servent à valider le kit terrain abyssal, ses pivots,
  ses contours, ses raccords et son rythme de parcours ;

## Famille d'explosions de barils v001

- `ExplosionData` est l'autorité unique de l'identité, de la famille, des
  rayons, dégâts, impulsion, durée, atlas et intensités VFX ;
- `ExplosivePropData.prop_id` identifie l'objet explosif concret, tandis que
  `ExplosionData.explosion_id` identifie le profil de détonation ;
- trois profils réutilisables `small`, `standard` et `heavy` forment une montée
  monotone de puissance et de densité visuelle ;
- le baril toxique actuel choisit explicitement `barrel_standard_explosion.tres`
  et ne dépend plus du profil d'obus de campagne ;
- `Explosion2D` compose animation peinte huit phases, fallback procédural,
  double onde, lumière, étincelles, débris et gouttes toxiques ;
- les effets restent locaux et ne possèdent aucun contrat de secousse caméra ;
- les atlas publiés et leurs sources, recette, provenance, manifeste et QA sont
  conservés dans le lot `barrel-explosion-family-v001` ;
- limite volontaire : les profils petit et lourd sont prêts pour de futurs
  contenants, mais aucune nouvelle scène de baril dupliquée n'est créée sans
  asset de prop et intention de niveau réels ;
- prochaine étape recommandée : équilibrer les dégâts, rayons, coûts et
  feedbacks des munitions en jeu réel, sans convertir leurs petits impacts en
  explosions de baril.

## Objets explosifs identifiés v001

- trois définitions d'objets explosifs existent sous `props/explosive/data/` :
  `toxic_small_explosive_barrel`, `toxic_standard_explosive_barrel` et
  `toxic_heavy_explosive_barrel` ;
- elles réutilisent la scène canonique actuelle `ExplosiveProp2D` et le bitmap
  publié du baril, mais possèdent des `prop_id`, PV et `ExplosionData`
  distincts ;
- la scène canonique expose `AuthorPreview`, visible dans l'éditeur, qui
  projette `prop_id` et `explosion_id` pour éviter de confondre l'objet et son
  profil de détonation ;
- l'occurrence du Pont choisit le prop standard et l'occurrence de Fonderie
  choisit le prop lourd directement dans la scène maîtresse ;
- le rayon terrain et le rayon de dégâts d'une explosion sont indépendants :
  une grosse charge peut creuser large sans appliquer ses dégâts sur toute la
  largeur du cratère ;
- limite volontaire : les scripts restent dans `props/explosive_barrel/` pour
  compatibilité de cette tranche ; seule la donnée générique nouvelle est
  introduite.

## Arsenal joueur Resource-first v001

- `PlayerLoadoutProfile` est l'autorité de l'arsenal autorisé, de l'arme
  primaire et de l'arme de départ ;
- `standard_loadout.tres` regroupe le canon de campagne et les quatre armes
  spéciales déjà publiées, sans recopier cadence, projectile, bitmap ni coût ;
- `PlayerLoadoutComponent` est visible sous `Player/Components/Loadout` et
  possède `equipped_weapon` au runtime ;
- `PlayerWeaponComponent` consomme l'arme équipée pour cadence, munitions,
  recul, HUD et demande de projectile, mais ne possède plus l'arsenal ;
- les armureries demandent l'équipement au Loadout et ajoutent éventuellement
  des munitions via `PlayerCombatInventoryComponent` ;
- les projectiles et armureries exposent `AuthorPreview` dans l'éditeur pour
  afficher l'identifiant de munition, l'impact, l'explosion éventuelle, la
  station et l'arme accordée ;
- la roue d'armes HUD observe le Loadout, appelle `equip_weapon()` pour les
  tests et recharge la réserve spéciale via CombatInventory lorsque son export
  de test est actif ; elle ne possède pas de slots persistants ni de munitions
  propres ;
- le canon de campagne possède son bitmap de munition et son impact animé
  publiés ; la roquette de démolition pointe vers
  `demolition_rocket_burst` au lieu du profil d'obus de campagne ;
- limite volontaire : pas encore de sélection multi-slot, pas de pools de
  munitions par famille et pas de nouveaux affichages HUD tant que le gameplay
  correspondant n'existe pas ;
- prochaine étape recommandée : équilibrer les coûts, quantités accordées et
  cadences des cinq WeaponData après playtest de Côte toxique.

## Player Kit v001

- le Player Kit désigne les actions et capacités du joueur, tandis que
  l'arsenal n'en est qu'un sous-ensemble ;
- le kit v001 gardé couvre courir, sauter, viser horizontal/vertical/diagonal,
  viser au pointeur PC, tirer, tenir le tir pour les armes automatiques,
  équiper via armurerie, ramasser soin/munitions/armure/Overdrive, subir dégâts,
  i-frames, mort et respawn ;
- crouch, drop-through, dash/slide, aim lock, melee, grenade, special attack
  séparée, swap multi-slot, drop et rescue sont reportés tant qu'un besoin réel
  de niveau, ennemi, animation, HUD et validation n'est pas établi ;
- les cinq armes publiées sont conservées comme base v001 à jouer et à
  différencier avant toute création d'un sixième rôle.

## Mission 2 — blockout abyssal v002

- l'ambiance du pack `jeuweb-abyssal-asset-pack-v001` est conservée comme
  direction conceptuelle, mais les PNG sources ne sont pas référencés
  directement par Godot ;
- DA-08 devient la référence visible de Mission 2 dans la galerie, tandis que
  le document de kit liste les pièces de structure à produire en lots ;
- quatre livrables runtime v001 sont publiés par
  `process_abyssal_ground_kit.py` : plateforme de corail noir, pente de corail,
  pont moteur de marée et mur nacré destructible ;
- seize livrables runtime v002 complètent le vocabulaire : plateformes small et
  large, caps gauche/droite, pentes up/down, marches low/high, ponts
  short/long, pilier de support, arche traversable, colonnes intacte/brisée et
  murs nacrés small/large ;
- cinq grands socles v004 générés remplacent la v003 refusée et deviennent la
  base principale du sol de Mission 2 ; ils sont `Permanent` par défaut pour
  être immédiatement solides en playtest, tandis que les pièces v002 sont
  considérées comme raccords et compléments ;
- `GroundPieceDefinition` reste l'autorité de chaque `piece_id`, texture,
  pivot, contour et surface de marche ; `GroundPiece2D` garde le mode et le
  Transform auteur instance par instance ;
- `mission_2.tscn` expose les branches obligatoires `Visual`, `Gameplay`,
  `Runtime` et `EditorPreview`, avec deux segments de 2560 px et vingt-deux
  occurrences de Ground Pieces sous `Gameplay/GroundPieces` ;
- le mur nacré conseille `Breakable` via un profil externe
  `pearl_wall_breakable.tres` ; les autres pièces conseillent `Permanent` pour
  tester d'abord la marche et les raccords ;
- limite volontaire : `DestructibleTerrain` est présent mais ne génère pas à
  l'entrée de scène, car ce premier blockout ne définit pas encore de zones
  destructibles ni de pièces Carvable de mission validées ;
- prochaine action recommandée : ouvrir Mission 2 depuis Start → Mission →
  Mission 2, jouer le parcours au clavier/manette, déplacer les pièces à la
  main, vérifier pivots/surfaces de marche, puis décider des premiers hazards,
  checkpoints et rencontres.

## Prochaine tranche recommandée

Jouer la nouvelle Côte toxique 7680 px à vitesse réelle et noter durée par beat,
usage de chaque armurerie, consommation de munitions par arme, armure,
Overdrive, dégâts reçus, lisibilité des passages et Player Feel. La prochaine
tranche doit corriger le pacing, les coûts, les placements et la famille
d'explosion de munition du lanceur, sans ajouter de nouveau système.


## Validations à exécuter

```bash
./scripts/run-tests.sh structure
./scripts/run-tests.sh content  # seulement après décision explicite sur le contenu auteur
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/foundation_smoke_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/map_contract_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/destructible_terrain_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/destructible_terrain_deferred_rebuild_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/explosion_integration_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/asset_pipeline_contract_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/player_contract_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/player_input_contract_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/pickup_interaction_contract_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/player_asset_integration_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/mission_camera_progression_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/mission_playtest_selector_contract_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/mission_run_contract_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/encounter_cadence_contract_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/permanent_ground_module_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/weapon_projectile_integration_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/class_glossary_contract_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/industrial_toxic_expansion_contract_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/project_state_catalog_contract_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/enemy_animation_roster_v002_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --quit-after 240
python3 pipeline/assets/tools/validate_vacuum_trooper_hit_death_candidate.py
python3 pipeline/assets/tools/validate_vacuum_trooper_attack_candidate.py
python3 pipeline/assets/tools/validate_toxic_pressure_candidates.py
python3 pipeline/assets/tools/validate_industrial_toxic_enemy_roster.py
python3 pipeline/assets/tools/validate_enemy_animation_roster_v002.py
```

Dernière validation complète : 2026-09-01, le profil `structure` passe 37/37.
Dernière validation complète avant cette tranche : le profil `content` passe
1/1, le pipeline des explosions de barils est reproductible bit à bit et
`git diff --check` ne signale aucun défaut.
La partition conserve trois occurrences, huit vagues et treize apparitions
explicites sur la nouvelle largeur de 7680 px.
Capture OpenGL réelle contrôlée sur `NaturalLedgeMedium` après 90 frames
d'atterrissage : marche, impact, éjection et épave suivent la pente.
