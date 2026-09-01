# Journal de création

## 2026-08-25 — Fondation, maps et première DA intégrée

### Direction

- défini un run-and-gun 2D solo à visée arcade classique ;
- fixé une DA militaire criarde, toxique et extravagante ;
- conçu les ennemis aspirateurs-scaphandres et leurs pilotes extraterrestres ;
- adopté `my-space` comme bibliothèque de recettes, sans dépendance globale.

### Projet Godot

- créé `project.godot` pour Godot 4.7.1 ;
- créé Boot Flow, Start Flow, galerie DA, écran de mission et Theme commun ;
- ajouté une architecture locale de navigation par signaux et AnimationPlayer ;
- créé les tests headless de fondation.

### Maps

- extrait les recettes pertinentes de `rpg-01`, `worms-revisite`,
  `serre-mecanique` et `horde-brawler` ;
- créé les Resources et Nodes du système de cartes ;
- créé la scène maîtresse `Côte toxique` ;
- séparé Visual, Gameplay, Destruction, Caméra et Actors ;
- ajouté contrat auteur et validation structurelle.

### Terrain destructible

- adapté le masque alpha et les collisions par chunks de `worms-revisite` aux
  zones dessinées dans Godot ;
- ajouté les boutons Inspector de régénération et de cratère ;
- protégé les rives via `IndestructibleGeometry` ;
- validé qu'un cratère ne reconstruit que les chunks touchés.

### Assets

- généré sept planches de direction artistique ;
- généré trois couches de décor de production pour Côte toxique ;
- généré une matière de sol originale et dérivé cinq textures runtime ;
- remplacé les références de terrain empruntées par les textures propres au
  projet ;
- intégré les plans de décor dans la scène via Sprite2D et Parallax2D.

### Mémoire et reprise

- créé un contrat de mémoire valable pour toute la production ;
- créé l'état courant, le journal chronologique et le manifeste des assets ;
- ajouté un point d'entrée `README.md` avec le parcours de reprise ;
- préparé Git comme historique de points de reprise validés.

### Validation obtenue après intégration des assets

- `FOUNDATION_SMOKE_TEST: PASS` ;
- `MAP_CONTRACT_TEST: PASS` ;
- `DESTRUCTIBLE_TERRAIN_TEST: PASS` ;
- démarrage du projet headless jusqu'au Boot Flow : succès.

## 2026-08-25 — Explosion canonique et première destruction gameplay

### Architecture

- créé `ExplosionData` comme autorité des rayons, dégâts, impulsion, durée et
  palette ;
- créé `Explosion2D.tscn` avec DamageArea, trois couches visuelles et
  AnimationPlayer ;
- confié à l'animation le moment exact d'activation de l'impact ;
- conservé `DestructibleTerrain2D` comme unique autorité du masque terrain ;
- exposé les futurs dégâts par signal, sans dépendance prématurée à un système
  de santé.

### Intégration Godot

- ajouté `field_shell_explosion.tres`, premier profil d'obus ;
- placé `TerrainDemoExplosion` dans `ToxicCoast/Actors/Effects` ;
- relié explicitement cette instance au terrain de la scène maîtresse ;
- ajouté les rayons de prévisualisation et le bouton Inspector
  `Prévisualiser l'impact terrain`.

### Validation

- `EXPLOSION_INTEGRATION_TEST: PASS` ;
- `FOUNDATION_SMOKE_TEST: PASS` ;
- `MAP_CONTRACT_TEST: PASS` ;
- `DESTRUCTIBLE_TERRAIN_TEST: PASS` ;
- démarrage complet headless : succès.

## 2026-08-25 — Doctrine Godot permanente

- enregistré le prompt socle editor-first/resource-first en 21 règles dans la
  documentation d'architecture ;
- créé `AGENTS.md` afin que cette doctrine soit chargée à chaque reprise par
  Codex ;
- relié explicitement la doctrine au contrat de mémoire et à la séparation du
  pipeline d'assets ;
- ajouté les recettes extraites de `rpg-01` : autorité unique, architecture
  visible, Resources-panneaux, définition/instance/présentation, scène
  canonique, generated/authored, correspondances explicites et triple contrat ;
- rendu obligatoires les quatre questions sur l'autorité, le point d'édition
  auteur, les correspondances et la validation automatique.

## 2026-08-25 — Séparation pipeline d'assets / Godot

### Frontière de production

- créé `pipeline/assets/` avec étapes sources, working, exports et recipes ;
- ajouté `pipeline/.gdignore` pour empêcher tout import Godot du pipeline ;
- défini `art/` comme dossier exclusif des livrables runtime publiés ;
- interdit les références `res://pipeline/` depuis scènes et Resources ;
- déplacé la source maître du sol toxique hors du système de fichiers Godot ;
- conservé les cinq dérivations utilisées par le terrain sous `art/` ;
- documenté la recette Côte toxique v001 et le contrat complet du pipeline ;
- ajouté un test interdisant toute référence runtime vers `res://pipeline/`.

### Validation

- `ASSET_PIPELINE_CONTRACT_TEST: PASS` ;
- les quatre tests fonctionnels existants passent toujours ;
- démarrage complet headless : succès.

## 2026-08-25 — Joueur canonique contrôlable

### Architecture visible

- remplacé la silhouette joueur de la carte par `PlayerCharacter2D.tscn` ;
- composé la scène avec CollisionShape, Hurtbox, Movement, Aim, Health,
  Presentation, AnimationPlayer et PlayerCamera ;
- créé trois Resources-panneaux pour locomotion, visée arcade et intégrité ;
- ajouté les actions Input Map clavier pour déplacement, saut et visée ;
- créé `MissionActorSpawner2D`, correspondance visible entre MapHost,
  PlayerSpawn et scène canonique du joueur ;
- relié le HUD au signal du HealthComponent ;
- conservé une présentation polygonale temporaire indépendante des futurs
  sprites publiés par le pipeline.

### Validation

- `PLAYER_CONTRACT_TEST: PASS` pour structure, profils, Input Map, spawn,
  terrain, déplacement, saut et HUD ;
- les cinq tests existants passent toujours ;
- démarrage complet headless : succès.

## 2026-08-25 — Lot d'assets joueur v001

### Production

- utilisé les planches DA-01 et DA-02 comme références d'identité et de style ;
- généré une planche alpha de 12 poses clés du joueur sans arme ;
- généré un canon de campagne modulaire séparé pour `AimPivot` ;
- conservé les sorties ImageGen sous `pipeline/assets/sources/` ;
- adapté les recettes de `fighter-sprites-2d`, `horde-brawler`,
  `serre-mecanique` et des protocoles génériques MySpace ;
- créé profil de représentation, manifeste, provenance, recette et QA ;
- normalisé les poses sur canevas fixe 384 puis dérivé des candidates 192 × 192 ;
- produit atlas 4 × 3, canon 768 × 384 et feuille de revue sombre ;
- maintenu le lot au statut `candidate`, sans publication dans `art/`.

### Validation

- 12 composantes alpha détectées et ordonnées ;
- dimensions, alpha, empreintes, débordements et exports protégés par
  `validate_player_candidates.py` ;
- corrigé une frange de réduction sous le root grâce à une marge de baseline,
  puis obtenu `PLAYER_ASSET_CANDIDATE_VALIDATION: PASS` ;
- timing, root et sockets restent explicitement à valider humainement.

### Approbation et intégration

- reçu l'approbation visuelle explicite du propriétaire du projet ;
- publié l'atlas corps sous `art/characters/player/` et le canon sous
  `art/weapons/player/` ;
- créé `player_visual_frames.tres` avec les poses nommées ;
- remplacé les polygones temporaires par AnimatedSprite2D et WeaponSprite ;
- ajouté un composant Presentation visible pour la correspondance état → pose ;
- aligné le pivot du canon et le socket Muzzle depuis le profil de production ;
- obtenu `PLAYER_ASSET_INTEGRATION_TEST: PASS` et conservé tous les tests
  existants au vert ;
- marqué le lot `integrated`, avec continuité temporelle encore provisoire.

## 2026-08-25 — Caméra de progression run-and-gun

### Diagnostic

- identifié deux caméras concurrentes : PreviewCamera fixe dans la map et
  PlayerCamera locale ;
- constaté que le fond lointain était un Sprite2D sans couche de parallaxe ;
- confirmé que la map de 1920 px ne permet que 640 px de défilement réel.

### Intégration

- créé `RunAndGunCameraProfile.tres` comme panneau de réglage ;
- créé `MissionCameraRig2D`, visible à côté de MapHost et ActorSpawner ;
- retiré la caméra du joueur et désactivé PreviewCamera au runtime ;
- ajouté look-ahead, limites de map et verrouillage de la progression arrière ;
- placé le fond lointain dans un Parallax2D plus lent ;
- préservé l'ajustement visuel du canon fait dans l'éditeur et recalé Muzzle sur
  sa transformation finale.

### Validation

- `MISSION_CAMERA_PROGRESSION_TEST: PASS` ;
- les sept autres tests et le démarrage complet headless passent.

## 2026-08-25 — Côte toxique étendue à 3840 px

### Architecture auteur

- créé `MapSegment2D`, Node auteur visible dans le SceneTree et l'Inspector ;
- ajouté `Gameplay/Segments` au contrat obligatoire des scènes de carte ;
- découpé Côte toxique en trois séquences contiguës de 1280 px : zone de
  débarquement, pont acide et fonderie aspirante ;
- fait de `MissionMapDefinition.world_size` l'autorité des 3840 × 720 px et de
  la scène maîtresse l'autorité du placement ;
- ajouté une validation automatique de l'ordre, des identités, de la hauteur
  et de la couverture exacte des segments ;
- documenté le plan de niveau dans `TOXIC_COAST_LEVEL_PLAN.md`.

### Progression et décor

- étendu les limites de caméra, l'atmosphère et la sortie jusqu'à x=3840 ;
- ajouté checkpoint de fonderie, colonne de siphonneurs et garde lourde ;
- ajouté deux zones destructibles, deux supports permanents et un second danger
  toxique pour donner une géométrie propre à chaque séquence ;
- activé `repeat_size=1920` sur les trois `Parallax2D` afin de couvrir la carte
  sans étirer les bitmaps ni mélanger pipeline et runtime ;
- conservé comme prochaine passe la production de modules artistiques propres
  au pont et à la fonderie.

### Validation

- `MAP_CONTRACT_TEST`, `DESTRUCTIBLE_TERRAIN_TEST`,
  `MISSION_CAMERA_PROGRESSION_TEST`, `EXPLOSION_INTEGRATION_TEST`,
  `PLAYER_CONTRACT_TEST`, `FOUNDATION_SMOKE_TEST`,
  `ASSET_PIPELINE_CONTRACT_TEST` et `PLAYER_ASSET_INTEGRATION_TEST` passent ;
- démarrage runtime headless : succès ;
- aucun éditeur graphique n'a été lancé.

## 2026-08-26 — Refonte du premier plan

- essayé une atténuation runtime puis rejeté cette direction après revue :
  l'opacité réduite dégradait le rendu sans corriger la composition ;
- restauré l'opacité et l'ordre de profondeur initiaux dans la scène Godot ;
- établi la règle correcte : faible intrusion verticale et raccords latéraux
  conçus dans l'asset, jamais dissimulés par `modulate` ;
- généré une candidate v002 plus légère, avec centre largement dégagé, petits
  amas latéraux et modules supérieurs espacés ;
- tenté deux extractions alpha avec ImageGen, toutes deux techniquement
  invalides car le damier est resté opaque ;
- conservé la sortie sous `pipeline/assets/sources/` avec statut `candidate`
  bloqué, sans publication dans `art/` et sans intégration Godot.

## 2026-08-26 — Sol permanent par scènes modulaires

### Décision et autorités

- retenu une architecture sans TileSet pour les structures illustrées majeures ;
- créé la scène canonique `GroundModule2D` avec `Fill`, `Surface` et
  `Body/Collision` visibles dans le SceneTree ;
- fait de l'export `Outline` l'unique autorité de la forme : il alimente le
  `Polygon2D` et le `CollisionPolygon2D` via un script `@tool` minimal ;
- créé `PermanentGroundStyle` comme Resource-panneau autoritaire pour textures,
  teintes, échelle et largeur de la bande de surface ;
- conservé `Surface Path` comme donnée visuelle distincte du volume physique.

### Intégration Côte toxique

- remplacé `WorldShell` et ses quatre collisions invisibles par quatre instances
  nommées `LandingBedrock`, `BridgeAnchor`, `FoundryApproach` et
  `FoundryExitBedrock` ;
- réutilisé les textures runtime Côte toxique déjà publiées, sans déplacer de
  source du pipeline vers Godot ;
- supprimé la double autorité collision/visuel du sol permanent ;
- laissé les `TileMapLayer` disponibles uniquement pour de futures décorations.

### Validation et limite

- `PERMANENT_GROUND_MODULE_TEST`, `MAP_CONTRACT_TEST`,
  `DESTRUCTIBLE_TERRAIN_TEST`, `MISSION_CAMERA_PROGRESSION_TEST` et
  `PLAYER_CONTRACT_TEST` passent ;
- une capture Movie Maker avec le renderer headless factice a provoqué un crash
  natif Godot sur `texture_2d_get` ; la revue visuelle doit donc être faite dans
  l'éditeur déjà ouvert, sans nouvelle ouverture automatique ;
- prochaine scène canonique recommandée : `ToxicPool2D` pour remplacer les
  rectangles colorés des dangers.

## 2026-08-26 — Recherche run-and-gun et premier tir jouable

### Recherche

- consulté documentation Godot, entretiens des équipes Metal Slug et Contra,
  postmortem Contra: Operation Galuga et ressources GDC sur les boss ;
- retenu commandes simples, lisibilité immédiate, vitesse/poids des tirs,
  progression non forcée, cohérence arme-niveau-ennemi et difficulté réglable ;
- enregistré synthèse, liens et applications dans
  `docs/research/RUN_AND_GUN_DESIGN_RESEARCH.md`.

### Autorités et scènes

- créé `WeaponData` pour projectile, cadence, mode automatique et animation ;
- créé `ProjectileData` pour vitesse, durée, dégâts, impulsion et couleurs ;
- créé `Projectile2D.tscn` comme Area2D canonique avec Timer, tracer et collision ;
- créé un impact court orchestré par AnimationPlayer ;
- ajouté `Components/Weapon/FireCooldown` dans la scène joueur ;
- ajouté flash de bouche et `WeaponFeedback` sous AimPivot sans modifier la
  transformation auteur du canon ni du Muzzle ;
- créé `MissionProjectileSpawner2D` selon la recette Godot par signal et ajouté
  `Actors/Projectiles` dans la carte.

### Boucle jouable

- ajouté `player_fire` sur J et X et une aide visible dans le HUD ;
- configuré le canon à 0,14 s entre tirs, projectile à 1350 px/s, 18 dégâts et
  1,45 s de vie ;
- ajouté un rayon physique entre frames en complément d'Area2D pour empêcher
  les projectiles rapides de traverser les collisions ;
- validé directions horizontale et verticale, cooldown, origine exacte au
  Muzzle, indépendance du joueur, collision World et impact.

### Validation

- dix tests headless passent, dont `WEAPON_PROJECTILE_INTEGRATION_TEST` ;
- démarrage runtime headless : succès ;
- aucune fenêtre d'éditeur n'a été lancée.

## 2026-08-26 — Candidats projectile et impact v001

- généré un projectile lourd de profil cohérent avec le canon et la planche
  d'armes/VFX existante ;
- généré une séquence d'impact 3 × 2 en six poses chronologiques ;
- conservé les sources ImageGen immuables sous `pipeline/assets/sources/` ;
- produit des dérivés transparents normalisés sans rien publier dans `art/` ;
- retiré du dérivé le faible voile alpha de la planche d'impact ;
- ajouté profil, recette, provenance, manifeste, rapport QA et deux outils
  reproductibles de traitement/validation ;
- détecté puis corrigé un débordement entier dans le remappage alpha grâce à
  la porte de validation ;
- validation technique réussie ; revue humaine encore requise avant intégration
  dans `Projectile2D` et son `AnimationPlayer`.

## 2026-08-26 — Ground Pieces, checkpoint Resources

- vérifié la base avant travaux : dix tests Godot existants passent ;
- créé `GroundPieceDefinition`, autorité des textures, pivots, masques et
  règles de géométrie d'une pièce ;
- créé `GroundBreakableProfile`, panneau de réglage de l'intégrité cassable ;
- ajouté la conversion déterministe alpha vers polygones avec seuil et
  simplification éditables ;
- ajouté les validations d'identité, texture, masque, contour et profil
  cassable ;
- observé le test rouge sur la classe absente puis obtenu
  `GROUND_PIECE_DEFINITION_TEST: PASS` sans lancer l'éditeur graphique.

## 2026-08-26 — Ground Pieces, checkpoints scène et stamps

- créé la scène canonique `GroundPiece2D` avec `Presentation`,
  `PermanentBody/Collision`, `DestructibleStamp`, `BreakableComponent` et
  `EditorPreview` visibles dans le SceneTree ;
- rendu exclusifs les modes Permanent, Carvable et Breakable depuis l'Inspector ;
- ajouté le cycle de vie cassable, la variante détruite et le signal
  `piece_broken` émis une seule fois ;
- ajouté `Gameplay/GroundPieces` comme seconde source auteur optionnelle du
  terrain destructible, sans retirer `DestructibleZones` ;
- composé couleur et masque des pièces Carvable dans le bitmap global selon
  leur transformation et leur priorité ;
- vérifié un cratère traversant deux stamps voisins et l'absence de double
  collision locale ;
- `GROUND_PIECE_MODES_TEST`, `GROUND_PIECE_DESTRUCTIBLE_STAMP_TEST` et le test
  historique `DESTRUCTIBLE_TERRAIN_TEST` passent.

## 2026-08-26 — Ground Pieces, premier asset et intégration pilote

- généré `natural_ledge_medium_v001` depuis la planche environnement utilisée
  uniquement comme référence de style ;
- rejeté et conservé une première source RGB avec damier opaque, puis obtenu
  une source v002 avec véritable canal alpha ;
- normalisé la pièce sur 768 × 384 avec pivot de surface `[384, 64]` ;
- reçu la validation visuelle explicite du propriétaire et publié le PNG sous
  `art/terrain/pieces/toxic_coast/natural/` ;
- fait du PNG publié l'aperçu canonique de la scène `.tscn`, sans vignette
  parallèle ;
- créé `GroundKitCatalog`, la définition `.tres` et la scène glissable ;
- importé le nouveau PNG avec l'importeur Godot headless, sans ouvrir de fenêtre ;
- ajouté `Gameplay/GroundPieces/LandingNaturalLedge` à Côte toxique en mode
  Carvable, tout en conservant les zones et modules legacy ;
- huit tests ciblés passent, dont catalogue, contrat de map, raccord destructible
  et contrat de séparation pipeline/runtime.

### Validation finale de la tranche

- quatorze tests Godot passent dans une exécution fraîche ;
- démarrage complet headless réussi avec Godot 4.7.1 ;
- aucun fichier runtime `.gd`, `.tscn` ou `.tres` ne référence `res://pipeline/` ;
- outils Python compilés, JSON du pipeline lisibles et dérivé reproductible ;
- corrigé un défaut de reprise : une régénération identique restaure désormais
  l'approbation humaine depuis le manifeste uniquement lorsque le hash publié
  correspond exactement ;
- aucune fenêtre d'éditeur graphique n'a été lancée.

## 2026-08-26 — Ground Pieces, recette Breakable publiable

- extrait le réglage de résistance saisi pour la corniche vers une Resource
  externe retrouvable et réutilisable ;
- conservé ses `1486` PV et activé sa disparition à rupture tant qu'aucune
  texture détruite n'est publiée ;
- ajouté les infobulles Inspector sur le mode, les PV et la politique de rupture ;
- ajouté une validation empêchant une pièce cassée de rester visuellement
  intacte sans `Destroyed Texture` ;
- documenté le passage d'une instance entre Permanent, Carvable et Breakable.

## 2026-08-26 — Corniche, textures de dégâts candidates

- généré deux éditions de la corniche intacte : `damaged` encore praticable et
  `destroyed` fragmentée avec tuyaux rompus ;
- conservé les sources ImageGen RGB dans le pipeline, hors de `res://art/` ;
- créé un processeur reproductible d'extraction des fonds noir/blanc connectés
  aux bords, démâtage colorimétrique et normalisation 768 × 384 ;
- maintenu le pivot canonique `[384, 64]` pour éviter tout saut lors du swap ;
- ajouté recette, provenance et rapport QA ; validation technique réussie ;
- rejeté une tentative d'extraction alpha ImageGen qui redessinait l'asset ;
- revue humaine requise avant publication et branchement à la Resource Godot.

### Approbation et intégration

- approbation visuelle reçue pour les deux candidats ;
- publié les bitmaps versionnés sous `art/terrain/pieces/.../damage_states/` ;
- ajouté `Damaged Texture` à la définition et `Damaged Health Ratio` au profil ;
- branché automatiquement intacte → endommagée → détruite via le signal
  `health_changed`, sans dépendance vers la map ;
- conservé la ruine finale, retiré sa collision et désactivé la suppression de
  scène ;
- rendu le composant cassable compatible `@tool`, corrigeant son chargement
  comme placeholder pendant le premier scan de l'éditeur ;
- tests modes, catalogue et carte réussis après import Godot headless.

## 2026-08-26 — Projectile vers terrain Carvable

- confirmé que le terrain savait creuser mais que la munition courante ne lui
  transmettait aucun impact ;
- ajouté dans `ProjectileData` l'activation et le rayon de cratère éditables ;
- réglé la munition de campagne sur un petit cratère de 12 px ;
- relié l'impact au groupe natif `destructible_terrains` et émis
  `terrain_carved` sans référence directe à la carte ;
- ajouté un test d'intégration vérifiant que le centre devient traversable et
  que la matière hors rayon reste intacte.

## 2026-08-26 — Tir à bout portant contre terrain Carvable

- reproduit le risque propre au canon long : son `Muzzle` peut dépasser le bord
  d'une paroi alors que l'origine interne reste devant ;
- vérifié séparément que masque visuel et collisions de chunks sont alignés ;
- ajouté un contrôle physique `AimPivot → Muzzle` avant chaque spawn ;
- lorsqu'une paroi coupe ce segment, résolu immédiatement l'impact sur son bord
  plutôt que de créer la balle au milieu du terrain ;
- ajouté les régressions d'alignement de chunk, d'alignement sur Côte toxique et
  de tir à bout portant.
## 2026-08-26 — Aperçus de map réservés à l'éditeur

- ajouté le panneau Inspector `Editor Preview` sur la scène maîtresse de map ;
- regroupé les silhouettes ennemies temporaires et les formes visuelles des
  dangers sous `map_authoring_preview` ;
- conservé ces repères visibles et commutables dans l'éditeur, mais toujours
  invisibles en jeu sans désactiver les `Area2D` ni leurs collisions ;
- étendu le contrat de map pour protéger cette séparation authoring/runtime.
## 2026-08-26 — Foreground Côte toxique v002 et raccord de départ

- généré un foreground v002 plus bas, discontinu et largement dégagé au centre ;
- rejeté deux sorties opaques et validé uniquement la sortie possédant un vrai
  canal alpha ;
- publié le flux `source → export pipeline → art runtime` sans référencer le
  pipeline depuis Godot ;
- remplacé le foreground v001 dans la scène maîtresse ;
- retiré de la map la deuxième corniche moyenne, empilée presque entièrement
  sur la première, tout en conservant sa scène canonique dans le kit ;
- conservé l'opacité complète des éléments peints : la lisibilité vient de la
  composition et non d'une transparence globale artificielle.

## 2026-08-26 — Entrées clavier, souris, manette et téléphone

### Architecture

- conservé l'Input Map de `project.godot` comme autorité unique des liaisons
  physiques ;
- ajouté `player_aim_left/right` pour le stick droit sans modifier la règle de
  déplacement du stick gauche ;
- étendu `PlayerAimProfile` avec les réglages de visée pointeur éditables ;
- confié à `PlayerAimComponent` la sélection entre visée arcade, stick droit et
  souris, sans Autoload ni gestionnaire global caché ;
- créé le contrat auteur `docs/input/PLAYER_INPUT_AUTHORING_CONTRACT.md`.

### Intégration visible dans Godot

- ajouté clavier, clic gauche, stick gauche, croix, stick droit, A, X, RB et
  gâchette droite dans `Project Settings > Input Map` ;
- créé la scène canonique `MobileControls` avec six `TouchScreenButton` qui
  produisent les mêmes actions que les autres périphériques ;
- intégré cette scène à `PrototypeMissionScreen`, avec taille et marges
  éditables, prévisualisation desktop et visibilité tactile automatique ;
- utilisé uniquement des Nodes, formes et styles Godot, sans nouvel asset
  bitmap ni modification du manifeste artistique.

### Limites et validation

- le confort, les safe areas et la densité des boutons restent à valider sur
  plusieurs téléphones physiques ;
- `PLAYER_INPUT_CONTRACT_TEST: PASS` ;
- `PLAYER_CONTRACT_TEST: PASS` ;
- seize tests sur dix-huit passent et le démarrage runtime headless réussit ;
- `destructible_terrain_collision_alignment_test.gd` échoue sur la matière et
  la collision attendues devant le canon dans Côte toxique ;
- `ground_kit_catalog_test.gd` échoue car la définition publiée de la corniche
  ne référence actuellement plus son profil Breakable externe ;
- ces deux échecs concernent les données terrain et n'ont pas été masqués par
  une modification hors périmètre de la tranche d'entrée.
## 2026-08-26 — Infobulles Inspector globales

- documenté les 208 propriétés exportées des 39 scripts de production ;
- décrit pour chaque réglage son autorité, son unité et son influence sur le
  gameplay, le rendu, le workflow auteur ou les performances ;
- couvert les Resources-panneaux, composants, correspondances de scène,
  outils de prévisualisation et commandes mobiles ;
- ajouté `inspector_documentation_contract_test.gd`, qui refuse désormais
  toute nouvelle propriété exportée sans commentaire `##` utile ;
- laissé les catégories et groupes sans texte artificiel : ils structurent
  l'Inspector mais ne constituent pas des propriétés réglables.

## 2026-08-26 — Correction de l'écran gris de mission

- reproduit le défaut par une capture graphique réelle de la scène de mission ;
- identifié le rejet complet de Côte toxique par `MissionMapHost2D` : une
  seconde corniche `Carvable` avait été placée avec une rotation de −35°,
  transformation interdite par sa `GroundPieceDefinition` ;
- retiré uniquement cette instance invalide de la scène maîtresse et conservé
  `LandingNaturalLedge`, placement canonique documenté ;
- rendu le message de validation utilisable avant l'ajout au SceneTree grâce
  au chemin relatif `Gameplay/GroundPieces/<node>` ;
- confirmé par capture que décor, terrain, joueur et HUD s'affichent à nouveau ;
- `MAP_CONTRACT_TEST: PASS`, `PLAYER_CONTRACT_TEST: PASS` et chargement graphique
  de mission sans erreur.

## 2026-08-27 — Transformations auteur souveraines

### Décision

- acté avec le propriétaire que toute future pièce ou famille d'objets placés
  doit accepter les transformations natives de Godot ;
- fait du Transform de l'instance dans la scène maîtresse l'autorité de la
  translation, rotation, échelle uniforme ou non uniforme et miroir ;
- réservé les restrictions futures aux seules règles créatives ou gameplay
  explicitement choisies, jamais aux lacunes techniques d'un consommateur ;
- créé le contrat transversal
  `docs/architecture/AUTHORED_TRANSFORM_CONTRACT.md` et intégré cette règle à
  la doctrine principale.

### Ground Pieces et scène maîtresse

- confirmé que `DestructibleTerrain2D` possédait déjà la bonne correspondance
  inverse pixel cible → espace local de la pièce ;
- supprimé les drapeaux `supports_rotation` et `supports_uniform_scale` ainsi
  que les interdictions artificielles du mode Carvable ;
- conservé uniquement le refus d'une échelle nulle, transformation
  mathématiquement non inversible ;
- restauré la corniche auteur à `(797, 319)` et `−35°` dans Côte toxique ;
- rétabli le profil Breakable externe de sa définition, sans changer le mode
  Carvable des instances actuelles.

### Validation

- étendu le test de stamp avec rotation `−35°`, miroir et échelle non uniforme
  `(-1.6, 0.55)` ; masque, couleur et collision générée suivent ensemble ;
- protégé dans le contrat de map la présence et la rotation de la corniche
  auteur ;
- les dix-huit tests Godot passent ;
- démarrage runtime headless réussi.

## 2026-08-27 — Marche candidate du Vacuum Trooper

### Intention et filiation

- repris les planches canoniques `da-06-enemies-vacuum-divers` et
  `da-07-enemy-pilot-lifecycle` pour l'identité de l'ennemi ;
- repris la marche Teal 2,5D de `arene` uniquement comme référence de cadence
  et de phases biomécaniques, selon le contrat d'animation de `my-space` ;
- généré avec ImageGen intégré une planche exacte de huit poses : contact,
  compression, passage et montée pour chaque alternance d'appui.

### Pipeline et autorités

- conservé la sortie ImageGen comme source candidate sous `pipeline/assets/`,
  avec son SHA-256, le prompt final, les références et la provenance ;
- créé un profil d'animation déclarant huit frames de 160 ms, une direction
  canonique droite et un root commun ;
- normalisé les silhouettes à échelle commune sur canevas 256 × 192, assemblé
  l'atlas 4 × 2 et produit une feuille de revue ainsi qu'une boucle WebP ;
- laissé volontairement le lot hors de `art/` : aucune scène ou Resource Godot
  ne référence un export pipeline avant approbation visuelle et temporelle.

### Validation et suite

- ajouté `validate_vacuum_trooper_walk_candidate.py`, qui protège la source,
  les dimensions, huit durées de 160 ms, l'alpha, les marges et le root fixe ;
- `Vacuum Trooper walk candidate: technical QA passed` ;
- statuts : technique `passed`, visuel et temporel `candidate`, gameplay
  `unmapped` ;
- prochaine action : approbation humaine de la boucle, puis publication et
  création editor-first du `SpriteFrames` et de la scène d'ennemi.

## 2026-08-27 — Première patrouille Vacuum Trooper intégrée

### Publication et architecture

- enregistré l'approbation humaine visuelle et temporelle de la marche v001 ;
- publié l'atlas sous `art/characters/enemies/vacuum_trooper/`, avec manifeste,
  provenance, SHA-256 et statuts pipeline mis à jour ;
- créé le contrat auteur `docs/characters/ENEMY_AUTHORING_CONTRACT.md` ;
- créé `EnemyArchetypeProfile`, `EnemyCatalog` et `EnemySceneBinding` afin que
  données de combat et correspondance de scène restent éditables en Resources ;
- créé la scène canonique `vacuum_trooper_2d.tscn`, dont Patrol, Health et
  Presentation sont visibles dans le SceneTree ;
- ajouté `MissionEnemySpawner2D` à l'écran de mission : `VacuumPatrol` génère
  deux ennemis autour de x=770, sous la branche runtime `Actors` ;
- laissé Brute et Siphoner comme marqueurs auteurs désactivés jusqu'à ce que
  leurs scènes existent.

### Liberté auteur et validation proportionnée

- ajouté `formation_spacing` au marqueur de rencontre pour que la formation se
  règle dans l'Inspector et non dans le code ;
- retiré deux assertions trop prescriptives : une ruine n'est plus imposée si
  l'auteur choisit `remove_after_break`, et la carte n'est plus obligée de
  placer de la matière Carvable devant le canon ;
- conservé les invariants utiles : une ruine conservée exige une texture, et
  toute matière Carvable effectivement rencontrée doit rester alignée avec sa
  collision ;
- validation ciblée passée : asset/pipeline, ennemi, carte et projectile ;
- `enemy_contract_test.gd` vérifie profil, catalogue, huit frames, arbre de
  scène, deux spawns dans 0–1280 et dégât réel d'un `FieldRound2D` ;
- prochaine action : poses d'impact/mort puis composant d'attaque distinct.

## 2026-08-27 — Correction visuelle réelle de la patrouille ennemie

- reconnu que les tests headless initiaux n'avaient pas remplacé une revue du
  jeu animé ; enregistré 90 frames avec le renderer OpenGL réel ;
- identifié que le spawner ajoutait l'ennemi au SceneTree avant son placement :
  Patrol mémorisait alors `origin_x = 0` au lieu des origines 700 et 840 ;
- placé chaque instance avant son `_ready()` afin que la formation auteur soit
  l'origine effective de sa patrouille ;
- remplacé le toggle aveugle de direction par une résolution directionnelle des
  limites et de la normale de mur, supprimant le flip gauche/droite par frame ;
- étendu uniquement `enemy_contract_test.gd` pour protéger les origines de
  formation, puis confirmé `ENEMY_CONTRACT_TEST: PASS` ;
- contrôlé plusieurs frames consécutives de la nouvelle capture : orientation
  et progression sont stables ; la corniche Breakable tournée possède encore
  une surface physique plus haute que sa lecture peinte par endroits, sujet
  terrain distinct à traiter via une géométrie auteur.

## 2026-08-27 — Fondation transversale pieds, sols et ombres

### Décision durable

- généralisé la règle aux futures maps, pièces, objets physiques, joueurs et
  ennemis via
  `docs/architecture/ACTOR_GROUNDING_AND_WALK_SURFACE_CONTRACT.md` ;
- inscrit la règle dans la doctrine Godot principale : une ombre dépend du vrai
  sol et une surface non Carvable possède une géométrie auteur inspectable ;
- maintenu une autorité unique : contour auteur pour Permanent/Breakable,
  masque et collisions runtime pour Carvable.

### Acteurs et projection

- créé la scène partagée `ActorGroundingComponent` avec GroundAnchor,
  GroundProbe et GroundShadow visibles dans le SceneTree ;
- remplacé les deux ovales fixes attachés à Presentation du joueur et du
  Vacuum Trooper ;
- projeté l'ombre au point World réel, orientée selon la normale, avec taille et
  opacité dépendant de la hauteur ; elle reste donc au sol pendant un saut et
  suit les futurs cratères sans correspondance spéciale ;
- aligné le GroundAnchor sur l'origine commune au bas des collisions et au root
  publié des sprites.

### Surface de marche auteur

- enrichi `GroundPieceDefinition` avec `walk_surface_point_count` : la surface
  est une portion sémantique du contour unique, jamais une géométrie dupliquée ;
- ajouté une prévisualisation éditeur magenta/verte sur `GroundPiece2D`, masquée
  en Carvable ;
- remplacé la collision alpha approximative de la corniche naturelle par un
  contour auteur aligné sur son bord supérieur et transformé avec l'instance ;
- confirmé par capture OpenGL réelle que le Trooper suit désormais la pente
  peinte avec les pieds au contact.

### Validation proportionnée

- ajouté un seul contrat transversal
  `grounding_walk_surface_contract_test.gd` pour toutes les scènes futures ;
- passés : Grounding/surface, définition et modes Ground Piece, joueur, ennemi,
  Inspector, stamp Carvable, alignement de collision et map ;
- contrôlé 90 frames réelles après les tests, sans se limiter au headless.

## 2026-08-27 — Suivi générique des pentes par les pieds

- ajouté `LeftFootProbe` et `RightFootProbe` à la scène Grounding partagée ;
- calculé la tangente sous la largeur d'appui et filtré les ruptures de bord ou
  de cratère par comparaison avec la normale centrale ;
- créé `ActorSlopePresentationComponent`, paramétrable par famille d'acteur
  pour largeur, ratio, angle maximal, zone morte et lissage ;
- introduit `Presentation/SlopeVisual`, pivoté au GroundAnchor, afin que le
  corps suive la pente sans modifier collision, canon ou direction de visée ;
- transformé les branches `Components` en `Node2D` : les probes héritent enfin
  du Transform réel de l'acteur au lieu de rester à l'origine mondiale ;
- remplacé la collision rectangulaire large du Vacuum Trooper par un polygone
  convexe terminé en `(0,0)` ; sur une pente, le contact est désormais central
  et non porté par un coin qui suspendait visuellement les pieds ;
- rendu le test d'origine de patrouille relatif au marqueur et à son espacement,
  afin de préserver les déplacements auteur ;
- passés : contrat Grounding/surface, joueur, assets joueur, entrées, ennemi,
  Inspector et map ;
- contrôlé les frames 55 à 89 d'une capture OpenGL réelle : après atterrissage,
  le contact central suit le bord peint de `NaturalLedgeMedium`.

## 2026-08-27 — Glossaire des classes et recherche d'architecture

### Vocabulaire durable

- créé `GLOSSARY_CLASSES_AND_VOCABULARY.md` comme autorité des termes, suffixes
  architecturaux et classes nommées du projet ;
- distingué précisément Data, Profile, Definition, Catalog, Binding, Component,
  Spawner, Host, Root, Rig, Flow, Style et Config ;
- recensé les classes actuelles par domaine, y compris la nouvelle famille
  ennemie et le composant partagé de projection au sol ;
- ajouté les vocabulaires terrain, combat, pipeline, authoring et runtime.

### Recherche externe

- comparé les recommandations officielles Godot avec le Gameplay Framework et
  les Data Assets Unreal, les ScriptableObjects et l'ECS Unity ;
- confirmé scènes composées + Resources + composants locaux + signaux comme
  architecture principale du projet ;
- réservé ECS, pooling, streaming et managers globaux aux besoins réellement
  mesurés ;
- identifié une future responsabilité de règles/session de mission à rendre
  visible lorsque victoire, défaite et respawn seront implémentés.

### Validation

- ajouté `class_glossary_contract_test.gd` afin que toute nouvelle
  `class_name` soit inscrite au glossaire dans le même changement ;
- `CLASS_GLOSSARY_CONTRACT_TEST: PASS` ;
- `INSPECTOR_DOCUMENTATION_CONTRACT_TEST: PASS`.

## 2026-08-27 — Candidate impact et mort du Vacuum Trooper

### Audit de la source

- contrôlé la nouvelle sortie ImageGen : 2079 × 756, RGBA avec alpha réel et
  SHA-256
  `336b73c59be18335a713aa9a331662f8a4774b8d64ff6020b7d7e5109c5ecde1` ;
- confirmé quatre poses d'impact/récupération puis quatre poses de mort comique
  avec ouverture de la coque et éjection du pilote ;
- détecté que 2079 n'est pas divisible par quatre et que la fumée de la frame 5
  ainsi que le haut du pilote de la frame 6 franchissent la ligne des rangées ;
- vérifié que ces dépassements sont spatialement séparés des poses supérieures
  et peuvent être récupérés uniquement depuis les pixels source.

### Pipeline et autorités

- ajouté un processeur à limites de colonnes explicites et reconstruction
  déterministe de la bande `y=330..378`, sans peinture ni génération ;
- normalisé les huit poses à échelle commune sur 512 × 384 puis 256 × 192, avec
  le root publié de la marche `[128, 180]` ;
- produit l'atlas candidat, les frames individuelles, la feuille de revue avec
  ligne de sol et deux boucles WebP séparées ;
- enregistré profil, manifeste candidat, provenance et recette sous
  `pipeline/assets/` ; aucune copie sous `art/` et aucune référence Godot ;
- défini des timings de revue non bouclés : impact `[90, 80, 130, 160]` ms et
  mort `[120, 160, 220, 600]` ms.

### Validation et suite

- `Vacuum Trooper hit/death v001: candidate QA passed` ;
- huit frames RGBA 256 × 192, atlas 1024 × 384, alpha sûr, marges présentes et
  root commun contrôlés automatiquement ;
- statuts : technique `passed`, visuel et temporel `candidate`, gameplay
  `unmapped` ;
- prochaine action : validation humaine de la feuille et des deux timings,
  puis seulement publication et intégration dans le `SpriteFrames` canonique.

## 2026-08-27 — Impacts et mort du Vacuum Trooper intégrés

### Publication

- enregistré l'approbation visuelle et temporelle explicite du propriétaire ;
- publié l'atlas 1024 × 384 sous
  `art/characters/enemies/vacuum_trooper/`, SHA-256
  `54b6342c11b1c3354c316d685b74fd0f56eeae44de3cb489b91b5d493f934ed2` ;
- passé manifeste, profil, provenance et QA aux statuts visuel/temporal/
  technical `passed` et gameplay `integrated` ;
- ajouté le livrable et sa correspondance Godot à `art/ASSET_MANIFEST.md`.

### Composition runtime

- ajouté les animations non bouclées `hit` et `death` au `SpriteFrames`
  canonique, avec les timings approuvés portés par la Resource ;
- relié `EnemyHealthComponent.damaged` à Presentation : Patrol suspend sa
  locomotion horizontale puis la reprend au signal de fin de `hit` ;
- à zéro PV, retiré immédiatement la coque de la couche cible tout en gardant
  sa collision World et sa gravité, puis joué `death` ;
- remplacé le `queue_free()` immédiat par le signal de fin de l'animation de
  mort ; le pilote reste volontairement une partie du raster et non un acteur
  gameplay séparé ;
- étendu le contrat auteur des ennemis à cette correspondance Health → Patrol
  → Presentation → suppression différée.

### Validation réelle

- validateur pipeline publié : `PASS` ;
- `ENEMY_CONTRACT_TEST: PASS`, y compris timings, boucles, suspension/reprise,
  couche cible neutralisée et suppression après la dernière pose ;
- capture OpenGL 1280 × 720 effectuée dans Côte toxique après 90 frames
  d'atterrissage, avec un seul ennemi immobilisé comme mannequin de revue ;
- conservé le montage des quatre états sous
  `pipeline/assets/working/enemies/vacuum_trooper/`, SHA-256
  `f75cbfd74c9dea0792ade49d2fd243f2e0b3cd1f567c8d82d4c165bb8baadc9d` ;
- contrôlé visuellement marche, impact orange, éjection et épave sur la pente
  réelle : root, inclinaison et ombre restent cohérents ;
- prochaine action : composant d'attaque séparé et auteur-first.

## 2026-08-27 — Lot Côte toxique glissable

- normalisé et publié le bloc bunker, la passerelle, le pont-tuyau, le bassin
  acide, le baril et les deux états de caisse sans mélanger pipeline et `art/` ;
- dérivé la caisse ouverte vide depuis la caisse fermée avec ImageGen intégré,
  puis garanti un alpha réel par une seconde passe d'extraction ;
- créé une `.tres` gameplay et une `.tscn` glissable pour chacun des six
  contenus ; ajouté les trois terrains au `GroundKitCatalog` ;
- rendu chaque terrain configurable par instance en Permanent, Carvable ou
  Breakable ; ajouté danger périodique, baril explosif et caisse ouvrable ;
- ajouté `player_interact` sur `F` et manette Y ; la caisse accepte par défaut
  tir ou interaction et reste vide en attendant le système de loot ;
- ajouté le contrat automatisé `toxic_coast_content_pack_test.gd`.

## 2026-08-27 — Point de restauration Git initial

- confirmé que le dépôt était déjà initialisé sur `main`, mais ne possédait
  encore aucun commit ;
- conservé `https://github.com/azemann/jeuweb.git` comme dépôt distant de
  référence ;
- contrôlé les exclusions Git : caches Godot, états locaux Codex, captures,
  exports et journaux ne font pas partie du contenu versionné ;
- vérifié l'absence de gros fichier accidentel, de lien symbolique inattendu et
  de signature courante de secret dans le contenu à versionner ;
- exécuté les 22 contrats headless du projet : tous passent ;
- prochaine action recommandée : corriger les contradictions internes de
  `docs/PROJECT_STATE.md` sans modifier le gameplay.

## 2026-08-27 — Réconciliation de l'état publié

- vérifié `toxic_coast_ground_kit.tres` : le catalogue contient quatre pièces,
  soit la corniche, le bloc bunker, la passerelle et le pont-tuyau ;
- distingué les trois contenus glissables hors catalogue de terrain : bassin
  acide, baril explosif et caisse militaire ;
- vérifié le contrat runtime de l'explosion : `Explosion2D` émet
  `damage_requested`, tandis que `ExplosiveProp2D` assure déjà la
  correspondance vers `apply_damage` pour les explosions de barils ;
- corrigé uniquement les deux formulations contradictoires de
  `docs/PROJECT_STATE.md`, sans modification gameplay ;
- prochaine action recommandée : traiter séparément l'ancienne mission
  prototype après audit complet de ses références.

## 2026-08-27 — Extensibilité des Ground Kits explicitée

- confirmé que `GroundKitCatalog.pieces` est un tableau auteur extensible de
  `PackedScene`, résolu par `piece_id` stable et sans limite de quantité ;
- corrigé la mémoire et le guide auteur afin que les quatre pièces actuelles
  décrivent un état publié, jamais un périmètre figé ;
- documenté l'ajout futur d'une définition, d'une scène canonique puis de sa
  correspondance dans le catalogue depuis l'Inspector ;
- précisé que les prochains biomes peuvent posséder leurs propres catalogues et
  que les tests doivent valider les invariants des entrées sans figer leur
  nombre ;
- aucune scène, Resource gameplay ou logique runtime n'a été modifiée.

## 2026-08-27 — Retrait de l'ancienne mission autonome

- vérifié que le runtime actif ouvre `PrototypeMissionScreen`, lequel charge
  `toxic_coast.tres` par `MissionMapHost2D` ;
- confirmé que `levels/prototype/prototype_mission.tscn` n'était référencée que
  par un ancien contrôle de fondation et une spécification historique ;
- supprimé cette scène parallèle désormais récupérable dans l'historique Git ;
- remplacé sa vérification dans `foundation_smoke_test.gd` par le chargement de
  la scène maîtresse canonique `toxic_coast.tscn` ;
- conservé `PrototypeMissionScreen`, qui reste l'écran applicatif actif et ne
  constitue pas une seconde architecture de carte ;
- marqué la spécification de fondation comme historique sans réécrire les
  décisions qu'elle documentait ;
- prochaine action recommandée : ajouter une validation ciblée entre l'état
  documenté et les catalogues publiés.

## 2026-08-27 — Contrat catalogues vers mémoire projet

- ajouté dans `PROJECT_STATE.md` une projection lisible des identifiants
  publiés pour les cartes, ennemis et Ground Pieces Côte toxique ;
- conservé les Resources `.tres` comme autorités uniques : la documentation
  est explicitement un dérivé contrôlé ;
- ajouté `project_state_catalog_contract_test.gd`, qui construit ses attentes
  depuis les catalogues runtime et compare dynamiquement les ensembles triés ;
- aucun nombre de pièces ni identifiant de contenu n'est codé en dur dans le
  test ; enrichir un catalogue exige seulement d'actualiser sa projection dans
  la mémoire du projet ;
- prochaine action recommandée : corriger séparément le contrat runtime fragile
  des dégâts d'explosion.

## 2026-08-27 — Explosion autonome et origine auteur

- fait de `Explosion2D` l'exécuteur autonome des dégâts radiaux : elle résout
  `apply_damage`, déduplique Body et Hurtbox par Damage Receiver, puis émet
  `target_damaged` uniquement après acceptation ;
- supprimé la correspondance privée du baril vers l'ancien signal
  `damage_requested` ;
- ajouté `ExplosionOrigin` comme `Marker2D` visible dans la scène canonique du
  baril et utilisé sa position mondiale comme autorité de détonation ;
- ajouté à `ProjectileData` une correspondance optionnelle scène + Resource ;
  une munition explosive délègue dégâts et terrain à l'explosion instanciée au
  point d'impact, tandis que les projectiles directs restent inchangés ;
- conservé `ExplosionData` comme autorité du style et du rayon, afin que
  rotation, miroir ou échelle du baril déplacent le socket sans modifier
  implicitement la puissance ;
- étendu les contrats pour vérifier une explosion autonome, une seule
  application malgré Body + Hurtbox et le socket transformé ;
- limite volontaire : l'impulsion est annoncée mais aucun contrat physique
  commun aux acteurs ne la consomme encore.

## 2026-08-27 — Lot candidat de l'attaque toxique du Vacuum Trooper

- généré avec ImageGen intégré une attaque complète en huit phases : détection,
  anticipation, charge, relâchement, phase active, recul, récupération et prêt ;
- généré séparément un projectile lent de pression toxique en quatre frames et
  son impact en six frames, tous deux sur alpha réel ;
- conservé la première planche d'attaque au faux damier comme source rejetée,
  puis archivé la passe corrigée RGBA sans écraser la provenance ;
- normalisé l'attaque sur le root ennemi publié `[128, 180]`, nettoyé quatre
  fragments intercellules et produit revues statiques et aperçus animés ;
- ajouté profils, manifestes, provenance, recettes et validateurs déterministes
  pour les deux lots ; validations techniques passées ;
- maintenu les sorties hors de `art/` et sans référence Godot : statuts visuel
  et temporel encore `candidate`, gameplay `unmapped` ;
- point de décision avant publication : accepter ou régénérer l'échelle plus
  petite imposée par la longue trompe de l'attaque.

## 2026-08-27 — Publication et branchement de l'attaque toxique

- validation visuelle acceptée ; publié l'atlas d'attaque, le projectile et
  l'impact sous `art/` avec les SHA des exports candidats ;
- ajouté `vacuum_trooper_attack_frames.tres`, les frames projectile/impact et
  `ProjectileData` `toxic_pressure` ;
- ajouté `EnemyAttackComponent` dans le SceneTree : détection par portée,
  anticipation en huit poses, émission à la frame `release`, récupération et
  reprise de la patrouille ;
- ajouté `AttackOrigin` visible et transformé selon l'orientation du Trooper ;
- validations Godot `FOUNDATION_SMOKE_TEST`, `ENEMY_CONTRACT_TEST` et
  `ASSET_PIPELINE_CONTRACT_TEST` passées ;
- point de restauration publié : `72e8c5e` (candidats), intégration en cours.

## 2026-08-27 — Correction du pivot arme joueur gauche/droite

- identifié que `AimPivot.rotation = aim_direction.angle()` retournait aussi
  visuellement l'arme lorsque le joueur visait à gauche ;
- conservé la rotation complète nécessaire à la direction du tir et ajouté un
  miroir vertical du pivot côté gauche, sans modifier `Muzzle`, la collision ou
  la trajectoire du projectile ;
- `PLAYER_CONTRACT_TEST` et `ENEMY_CONTRACT_TEST` passent après correction.

## 2026-08-27 — Première boucle de mort et respawn

- ajouté `PlayerHealthComponent.reset_health()` comme commande unique de remise
  à zéro des PV ;
- relié `MissionActorSpawner2D` au signal `died` du joueur, avec délai
  configurable et remplacement de l'acteur dans `Actors` ;
- exposé `respawn_spawn_id` dans l'Inspector, initialisé sur `player_start` pour
  la première tranche ;
- validations `PLAYER_CONTRACT_TEST`, `MAP_CONTRACT_TEST` et démarrage headless
  de la mission passés ;
- limite connue : aucun déclencheur de checkpoint ne met encore à jour
  `respawn_spawn_id` automatiquement.

## 2026-08-27 — FSM commune joueur et ennemis

- ajouté `ActorStateMachineComponent` comme composant réutilisable avec les
  états `IDLE`, `RUN`, `ATTACK`, `HURT`, `DEAD` et `RESPAWN` ;
- branché la FSM au joueur canonique en plus du Vacuum Trooper ; les dégâts et
  la mort du joueur passent désormais par des transitions signal-driven ;
- règle rétroactive : tout placeholder du megapack devra recevoir cette FSM dès
  sa scène canonique, même si son comportement complet arrive plus tard ;
- `PLAYER_CONTRACT_TEST` et `ENEMY_CONTRACT_TEST` passent.

## 2026-08-27 — Transitions FSM du joueur

- étendu la FSM commune avec `SHOOT`, `JUMP` et `FALL` ;
- relié le mouvement aux transitions `IDLE/RUN/JUMP/FALL` ;
- relié le tir à `SHOOT`, en conservant les états `HURT` et `DEAD` prioritaires ;
- les transitions restent dans les composants de mouvement et d'arme, donc
  réutilisables par les futurs acteurs et placeholders.

## 2026-08-27 — Nomenclature des ennemis du megapack

- inventorié le megapack industriel toxique : quatre silhouettes ennemies,
  neuf props, neuf terrains, quatre pickups et quatre familles d'armes ;
- confirmé le mapping gameplay demandé : Siphoner → `Grunt`, Scout Drone →
  `Flying enemy`, Brute → `Boss`, Hatchling Saboteur → pilote éjecté ;
- enregistré cette table dans
  `pipeline/assets/working/megapacks/industrial_toxic_v001/enemy-role-mapping-v001.md` ;
- conservé `vacuum_trooper`, `vacuum_brute` et `vacuum_siphoner` comme identifiants
  legacy jusqu'à la normalisation et l'intégration des nouvelles scènes ;
- aucune source du megapack n'est encore publiée ni utilisée par le runtime.
- correction de design : l'éjection du pilote appartient à
  `vacuum_trooper`, jamais à `vacuum_boss` ; le boss aura un lifecycle séparé.

## 2026-08-27 — Boucle de victoire Côte toxique

- conservé la scène maîtresse comme autorité des objectifs : les rencontres
  activées choisissent `required_for_completion` dans l'Inspector et
  `Gameplay/Exits/MissionEnd` possède la sortie ;
- ajouté `MissionRunController` comme Node d'orchestration visible dans l'écran
  prototype ; il suit les ennemis par les signaux du spawner et de Health sans
  recopier les identifiants auteur ;
- empêché qu'une rencontre pas encore apparue soit confondue avec une rencontre
  éliminée, puis garanti que `mission_won` n'est émis qu'une fois ;
- affiché le panneau « Mission accomplie » lorsque le joueur atteint la sortie
  après avoir éliminé les deux Vacuum Troopers obligatoires ;
- intégré les checkpoints du pont et de la fonderie et rangé le baril placé sous
  `Gameplay/Interactions`, sans modifier son Transform auteur ;
- documenté le contrat auteur de victoire, complété le glossaire des cinq
  classes manquantes et restauré les infobulles Inspector exigées par le
  validateur transversal ;
- ajouté `mission_run_contract_test.gd` et étendu `map_contract_test.gd` pour
  protéger objectifs, sortie, checkpoints, baril et résultat visible ;
- validation réelle : les 24 contrats headless et le démarrage complet du
  projet avec arrêt après 240 frames passent ;
- limites volontaires : checkpoints sans feedback, résultat sans score ni
  enchaînement de mission ; prochaine action recommandée : équilibrer le tir
  toxique puis ajouter le feedback des checkpoints.

## 2026-08-28 — Roster ennemi complet et poses gameplay

- généré avec ImageGen intégré quatre planches strictes 4×4, chacune composée
  de quatre poses de déplacement, quatre d'attaque propre au rôle, quatre
  d'impact et quatre de mort ; les quatre identités sources du megapack sont
  conservées et les essais statiques rejetés ont été sortis du workspace ;
- ajouté un processeur déterministe de fond cyan vers alpha, normalisé les 64
  poses sur quatre canevas/root auteurs et publié les atlas sous
  `art/enemies/industrial_toxic/`, avec revues, aperçus, manifeste, provenance,
  recette et QA conservés sous `pipeline/assets/` ;
- créé les scènes, profils, bindings et `SpriteFrames` de `vacuum_grunt`,
  `vacuum_flying`, `vacuum_boss` et `vacuum_pilot_saboteur`, puis enrichi
  `enemy_catalog.tres` sans renommer le Trooper existant ;
- étendu le profil et Patrol avec un mode volant data-driven ; généralisé
  Attack aux animations propres au rôle, aux projectiles et au contact
  autodestructeur ;
- ajouté `EnemyEjectionComponent` dans le SceneTree du Trooper : sa mort fait
  apparaître un véritable Saboteur autonome dans `Actors` ;
- activé dans Côte toxique deux Grunts, deux Drones et un Boss en plus des deux
  Troopers ; les sept ennemis principaux sont obligatoires pour ouvrir la
  sortie, tandis que les pilotes éjectés restent hors du décompte de mission ;
- autorités : profils pour identité/locomotion, composants de scène pour
  attaque et éjection, `SpriteFrames` pour poses/timings, catalogue pour la
  correspondance et marqueurs de carte pour placement/objectif ;
- validation réelle : processeur et validateur raster passés, 24 contrats
  headless passés, démarrage complet du projet pendant 240 frames passé et
  `git diff --check` propre ;
- limite volontaire : le Boss utilise encore le projectile toxique commun ;
  prochaine action recommandée : équilibrer la rencontre jouée puis produire
  son projectile lourd dédié.

## 2026-08-28 — Enemy cadence Resource-first et Combat Gates

- remplacé les marqueurs plats `archétype + quantité` par la chaîne auteur
  `EnemySpawnPatternData → WaveData → EncounterData → MapEncounterMarker2D` ;
- publié six formations génériques (`Centered Line`, directions latérales,
  `Vertical Stack`, `Pincer`, offsets libres), les intervalles d'apparition,
  les respirations et les transitions `When Cleared` / `After Delay` ;
- ajouté les beats `Pressure`, `Release`, `Escalation`, `Payoff` et les types
  `Standard`, `Combat Gate`, `Kill Room`, `Gauntlet`, `Set Piece`, `Arena` dans
  des Resources visibles et validées dans l'Inspector ;
- séparé `MissionEncounterController`, autorité de l'état des vagues, de
  `MissionEnemySpawner2D`, désormais limité à la traduction catalogue et à
  l'instanciation ; `MissionRunController` ne consomme plus que les fins de
  rencontres obligatoires ;
- composé Côte toxique en trois rencontres, sept vagues et douze apparitions :
  Landing Pressure/Release, Bridge Pressure/double Escalation avec chevauchement
  temporel, Foundry Pressure/Payoff Boss ;
- ajouté trois `MissionCombatGate2D` sous `Gameplay/Encounters` : leur collision
  World empêche réellement de court-circuiter un segment, puis leur visuel et
  leur collision disparaissent à la fin de la cadence correspondante ;
- ajouté l'aperçu coloré des formations sur chaque Marker dans l'éditeur et un
  feedback HUD indiquant rencontre, beat et numéro de vague actifs ;
- ajouté `ENCOUNTER_AUTHORING_CONTRACT.md`, étendu contrats carte/ennemi,
  glossaire, plan Côte toxique et validations récursives de la scène maîtresse ;
- ajouté `encounter_cadence_contract_test.gd` : il protège Resources, catalogue,
  géométrie Pincer/Vertical Stack, ordre des sept vagues, chevauchement réel du
  Gauntlet, total de douze ennemis, HUD et ouverture des barrières ;
- remplacé les coroutines de temporisation par un automate de cadence piloté
  par les frames après avoir détecté une reprise asynchrone lors de la
  destruction anticipée de l'écran ; quitter ou recharger une map est propre ;
- validation réelle : les 25 contrats headless passent sans erreur, ainsi que
  le démarrage complet du projet avec arrêt après 240 frames ;
- limite volontaire : Kill Room/Arena n'ont pas encore leur verrou caméra et
  Set Piece n'orchestre pas encore audio/VFX ; prochaine action recommandée :
  construire les phases et le projectile lourd du Boss comme premier Set Piece.

## 2026-08-28 — Dégâts lisibles et Hurtbox du Boss

- reproduit un impact réel de `FieldRound2D` sur le Boss : les dégâts étaient
  acceptés au centre, mais le collider de 132 px ne couvrait pas la coque
  raster d'environ 238 px, donnant l'impression que les tirs la traversaient ;
- ajouté une Hurtbox auteur 260 × 175 sous la scène Boss et retiré sa couche de
  réception du corps physique : la Hurtbox est désormais l'autorité unique des
  impacts, tandis que le CharacterBody conserve mouvement et collision World ;
- désactivé automatiquement cette Hurtbox à la mort depuis
  `EnemyCharacter2D` ;
- ajouté au HUD une barre « Brute aspirante » directement reliée au signal
  `health_changed` de `EnemyHealthComponent` ;
- étendu les tests avec un tir passant hors de l'ancien collider mais dans la
  silhouette visible, et avec la barre atteignant zéro pendant le run complet.
- validation réelle : les 25 contrats headless et le démarrage complet pendant
  240 frames passent après le correctif.

## 2026-08-28 — Reprise exhaustive des 88 poses ennemies v002

- audité les cinq archétypes consommables de la mission et refusé les grilles
  v001 dont les cases illustraient une action sans former une vraie séquence ;
- utilisé ImageGen en édition/dérivation depuis les cinq identités sources et
  produit une bande séparée par action : locomotion, attaque, impact et mort ;
  le Trooper conserve huit poses de marche et huit d'attaque, soit 88 poses au
  total pour le bestiaire ;
- rejeté puis régénéré le mouvement et le hit du Drone parce qu'une turbine
  disparaissait, ainsi que l'attaque du Boss dont le rayon touchait la frontière ;
- ajouté `process_enemy_animation_roster_v002.py` : extraction cyan, suppression
  des composants détachés au bord, échelle commune par action, root auteur,
  sept atlas, cinq revues et cinq aperçus ;
- détecté avant publication une incompatibilité Trooper 256 × 256 contre les
  régions Godot 256 × 192, puis corrigé le pipeline à `[256,192]` et root
  `[128,180]` ;
- publié sans écraser les v001 et migré les six Resources `SpriteFrames` vers
  les PNG v002 ; timings et frames actives restent autorités Godot ;
- ajouté recette, provenance, manifeste, QA, validateur Python et test Godot
  dédié protégeant les 88 poses, sept atlas, alpha, hashes et dimensions ;
- validations réelles : processeur PASS, validateur `88 poses / 7 atlas / 5
  archetypes` PASS, import Godot PASS et
  `ENEMY_ANIMATION_ROSTER_V002_TEST: PASS` ;
- le contrat ennemi global charge toutes les animations v002 mais reste bloqué
  plus loin par les marqueurs Landing d'une modification parallèle de
  `toxic_coast.tscn` ; au dernier passage, la rencontre bloquante
  `landing_cadence2` n'avait pas de Combat Gate. Cette carte n'a pas été
  corrigée ni écrasée dans cette tranche ;
- prochaine action : rétablir la correspondance valide entre les marqueurs
  Landing et leurs Combat Gates, relancer les contrats complets puis faire la
  revue jouée de cadence à taille réelle.

## 2026-08-28 — Arborescence Godot lisible et séparation auteur/runtime

- conservé l'architecture Resource-first existante et refondu sa représentation
  dans le SceneTree afin que chaque branche décrive son contenu réel ;
- renommé les branches de map `SpawnPoints`, `EnemySpawns` et `Encounters` en
  `PlayerSpawnPoints`, `EncounterMarkers` et `CombatGates` ;
- créé `Runtime` avec quatre responsabilités explicites : `Actors`,
  `Projectiles`, `Effects` et `DestructibleTerrain` ; déplacé silhouettes,
  explosion de démonstration et caméra d'édition sous `EditorPreview` ;
- regroupé les cinq services techniques de l'écran de mission sous
  `RuntimeSystems`, tout en gardant `MapHost` et `MissionCameraRig` visibles à
  leur niveau d'orchestration ;
- supprimé le doublon de nom `Presentation` des scènes joueur et ennemies : le
  composant devient `Components/Animation`, la représentation `Visuals`, et le
  pivot de pente `GroundPivot` piloté par `Components/SlopeAlignment` ;
- ajouté à `MissionMapRoot2D` des correspondances typées vers Runtime,
  Projectiles, Effects, DestructibleTerrain, EditorPreview, PlayerSpawnPoints,
  EncounterMarkers et CombatGates afin que les contrôleurs ne répètent plus les
  chemins métier ;
- migré tous les NodePath, pistes AnimationPlayer, spawners, contrôleurs,
  tests, contrats auteur et correspondances du manifeste sans modifier les
  Resources d'autorité gameplay ;
- préservé `LandingCadence2`, désormais valide et non bloquante ; le contrat de
  cadence dérive son total depuis tous les Markers actifs et vérifie quinze
  instances pour l'état auteur courant au lieu de figer douze apparitions ;
- renforcé les contrats pour refuser le retour des anciennes branches et
  vérifier la séparation `Gameplay` / `Runtime` / `EditorPreview`, le groupe
  `RuntimeSystems` et l'absence des deux anciens `Presentation` ;
- validation réelle : `git diff --check` propre et les 26 contrats Godot
  headless passent ;
- limite volontaire : les deux rencontres Landing sont proches du départ et
  leurs seuils se chevauchent probablement ; prochaine action recommandée :
  revue jouée des quinze apparitions, puis stabilisation différée des collisions
  destructibles et des références de tireur libérées.

## 2026-08-28 — Reconstruction physique différée du terrain destructible

- confirmé dans le journal Godot 660 répétitions d'une seule erreur : un impact
  projectile reconstruisait les `StaticBody2D` et `CollisionPolygon2D` pendant
  le traitement physique de `body_entered` ;
- conservé comme autorités les zones et Ground Pieces auteur, puis le masque et
  `BitMap` runtime ; seule leur représentation physique dérivée change de
  temporalité ;
- séparé dans `DestructibleTerrain2D` la modification immédiate du masque/rendu
  et la reconstruction différée des collisions via `call_deferred` ;
- ajouté une file dictionnaire de coordonnées sales : plusieurs impacts sur le
  même chunk dans une frame produisent un seul rebuild, trié de manière
  déterministe ;
- exposé le nombre de chunks en attente, le nombre de flushs et le signal
  `collision_chunks_rebuilt` afin que le comportement soit inspectable et
  testable sans devenir une seconde autorité gameplay ;
- cette correction appartient au terrain global : toute future zone et toute
  future `GroundPiece2D` en mode `Carvable` en bénéficient automatiquement ;
- ajouté `destructible_terrain_deferred_rebuild_test.gd`, qui déclenche deux
  cratères depuis une vraie callback physique `body_entered`, vérifie zéro
  rebuild synchrone, un seul flush et un rebuild unique par chunk ;
- renforcé les tests terrain, projectile et stamp de Ground Piece pour vérifier
  masque immédiat, file différée et héritage par les futures pièces ;
- validation réelle : nouveau test physique PASS, tests terrain/explosion/
  projectile/Ground Piece PASS, puis suite globale de 27 contrats headless PASS
  et `git diff --check` propre ;
- limite restante : la référence `shooter` d'un projectile doit encore être
  protégée par `is_instance_valid()` lorsque son acteur est libéré.

## 2026-08-28 — Contours concaves et durée de vie des projectiles

- reproduit depuis le journal joué les deux erreurs restantes après le flush
  différé : échec de décomposition convexe d'un contour creusé et accès à un
  `shooter` déjà libéré ;
- conservé le masque/`BitMap` comme autorité de la matière et publié ses
  contours physiques dérivés comme triangles `ConvexPolygonShape2D` solides,
  adaptés aux cratères concaves sans décomposition convexe implicite ;
- centralisé la validation de `Projectile2D.shooter` : un projectile survivant
  à son acteur oublie la référence libérée avant les exclusions de raycast et
  les tests d'ascendance ;
- renforcé les contrats terrain et projectile avec la vérification des formes
  triangulaires solides et un tireur explicitement libéré avant sa munition ;
- validations réelles : `destructible_terrain_test.gd`,
  `destructible_terrain_deferred_rebuild_test.gd`,
  `destructible_terrain_collision_alignment_test.gd`,
  `projectile_carvable_integration_test.gd` et
  `weapon_projectile_integration_test.gd` passent, `git diff --check` propre ;
- limite hors tranche : la carte auteur locale reste en cours d'édition autour
  de `LandingFly` et `bridge_gauntlet.tres` ; ces données n'ont pas été corrigées
  ou écrasées par le refactor runtime.

## 2026-08-28 — Durcissement structurel et workflow auteur des rencontres

- ajouté `scripts/run-tests.sh` avec profils `structure`, `content` et `all` :
  chaque test possède ses répertoires Godot isolés et toute sortie `ERROR` ou
  `WARNING` fait échouer le runner même si le processus retourne zéro ;
- publié la CI Godot 4.7.1 et séparé les invariants architecturaux des snapshots
  de cadence, afin qu'une modification volontaire dans l'Inspector ne ressemble
  plus à une casse du runtime ;
- fait piloter le chargement par `PrototypeMissionScreen` après une frame : le
  `MissionMapHost2D` émet désormais loading/loaded/failed et l'écran affiche
  chargement ou diagnostic au lieu d'un viewport gris silencieux ;
- ajouté sur `MapEncounterMarker2D` l'avertissement immédiat des IDs frères
  dupliqués, le bouton Inspector `Générer un Encounter ID unique` et l'alerte
  sur les recettes encore intégrées à la scène ; la Resource partagée reste
  volontairement réutilisable et n'est jamais copiée silencieusement ;
- placé les budgets physiques dans `DestructibleTerrainProfile` et exposé leur
  validation runtime ; Côte toxique publie 96 corps, 640 formes et neuf chunks
  par flush comme limites inspectables ;
- remplacé les 904 triangles initiaux par 434 pièces convexes pleines obtenues
  par fusion sûre, réduisant les Nodes mesurés de 1119 à 649 ; après vingt
  petits cratères concentrés, la mesure reste à 522 formes ;
- extrait la géométrie pure dans `TerrainCollisionBuilder` sans lui transférer
  d'état ni d'autorité, et remplacé le dictionnaire libre de cadence par
  `EncounterRuntimeState` et son enum de phases ;
- renforcé les contrats carte, mission, terrain et auteur ; validation finale :
  `./scripts/run-tests.sh structure` passe 26/26 sans erreur ni warning Godot ;
- limite volontaire : le coût froid reste proche de 3,57 s en headless et le
  snapshot de contenu attend la décision auteur sur LandingFly/Bridge.

## 2026-08-28 — Composition ennemie canonique sans nouvelle classe

- remplacé la copie manuelle de Patrol, Health, Attack, StateMachine et
  Animation dans les cinq scènes ennemies par une instance éditable commune de
  `characters/enemies/enemy_components.tscn` ;
- conservé dans chaque scène d'archétype uniquement son profil, ses réglages
  d'attaque, sa collision, sa présentation et ses composants optionnels
  Grounding, SlopeAlignment ou Ejection ;
- n'a ajouté aucun nouveau `class_name`, Profile, Data, Definition, Binding ou
  Catalog : la factorisation utilise uniquement la composition de scènes native
  de Godot ;
- renforcé `enemy_contract_test.gd` pour refuser toute scène du roster qui
  recopierait la branche Components au lieu d'instancier la composition
  canonique ;
- validation ciblée réelle : `enemy_contract_test.gd` passe avec les cinq
  archétypes, y compris dégâts, mort animée, suppression différée, éjection,
  Hurtbox du Boss et spawn de mission ;
- validation structurelle globale : 25 contrats sur 26 passent ; l'unique
  échec est le `map_contract_test.gd` déjà affecté par les données auteur
  locales LandingFly/Bridge hors de cette tranche ;
- limite volontaire : les autorités de données `EnemyArchetypeProfile`,
  `EnemySceneBinding` et les réglages locaux d'Attack restent inchangés ; leur
  consolidation éventuelle constitue une tranche séparée.

## 2026-08-29 — Resources de rencontres proportionnées à leur réutilisation

- conservé cinq recettes `EncounterData` externes et assignables depuis les
  Markers de Côte toxique ; externalisé notamment l'ancienne recette intégrée
  `LandingCadence2` et rangé `LandingFly` avec les autres recettes de mission ;
- intégré dans leur parent toutes les Waves et tous les Spawn Patterns utilisés
  une seule fois, sans modifier leurs identifiants, ordres, beats, formations,
  quantités, offsets ou délais auteur actuellement présents ;
- conservé externes uniquement `landing_pressure.tres`,
  `landing_release.tres` et `bridge_flying_column.tres`, car ces trois Resources
  possèdent réellement plusieurs consommateurs ;
- supprimé douze fichiers `.tres` mono-usage et ajouté un seul fichier de
  recette explicite pour `LandingCadence2`, soit onze fichiers de moins sans
  nouvelle classe runtime ;
- ajouté `encounter_resource_structure_test.gd`, qui protège automatiquement la
  frontière entre recette externe, sous-resource mono-usage et donnée partagée ;
- validations réelles : nouveau contrat structurel PASS, `git diff --check`
  propre et profil structure à 26/27 ; l'unique échec reste le Marker/Gate
  Bridge absent de la scène auteur ; le profil contenu retrouve séparément les
  cinq écarts Bridge déjà présents avant cette migration ;
- limite volontaire : les choix auteur en cours — ordre et population Bridge,
  absence actuelle du Marker/Gate Bridge et nouvelle occurrence LandingFly —
  sont préservés tels quels et ne sont pas acceptés comme nouveau snapshot de
  contenu par cette tranche structurelle.

## 2026-08-29 — Feedback de dégâts et de mort du joueur

- conservé `PlayerHealthComponent` comme autorité des PV et
  `ActorStateMachineComponent` comme autorité de l'état runtime ;
- étendu `Components/Animation` sans créer de contrôleur parallèle : il traduit
  désormais `HURT` et `DEAD` vers la pose raster et les animations de feedback ;
- ajouté dans l'`AnimationPlayer` de la scène canonique les timings auteurs
  `damage` et `death` : flash/secousse de 0,22 s, puis disparition de 0,75 s ;
- corrigé le cycle incomplet de `HURT` : la fin de `damage` restaure maintenant
  automatiquement `IDLE`, `RUN`, `JUMP` ou `FALL` selon le CharacterBody2D ;
- conservé la pose `hurt` comme représentation provisoire de mort, sans créer
  ni publier d'asset artificiel hors du pipeline ;
- ajouté `player_feedback_contract_test.gd`, qui protège pose, timings,
  transition de reprise et disparition avant le respawn de 0,8 s ;
- validations réelles : contrats feedback, joueur et intégration des assets
  joueur PASS ; profil structure global à 27/28, avec le seul
  `map_contract_test.gd` déjà hors tranche en échec sur rencontre/Gate Bridge et
  rotation auteur de la corniche ; `git diff --check` propre ;
- prochaine action recommandée : ajouter l'audio, le recul du corps et la
  secousse caméra en gardant leurs autorités séparées de Health.

## 2026-08-29 — Recul corporel et secousse caméra sans audio

- reporté explicitement l'audio afin de poursuivre la finalisation du gameplay
  sans publier de placeholders sonores comme assets définitifs ;
- ajouté `Components/Recoil` et son AnimationPlayer à la scène joueur : la
  courbe normalisée de 0,12 s est auteur, tandis que le composant applique la
  direction opposée du tir aux pivots Body et Aim sans déplacer le corps physique ;
- ajouté à `WeaponData` les autorités par arme Body Recoil Distance, Camera
  Shake Strength et Camera Shake Duration ;
- relié `PlayerWeaponComponent.fired` au `MissionCameraRig2D`, qui borne toute
  demande non nulle avec son profil et écrit uniquement `Camera2D.offset` ;
- après contrôle joué, réglé explicitement le canon automatique à zéro secousse :
  chaque balle conserve le recul local mais le viewport reste parfaitement stable ;
- renforcé les contrats joueur, caméra et projectile avec un vrai tir, le recul
  visible, le retour exact aux positions auteur, l'offset nul du canon courant
  et une commande de secousse lourde testée séparément ;
- validations ciblées réelles : `player_contract_test.gd`,
  `mission_camera_progression_test.gd` et
  `weapon_projectile_integration_test.gd` PASS sans erreur ni warning Godot ;
- prochaine action recommandée : poursuivre le gameplay par Interaction et
  pickups, l'audio restant volontairement hors tranche.

## 2026-08-29 — Première chaîne caisse et pickup de soin

- sélectionné l'injecteur de soin du megapack industriel toxique, rejeté deux
  extractions génératives qui altéraient inutilement le dessin, puis publié la
  source valide sur alpha réel avec un processeur déterministe 192 × 192 ;
- créé le lot traçable `health-injector-pickup-v001` avec recette, manifeste,
  provenance, export, copie runtime et rapport QA séparés de l'importeur Godot ;
- ajouté `PickupData` et la scène canonique `Pickup2D` : l'effet soin appelle
  uniquement `PlayerHealthComponent.heal()` et le pickup reste présent lorsque
  le joueur est déjà à son maximum ;
- ajouté `Components/Interaction` au joueur, son volume inspectable, son prompt
  et la sélection de la cible `interaction_targets` la plus proche ; complété
  clavier `F`, manette Y et septième commande tactile sans lecture d'entrée dans
  la caisse ;
- étendu `SupplyCrateData` avec `Contents Scene`, ajouté `ContentsOrigin` et
  garanti une seule occurrence top-level qui n'hérite pas de l'échelle de la
  caisse placée sous `Gameplay/Interactions/LandingSupplyCrate` ;
- publié `PICKUP_INTERACTION_AUTHORING_CONTRACT.md`, synchronisé glossaire,
  contrats joueur/input/map et manifeste des assets ;
- ajouté `pickup_interaction_contract_test.gd`, qui valide détection, prompt,
  ouverture, spawn unique, collecte et soin ; corrigé en parallèle le test de
  projectile pour attendre une frame physique avant de mesurer son déplacement ;
- validation structurelle réelle : 28 contrats sur 29 passent ; l'unique échec
  reste `map_contract_test.gd` sur les trois données auteur Bridge/corniche déjà
  connues, sans lien avec cette tranche ; `weapon_projectile_integration_test.gd`
  repasse après restauration de sa synchronisation physique ;
- prochaine action gameplay recommandée : définir l'autorité des réserves de
  munitions avant de publier le pickup tambour, afin d'éviter un item sans
  consommateur canonique.

## 2026-08-29 — Partition de combat Côte toxique v001

- formalisé la mission sur six plans auteur — dramatique, spatial, tactique,
  rythmique, économique et spectaculaire — dans
  `TOXIC_COAST_COMBAT_SEQUENCE_V001.md`, sans ajouter de nouvelle abstraction
  runtime ;
- supprimé les occurrences concurrentes `LandingCadence2`, `LandingFly` et les
  deux Markers anonymes afin de restaurer exactement un acte par segment ;
- déplacé les seuils après les zones de préparation : caisse avant Landing,
  déclenchement du Pont dans son propre segment et checkpoint avant Fonderie ;
- recomposé Landing en deux Troopers puis un Grunt, le Pont en pression terrestre
  puis deux Drones chevauchés et une pince, et la Fonderie en deux Grunts, un
  Drone de déplacement puis le Boss après une seconde de silence ;
- restauré `BridgeCombatGate`, rendu les trois portes visibles, rétabli la
  rotation auteur −35° de la corniche et replacé le bunker dans la branche
  `Gameplay/GroundPieces` ;
- placé un baril d'apprentissage au Pont et un baril de maîtrise dans la
  Fonderie, tandis que la caisse de soin reste la ponctuation de découverte du
  débarquement ;
- intégré toutes les Waves et Patterns désormais mono-usage dans leurs trois
  recettes `EncounterData`, puis supprimé les anciens fichiers prétendument
  partagés ;
- renforcé les contrats map, structure Resource et cadence : trois actes, huit
  vagues, treize apparitions, seuils par segment, deux props tactiques,
  chevauchement aérien du Pont et entrée finale du Boss sont vérifiés ;
- les validations ciblées `map_contract_test.gd`,
  `encounter_resource_structure_test.gd`, `encounter_cadence_contract_test.gd`,
  `mission_run_contract_test.gd` et `toxic_coast_content_pack_test.gd` passent ;
- prochaine action recommandée : playtest chronométré de chaque beat avant de
  définir réserves de munitions et pickup tambour.

## 2026-08-30 — Expansion industrielle sans doublons et Côte toxique 7680

- audité les 38 candidats du megapack dans une matrice explicite : 11 contenus
  déjà intégrés ou supplantés restent exclus, 27 sorties inédites sont retenues ;
- publié ces 27 bitmaps avec recette, processeur déterministe, manifeste,
  provenance, exports et QA, puis validé leur import Godot ;
- étendu le Ground Kit de quatre à dix pièces avec culée, mur destructible,
  tour, plateforme de fonderie, arche traversable et barricade Breakable ;
- ajouté stations médicale et munitions, projecteur, relais radio, mine et évent
  selon quatre contrats existants distincts plutôt qu'un système de props opaque ;
- ajouté `PlayerCombatInventoryComponent` et son profil comme autorités uniques
  des munitions spéciales, de l'armure et de l'Overdrive ; publié les trois pickups ;
- publié quatre familles complètes — acide, électrique, implosion et démolition
  — avec WeaponData, ProjectileData, scènes et impacts animés ; quatre
  `ServiceStationData` réutilisent le casier unique pour les rendre équipables ;
- reconstruit Côte toxique sur 7680 × 720 en trois actes de 2560 px et placé les
  nouveautés selon une fonction de lecture, de décision ou de récompense ;
- porté le budget du terrain à 144 chunks et 960 formes pour cette autorité de
  taille ; `map_contract_test.gd` vérifie encore les budgets effectifs ;
- validation complète PASS : profil `structure` 30/30, profil `content` 1/1
  et `git diff --check` propre ;
- limite volontaire : le pacing et la lisibilité visuelle des placements
  exigent maintenant un playtest réel, pas un nouveau système ;
- prochaine action recommandée : jouer les trois actes et noter durée, dépenses
  de munitions, choix d'armurerie, dégâts, armure et usage de l'Overdrive.

## 2026-08-30 — Backgrounds dédiés aux trois actes

- corrigé l'omission de la première refonte : les anciens panoramas v001
  répétés ne représentaient ni le pont acide ni la fonderie ;
- audité les sources existantes et refusé de recycler les backgrounds de menu,
  qui constituent des compositions opaques hors contrat de mission ;
- généré trois sources ImageGen distinctes : côte militaire, ravin du pont
  acide et fonderie aspirante avec réacteur d'implosion ;
- ajouté un pipeline déterministe qui cadre en 16:9, publie en 2560 × 720 et
  assombrit progressivement la bande basse pour préserver le gameplay ;
- remplacé les trois anciens `Parallax2D` répétés par
  `Visual/SegmentBackgrounds`, dont chaque Sprite2D correspond exactement aux
  bornes d'un `MapSegment2D` ;
- renforcé `map_contract_test.gd` : trois backgrounds, dimensions, centres et
  absence des anciens parallaxes sont désormais contractuels ;
- ajouté deux raccords dérivés 384 × 720, visibles dans le SceneTree et centrés
  sur les frontières x=2560 et x=5120 ;
- validation complète PASS après intégration : profil `structure` 30/30,
  profil `content` 1/1 et `git diff --check` propre ;
- limite volontaire : contrôler en jeu les deux raccords de segment et le
  contraste réel derrière personnages, projectiles et VFX.

## 2026-08-30 — Correction du débogueur projectile toxique

- reproduit les deux erreurs runtime du débogueur : `%Visual` introuvable puis
  assignation de texture sur une instance nulle dans `Projectile2D` ;
- identifié la cause : les nouvelles munitions utilisent un `Sprite2D` bitmap,
  tandis que `ToxicPressure2D` possède légitimement un `AnimatedSprite2D` ;
- rendu le Sprite2D bitmap optionnel sans toucher à l'animation toxique, aux
  primitives Tracer/Core ni à leur autorité `ProjectileData` ;
- ajouté une régression dans `weapon_projectile_integration_test.gd` qui
  instancie le projectile toxique et vérifie que son animation joue sans erreur ;
- retiré deux anciens fichiers mono-usage non référencés réapparus sur disque ;
  leurs sous-resources autoritaires restent intégrées aux EncounterData ;
- validation : les 29 autres contrats structurels passaient déjà, puis les
  contrats projectile et structure Encounter corrigés repassent sans erreur ;
  `git diff --check` reste propre.

## 2026-08-30 — Mode Flux Libre sans Combat Gates

- supprimé la branche `Gameplay/CombatGates` et ses trois barrières de la scène
  maîtresse ; `MissionMapRoot2D` et `MissionEncounterController` n'en dépendent
  plus au runtime ni en validation ;
- rendu Landing et Pont facultatifs via leurs `EncounterData`, tandis que la
  finale Fonderie passe en `Arena` et reste le seul objectif de victoire ;
- désactivé le verrou arrière dans `arcade_forward_camera.tres` et signé le
  look-ahead avec la direction de visée pour permettre un vrai retour gauche ;
- renforcé `MissionActorSpawner2D.set_respawn_spawn()` : un spawn situé derrière
  le checkpoint courant ne peut jamais devenir l'autorité de reprise ;
- adapté les contrats carte, cadence, mission et caméra : absence de portes,
  Boss unique obligatoire, retour caméra et checkpoint monotone sont vérifiés ;
- conservé `MissionCombatGate2D` comme vocabulaire réservé aux futures missions
  fermées, sans aucune occurrence dans Côte toxique.
- validation complète PASS : profil `structure` 30/30, profil `content` 1/1
  et `git diff --check` propre.
# 2026-08-30 — Caméra stable lors des changements de direction

- neutralisé le look-ahead du profil de la Côte toxique afin qu'un demi-tour du
  joueur ne déplace plus le cadre ;
- conservé le look-ahead comme option explicite pour de futurs profils caméra ;
- ajouté une régression vérifiant qu'un changement de visée sans déplacement ne
  modifie pas la position du CameraRig.

## 2026-08-30 — Profondeur et atmosphères animées de Toxic Coast

- conservé les trois panoramas v002 comme identité lointaine autoritaire et
  restauré deux bitmaps transparents historiques comme `MidgroundParallax` et
  `ForegroundParallax`, sans réintroduire le fond opaque v001 ;
- créé la scène canonique `EnvironmentFX2D` composée de trois
  `GPUParticles2D`, d'un flash, de deux branches `Line2D`, d'un `Timer` et d'un
  `AnimationPlayer` ;
- créé trois `EnvironmentFXProfile` pour le débarquement, le pont acide et la
  fonderie, puis placé leurs instances et origines dans la scène maîtresse ;
- établi `ENVIRONMENT_VISUAL_AUTHORING_CONTRACT.md` : la Resource possède le
  climat, la scène possède le placement et aucun effet ne contrôle le gameplay ;
- mis à jour le manifeste pour rendre explicite la réactivation du midground
  v001 et du foreground v002, sans créer de nouvel asset ni doublon ;
- ajouté `environment_fx_contract_test.gd` et renforcé le contrat carte ; la
  validation finale passe 31/31 en structure, 1/1 en contenu, 240 frames
  runtime sans erreur et `git diff --check` propre ;
- limite volontaire : le renderer headless factice ne permet pas la capture,
  donc densité, contraste et cadence des éclairs restent à valider visuellement
  dans Godot interactif.

## 2026-08-30 — HUD Toxic Commando orienté arsenal

- importé les trois planches sources du thème Toxic Commando dans le pipeline,
  sans référencer le pack externe depuis Godot ;
- créé un processeur déterministe isolant les composants alpha principaux : six
  cadres, douze icônes, un portrait joueur dérivé et une planche de contrôle ;
- corrigé une première composition sémantiquement fausse après revue : le grand
  cercle affiche désormais le portrait du commando, tandis que le cœur reste un
  petit repère de la barre de vie ;
- supprimé les icônes Boss et Overdrive du layout, leurs cadres portant déjà
  ces emblèmes, et réservé les slots inférieurs aux futurs statuts réels ;
- créé `MissionHUDTheme` et `MissionHUD` ; le layout observe Health, Weapon,
  CombatInventory et Boss Health sans posséder leurs données ;
- ajouté `weapon_changed` et une fenêtre consommant directement
  `WeaponData.weapon_texture` ; les cinq armes publiées sont couvertes par le
  même contrat sans condition sur `weapon_id` ;
- confié le choix de thème à `MissionMapDefinition.hud_theme` pour permettre aux
  futures missions de changer de peau sans modifier l'écran ou les composants ;
- remplacé les anciens panneaux de debug et masqué le bouton Retour pendant le
  gameplay ; Pause/Options reste la prochaine autorité de navigation à créer ;
- ajouté le contrat auteur HUD, le manifeste du lot et
  `mission_hud_contract_test.gd` ; validation finale 32/32 en structure, 1/1 en
  contenu, pipeline reproductible sur 19 sorties et `git diff --check` propre.

## 2026-08-30 — Boot/Start illustré et ressenti typographique

- repris le lot candidat `industrial-toxic-boot-start-flow-v001` déjà conservé
  dans le pipeline et publié dix-neuf livrables par découpe et normalisation
  déterministes, sans dépendance runtime vers le dépôt externe ;
- créé `BootStartFlowTheme`, panneau Resource autoritaire des quatre
  backgrounds, de l'emblème, des cadres, des ornements et des six marqueurs ;
- remplacé les glyphes et concept boards provisoires du Boot/Start par les
  illustrations publiées, tout en gardant titres, légendes et boutons sous
  forme de Controls Godot localisables ;
- relié la flèche magenta au focus clavier/manette réel au lieu d'en faire une
  décoration fixe ; le menu reste un émetteur d'intentions et ne route aucun
  écran lui-même ;
- enrichi `game_ui_theme.tres` avec des variations sémantiques pour titres,
  légendes, HUD, objectifs, notifications, boutons compacts et commandes
  tactiles, avec contours lisibles sur les illustrations chargées ;
- remplacé l'aplat noir du chargement en mission par la turbine publiée, une
  ombre, une plaque et un message centré ; `MissionHUDTheme` choisit cette
  présentation sans devenir autorité du message ou du chargement ;
- conservé carte, marqueurs, cadenas et lampes comme vocabulaire préparé : leur
  runtime attend un vrai Mission Catalog et une autorité de progression ;
- ajouté le contrat auteur Boot/Start et
  `boot_start_flow_contract_test.gd`, couvrant les dix-neuf sorties, les rôles
  sémantiques, le focus, la typographie et le loading composé.
- validation finale : profil `structure` 33/33, profil `content` 1/1,
  pipeline Boot/Start 19/19 et `git diff --check` propre.

### Revue artistique corrective sur captures réelles

- capturé le Start Flow, le HUD joué et le loading avec le renderer OpenGL réel
  en 1280 × 720 ; la première version contractuellement valide restait
  visuellement refusée ;
- constaté puis corrigé le cadre vertical déformé, le sous-titre débordant, les
  boutons gris génériques, le fond trop lumineux sous le menu et la colonne qui
  se décalait lorsque l'indicateur de focus passait en `visible = false` ;
- ajouté une ombre latérale progressive, un verre sombre dans l'ouverture, une
  variation `StartMenuButton` sans boîte opaque et deux SystemFont condensées
  avec fallbacks ;
- recalibré les textes du panneau d'arme et rendu le `MissionHUD` autonome en
  lui assignant explicitement `game_ui_theme.tres` ;
- recomposé le loading en signalétique à deux niveaux : `DÉPLOIEMENT` lime et
  `EN COURS` crème, tous deux contenus dans la fenêtre centrale du cadre ;
- renforcé le contrat auteur et le test afin de protéger ratio 2:3, colonne
  stable, variation dédiée, hiérarchie du loading et Theme explicite du HUD.

## 2026-08-31 — Famille d'explosions de barils v001

- généré puis normalisé trois atlas ImageGen 4 × 2 pour les explosions petite,
  standard et lourde, avec huit phases, alpha réel et ancrage commun ;
- créé `process_barrel_explosion_family.py`, la recette, la provenance, le
  manifeste et la QA du lot `barrel-explosion-family-v001` ;
- étendu `ExplosionData` avec identité, famille, animation et intensités VFX,
  sans déplacer l'autorité gameplay vers la scène ou le consommateur ;
- créé trois profils `.tres` monotones et branché le baril toxique courant sur
  le profil standard au lieu du profil `field_shell` ;
- recomposé `Explosion2D` autour d'un `AnimatedSprite2D`, de deux ondes, d'une
  lumière et de trois couches de particules, tout en conservant le fallback
  procédural pour les familles sans atlas ;
- interdit par contrat et test toute caméra interne ou secousse globale : la
  richesse VFX ne doit pas déplacer l'écran ;
- ajouté `barrel_explosion_family_contract_test.gd`, couvrant validité, huit
  frames, progression des puissances, branchement du baril et SceneTree VFX ;
- limite volontaire : aucun faux petit/gros baril n'est créé sans prop publié ;
  les deux profils attendent leurs futurs consommateurs réels ;
- validation finale : profil `structure` 34/34, profil `content` 1/1, atlas
  reproductibles bit à bit et `git diff --check` propre.

## 2026-08-31 — Arsenal joueur Resource-first v001

- créé `PlayerLoadoutProfile` comme autorité de l'arsenal autorisé, de l'arme
  primaire et de l'arme de départ ;
- créé `standard_loadout.tres` avec le canon de campagne et les quatre armes
  spéciales déjà publiées, sans recopier les `WeaponData` ou leurs
  `ProjectileData` ;
- ajouté `PlayerLoadoutComponent` sous `Player/Components/Loadout`, propriétaire
  de l'arme équipée runtime et du refus des armes hors profil ;
- branché `PlayerWeaponComponent` sur le Loadout : il consomme l'arme équipée
  pour cadence, munitions, feedback et demande de projectile, mais ne devient
  pas catalogue d'armes ;
- branché les armureries sur `PlayerLoadoutComponent.equip_weapon()`, avec
  fallback vers l'ancien composant de tir uniquement pour compatibilité locale ;
- corrigé le baril toxique revenu par UID/cache sur l'explosion lourde : il
  choisit de nouveau `barrel_standard_explosion.tres`, et le test compare
  maintenant l'identité stable `explosion_id`/`family_id` ;
- renforcé `player_contract_test.gd` et
  `industrial_toxic_expansion_contract_test.gd` pour protéger la présence du
  Loadout, les cinq armes du profil standard et le refus d'une arme non listée ;
- mis à jour les contrats joueur, armes/projectiles, pickups/stations, HUD et
  glossaire ;
- validation finale : `player_contract_test.gd`,
  `weapon_projectile_integration_test.gd`,
  `industrial_toxic_expansion_contract_test.gd`,
  `barrel_explosion_family_contract_test.gd` et profil `structure` 34/34 PASS ;
- limite volontaire : pas de slots multiples, pas de pools de munitions par
  famille et pas d'affichage HUD supplémentaire avant un gameplay réel de
  sélection d'armes.

## 2026-08-31 — Cadrage Player Kit avant nouvelles armes

- clarifié le vocabulaire de conception : Player Kit, Player Controller,
  Player Feel, HUD Layout et Arsenal ;
- créé `docs/characters/RUN_AND_GUN_PLAYER_KIT.md` pour inventorier ce que le
  joueur peut déjà faire et décider ce qui est gardé, reporté ou à mesurer ;
- acté que courir, sauter, viser horizontal/vertical/diagonal, viser au
  pointeur PC, tirer, tenir le tir, équiper via armurerie, interagir, ramasser,
  subir dégâts, i-frames, mort et respawn forment le kit v001 ;
- reporté crouch, drop-through, dash/slide, aim lock, melee, grenade, attaque
  spéciale séparée, swap multi-slot, drop et rescue tant que Côte toxique ne
  démontre pas leur besoin ;
- conservé les cinq armes publiées comme base v001 à différencier par
  équilibrage avant de créer un nouveau rôle d'arme ;
- prochaine action recommandée : créer une famille d'explosions de munitions
  pour le lanceur de démolition, puis playtester les coûts et cadences des cinq
  armes.

## 2026-08-31 — IDs d'objets explosifs distincts des explosions

- clarifié le problème auteur : `barrel_heavy` était un profil d'explosion, pas
  l'identité de l'objet qui explose ;
- créé trois `ExplosivePropData` génériques sous `props/explosive/data/` avec
  `prop_id` distinct : petit contenant, baril standard et gros contenant ;
- conservé la scène canonique existante `ExplosiveProp2D` sans migration de
  scripts pour limiter le risque ;
- assigné explicitement `toxic_standard_explosive_barrel` au baril du Pont et
  `toxic_heavy_explosive_barrel` au baril de Fonderie dans la scène maîtresse ;
- ajouté `AuthorPreview` dans la scène canonique pour afficher dans l'éditeur
  le `prop_id` de l'objet et le `explosion_id` réellement déclenché ;
- adapté `ExplosionData.is_valid()` : `terrain_radius` et `damage_radius` sont
  indépendants, car une grosse explosion peut creuser plus large qu'elle ne
  blesse ;
- renforcé `barrel_explosion_family_contract_test.gd` et `map_contract_test.gd`
  pour protéger la séparation `prop_id` / `explosion_id` et les deux
  occurrences de Côte toxique ;
- validation ciblée PASS :
  `barrel_explosion_family_contract_test.gd` et `map_contract_test.gd`.

## 2026-08-31 — Assets manquants du canon de campagne et arsenal lisible

- publié les deux candidates techniques du lot `projectile-impact-lot-v001`
  vers `art/` après accord auteur : projectile `field-round-v001.png` et impact
  `field-round-impact-3x2-v001.png` ;
- créé `effects/weapons/field/field_round_impact_frames.tres` et
  `FieldRoundImpact2D` sur la scène canonique `AnimatedProjectileImpact2D` ;
- branché `field_round.tres` sur le bitmap de munition et son impact animé,
  sans changer son rôle de projectile direct qui creuse un petit cratère ;
- créé `demolition_rocket_explosion.tres` pour que la roquette de démolition
  possède son propre `ExplosionData` de munition au lieu de réutiliser
  l'ancien profil d'obus de campagne ;
- ajouté `AuthorPreview` aux projectiles et armureries afin de voir depuis
  l'éditeur les identifiants réellement branchés : projectile, impact,
  explosion éventuelle, station et arme accordée ;
- mis à jour le manifeste `art/`, le manifeste pipeline, la provenance, le
  contrat armes/projectiles et la mémoire projet ;
- validation ciblée PASS :
  `validate_projectile_impact_candidates.py`,
  `weapon_projectile_integration_test.gd` et
  `industrial_toxic_expansion_contract_test.gd`.

## 2026-08-31 — Roue d'armes de test v001

- ajouté `WeaponWheelOverlay` au HUD de mission pour sélectionner rapidement
  une arme parmi celles autorisées par `PlayerLoadoutComponent` ;
- ajouté l'action `player_weapon_wheel`, maintenue avec `Tab` au clavier ou
  l'épaule gauche de manette ;
- la roue se sélectionne au pointeur ou au stick droit et équipe au
  relâchement via `PlayerLoadoutComponent.equip_weapon()`, sans posséder de
  liste d'armes ni d'inventaire parallèle ;
- elle affiche le coût de munition par segment et recharge la réserve spéciale
  partagée lorsqu'une arme consommatrice est choisie, pour permettre le test
  immédiat de chaque projectile ;
- renforcé `mission_hud_contract_test.gd` et `player_input_contract_test.gd`
  pour protéger le Node HUD, l'action Input Map et l'équipement par la roue.

## 2026-09-01 — Impact du canon de campagne réduit

- réduit l'échelle de `FieldRoundImpact2D/Visuals` à 0,42 pour que le canon de
  base lise comme un impact compact plutôt qu'une explosion lourde ;
- conservé le PNG publié et la `ProjectileData` inchangés : seul l'assemblage
  de présentation Godot règle la sensation visuelle ;
- renforcé `weapon_projectile_integration_test.gd` pour empêcher l'impact du
  canon de base de redevenir trop grand.

## 2026-09-01 — Mission 2 blockout abyssal et Ground Kit v001

- repris le pack externe `jeuweb-abyssal-asset-pack-v001` comme source
  conceptuelle read-only, branche `agent/ajoute-serre-mecanique`, commit
  `e2b81a5` ;
- copié les sources terrain retenues dans
  `pipeline/assets/sources/terrain_kits/abyssal/`, puis publié quatre PNG
  runtime sous `art/terrain/pieces/abyssal/` via
  `process_abyssal_ground_kit.py` ;
- créé le catalogue `terrain/kits/abyssal/abyssal_ground_kit.tres`, quatre
  `GroundPieceDefinition`, quatre scènes glissables et un profil Breakable pour
  le mur nacré ;
- transformé `maps/missions/mission2/mission_2.tscn` en scène maître
  `MissionMapRoot2D` conforme, avec un acte de 2560 × 720, un spawn joueur, les
  branches auteur/runtime obligatoires et cinq occurrences de Ground Pieces ;
- créé `maps/definitions/mission_2.tres` et ajouté `mission_2_abyssal` au
  catalogue de missions ;
- ajouté `abyssal_ground_kit_contract_test.gd` et étendu
  `project_state_catalog_contract_test.gd` pour protéger le nouveau kit et la
  projection de catalogue ;
- limite volontaire : aucun ennemi, checkpoint, background final ou boucle de
  victoire Mission 2 n'est inventé dans cette tranche ; le but est seulement de
  tester le sol et les raccords dans l'éditeur.

## 2026-09-01 — DA Mission 2 abyssale et vocabulaire de structures

- généré et publié `art/concepts/da-08-abyssal-mission.png` comme nouvelle
  planche de direction artistique pour Mission 2 ;
- conservé la source ImageGen sous
  `pipeline/assets/sources/imagegen/concepts/abyssal_mission_v001/` et ajouté
  recette/provenance dédiées ;
- ajouté DA-08 au `GalleryCatalog`, qui passe de sept à huit planches ;
- créé `docs/assets/MISSION_2_ABYSSAL_ART_DIRECTION_AND_STRUCTURE_KIT.md` pour
  fixer les règles visuelles abyssales et une liste de pièces terrain de
  structure à produire par lots ;
- corrigé le blockout Mission 2 : le fond `Visual` reste masqué si l'auteur a
  décoché l'œil, et ses aplats sont désormais derrière le gameplay avec une
  opacité réduite s'ils sont rallumés ;
- limite volontaire : les nombreuses pièces listées ne sont pas encore toutes
  publiées en sprites runtime ; le prochain lot doit produire les modules
  prioritaires avant de densifier les props et hazards.

## 2026-09-01 — Mission 2 level design blockout et Ground Kit abyssal v002

- étendu `process_abyssal_ground_kit.py` pour publier un lot v002 de seize
  sorties supplémentaires sans écraser les quatre pièces v001 ;
- ajouté la source locale `abyssal-temple-arch-source-v001.png` dans le
  pipeline, puis dérivé plateformes, caps, pentes, marches, ponts, support,
  arche, colonnes et murs nacrés ;
- créé seize `GroundPieceDefinition` v002, seize scènes glissables sous
  `terrain/kits/abyssal/pieces/v002/` et un profil Breakable lourd pour le
  grand mur nacré ;
- étendu `abyssal_ground_kit.tres` à vingt scènes, toutes résolues par
  `piece_id` stable ;
- agrandi Mission 2 à 5120 × 720 avec deux segments auteur :
  `abyssal_entry` et `tide_engine_ruins` ;
- placé dix-sept occurrences de Ground Pieces dans `mission_2.tscn`, dont
  pont long, supports, arche traversable, colonnes et grand mur destructible ;
- renforcé `abyssal_ground_kit_contract_test.gd` pour protéger le catalogue
  de 20 pièces, les deux segments et les 17 occurrences de blockout ;
- limite volontaire : le parcours est un blockout game art/level design, pas
  encore une mission jouable complète avec ennemis, checkpoints, hazards et
  scoring.

## 2026-09-01 — Grands socles générés et apprentissage de production

- intégré le retour auteur : les grands sols en bas de DA-08 doivent porter la
  base de Mission 2, mais ne doivent pas être extraits tels quels si la DA crée
  plusieurs hauteurs de sol visibles ;
- consulté des workflows externes de Tilemap/TileSet et de kits modulaires :
  palette de pièces éditables, pivots stables, modules cohérents et absence de
  reconstruction du level design pendant l'art pass ;
- refusé la v003 extraite de DA-08 : pseudo-rendu, double lecture de hauteur et
  mauvaise adaptation en sprite gameplay ;
- ajouté `process_abyssal_generated_large_structures.py` pour publier cinq
  grands socles générés, avec alpha, canevas 1024 × 320 et QA ;
- publié cinq PNG sous
  `art/terrain/pieces/abyssal/v004_large_structures/`, leurs
  `GroundPieceDefinition` et scènes glissables ;
- étendu `abyssal_ground_kit.tres` à vingt-cinq pièces et Mission 2 à vingt-deux
  occurrences de blockout ;
- renforcé le contrat abyssal pour protéger le nombre de pièces, les grands
  socles générés et la scène deux actes.
