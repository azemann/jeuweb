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
