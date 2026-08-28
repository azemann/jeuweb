# Glossaire des classes et du vocabulaire du projet

Ce document est l'autorité des noms architecturaux employés dans le projet.
Il doit permettre de comprendre le rôle d'une classe, d'une scène ou d'une
Resource sans interpréter librement son suffixe.

Le catalogue correspond à l'état du projet au 28 août 2026. Toute nouvelle
`class_name` doit être ajoutée ici dans le même changement.

## Règle de lecture d'un nom

Un nom suit généralement cette formule :

```text
Domaine + responsabilité + forme Godot

Enemy + Health + Component
Mission + Map + Definition
Projectile + Data
```

Les classes utilisent `PascalCase`, les fichiers et dossiers `snake_case`, et
les identifiants de contenu stables `snake_case` dans un `StringName`.

## Suffixes architecturaux

| Suffixe | Signification obligatoire | Contient | Ne doit pas devenir |
|---|---|---|---|
| `Data` | Définition éditable d'un contenu | paramètres, références d'assets et scènes | état mutable d'une occurrence |
| `Profile` | Panneau cohérent de réglages partagé | valeurs de tuning d'un comportement | catalogue de contenus différents |
| `Definition` | Identité complète d'un contenu auteur | identifiant, présentation, politique, références | instance runtime |
| `Catalog` | Ensemble éditable de définitions ou correspondances | liste et résolution par identifiant | propriétaire du gameplay runtime |
| `Binding` | Une correspondance explicite entre deux vocabulaires | identifiant source et cible Godot | logique générale ou recherche implicite |
| `Component` | Responsabilité runtime spécialisée attachée à une scène | état local et comportement ciblé | personnage complet ou singleton global |
| `Character2D` | Racine physique canonique d'un acteur | composition et API publique de l'acteur | toutes les règles de ses composants |
| `Spawner2D` | Traducteur entre demande/marker et `PackedScene` | instanciation et placement | définition de l'objet instancié |
| `Marker2D` | Intention auteur positionnée dans une map | identifiant, rôle et paramètres de placement | ennemi ou interaction runtime |
| `Host2D` | Propriétaire d'un contenu remplaçable | chargement, déchargement et référence courante | service global |
| `Root2D` | Racine contractuelle d'une scène maîtresse | branches, accès et validation structurelle | gros script de gameplay |
| `Rig2D` | Assemblage technique suivant une cible | caméra, pivots ou contraintes | donnée éditable |
| `Flow` | Orchestration d'une succession d'écrans ou d'états | transitions et signaux de navigation | gameplay d'une mission |
| `Style` | Données purement visuelles partagées | textures, couleurs, dimensions visuelles | collision ou état runtime |
| `Config` | Configuration d'application ou de système | références et réglages de démarrage | contenu gameplay instanciable |

`Data`, `Profile` et `Definition` sont proches mais pas interchangeables :

- `Data` décrit une chose consommée directement, comme un projectile ;
- `Profile` règle une famille de comportements, comme la locomotion ;
- `Definition` donne une identité auteur complète, comme une mission ou une
  pièce de terrain.

## Vocabulaire architectural

| Terme | Définition dans ce projet |
|---|---|
| Autorité | Unique endroit où une information est créée ou modifiée légitimement. |
| Asset source | Fichier de création conservé dans `pipeline/`, jamais chargé par Godot. |
| Asset généré | Résultat reproductible du pipeline, destiné à être remplacé lors d'une nouvelle exécution. |
| Asset publié | Livrable runtime validé sous `art/`, importable par Godot. |
| Authoring | Travail effectué dans l'éditeur par placement, composition et réglage Inspector. |
| Runtime | État créé pendant une partie et non utilisé comme définition de contenu. |
| Scène canonique | `PackedScene` unique servant de structure commune à une famille d'objets. |
| Scène maîtresse | Scène auteur qui assemble une mission complète sans être générée. |
| Présentation | Sprites, animations, sons et VFX ; elle traduit l'état sans en être l'autorité. |
| Correspondance | Traduction explicite d'un identifiant ou outil vers une classe, scène ou Resource Godot. |
| Composition | Construction d'un objet avec des scènes et composants spécialisés. |
| Dépendance injectée | Référence fournie par le parent, l'Inspector ou un spawner plutôt que recherchée globalement. |
| Commande | Appel direct exprimant une intention : tirer, subir des dégâts, charger une map. |
| Événement | Fait déjà arrivé, communiqué par un signal : `died`, `map_loaded`, `terrain_carved`. |
| Contrat auteur | Règles que le designer respecte pour créer correctement du contenu. |
| Contrat runtime | Garanties entre objets pendant l'exécution. |
| Contrat de validation | Test ou avertissement qui protège automatiquement les deux contrats précédents. |
| État runtime | Valeur mutable propre à une occurrence : PV actuels, direction ou cooldown restant. |
| Identifiant stable | `StringName` indépendant du chemin, du nom visible et de la langue. |
| Aperçu éditeur | Représentation visible pour l'auteur mais systématiquement masquée en jeu. |
| Transformation auteur | Position, rotation, échelle et orientation choisies dans la scène maîtresse. |

## Vocabulaire terrain

| Terme | Sens exact |
|---|---|
| `Permanent` | Pièce possédant une collision locale qui ne peut pas être détruite. |
| `Carvable` | Matière fusionnée au masque global et creusée localement façon *Worms*. |
| `Breakable` | Objet discret avec des PV, des états visuels et une rupture complète. |
| Ground Piece | Scène glissable dont PNG, pivot et géométrie viennent d'une `GroundPieceDefinition`. |
| Ground Module | Volume permanent dont `outline` est l'autorité commune du dessin et de la collision. |
| Authored Zone | Forme simple placée dans la map et consommée pour construire le masque destructible. |
| Chunk | Portion du terrain Carvable dont le visuel et la collision sont reconstruits après impact. |
| Surface Path | Ligne purement visuelle qui indique le bord marchable d'un Ground Module. |
| Ground Anchor | Point canonique entre les appuis d'un acteur. |
| Ground Probe | `RayCast2D` cherchant le véritable sol physique sous l'acteur. |

## Vocabulaire combat

| Terme | Sens exact |
|---|---|
| Muzzle | `Marker2D` situé à la sortie extérieure du canon. |
| Clearance Origin | Point interne du canon depuis lequel vérifier qu'un mur n'a pas été traversé. |
| Projectile | Occurrence physique en vol consommant une `ProjectileData`. |
| Impact | Présentation créée au contact ; les dégâts restent décidés par le projectile ou l'explosion. |
| Hurtbox | Zone indiquant où un acteur peut recevoir un impact. |
| Hitbox | Zone active qui applique ou propose une attaque. |
| Invulnérabilité post-impact | Fenêtre empêchant plusieurs dégâts involontaires issus du même événement. |
| Archétype ennemi | Identifiant de contenu résolu par `EnemyCatalog` vers une scène canonique. |
| Encounter Marker | Intention de rencontre placée dans la map, pas un ennemi déjà instancié. |
| Enemy cadence | Moment, position et rythme auxquels une rencontre injecte ses ennemis. |
| Enemy archetype | Famille comportementale d'ennemi résolue par `EnemyCatalog`. |
| Grunt | Ennemi terrestre basique qui établit la pression de référence. |
| Elite | Variante plus dangereuse d'un archétype ; vocabulaire réservé, non publiée actuellement. |
| Turret | Ennemi fixe ; vocabulaire réservé, non publié actuellement. |
| Spawner enemy | Ennemi capable de produire d'autres ennemis ; distinct de `MissionEnemySpawner2D`. |
| Flying enemy | Archétype aérien dont le profil choisit la locomotion volante. |
| Mini-boss / Mid-boss | Boss intermédiaire servant d'escalade avant le climax. |
| Boss phase | Phase comportementale d'un Boss ; future Resource, absente du runtime actuel. |
| Spawn Pattern | Motif géométrique et temporel d'apparition d'un même archétype. |
| Wave | Ensemble ordonné de Spawn Patterns associé à un beat de combat. |
| Encounter | Séquence auteur de vagues déclenchée à un point de progression. |
| Combat rhythm | Alternance intentionnelle `pressure → release → escalation → payoff`. |
| Pressure | Beat qui augmente la charge active imposée au joueur. |
| Release | Beat court de respiration et de récupération relative. |
| Escalation | Beat qui combine ou intensifie les menaces déjà apprises. |
| Payoff | Résolution spectaculaire ou défi culminant préparé par la cadence. |
| Combat gate | Rencontre dont l'achèvement conditionne la progression ou la sortie. |
| Kill room | Arène fermée jusqu'à élimination ; type décrit par `EncounterData`, verrou spatial futur. |
| Gauntlet | Succession intensive de vagues pouvant se chevaucher dans le temps. |
| Set piece | Séquence spécialement mise en scène ; type décrit, orchestration audiovisuelle future. |
| Scrolling section | Portion de carte dont la caméra participe à la contrainte de progression. |
| Auto-scroll | Défilement autonome de caméra ; non implémenté actuellement. |
| Forced scroll | Défilement que le joueur doit suivre ; non implémenté actuellement. |
| Vertical scrolling | Progression dont l'axe principal devient vertical ; non implémentée actuellement. |
| Arena section | Segment temporairement traité comme arène ; verrou spatial futur. |
| Moving platform | Plateforme mobile ; famille gameplay non publiée actuellement. |
| Breakable wall | Mur discret destructible, spécialisé depuis le contrat `Breakable`. |
| Secret route | Passage alternatif caché ; intention de niveau non publiée actuellement. |

## Catalogue des classes

### Application et écrans

| Classe | Forme | Responsabilité |
|---|---|---|
| `AppFlowConfig` | Resource | Associe les écrans Boot, Start, Gallery et Mission et règle les fondus. |
| `AppFlow` | Control | Orchestre le flux principal et remplace le contenu de `ScreenHost`. |
| `BootFlow` | Control | Joue l'introduction puis signale que le menu peut apparaître. |
| `StartFlow` | Control | Expose les commandes du menu principal par signaux. |
| `PrototypeMissionScreen` | Control | Assemble temporairement mission, HUD et retour au menu. |
| `ArtDirectionGallery` | Control | Affiche et fait parcourir les planches du catalogue artistique. |
| `GalleryCatalog` | Resource | Ordonne les entrées disponibles dans la galerie. |
| `GalleryEntry` | Resource | Décrit une planche, sa catégorie et sa texture publiée. |

### Maps, progression et caméra

| Classe | Forme | Responsabilité |
|---|---|---|
| `MissionMapDefinition` | Resource | Identité, scène maîtresse, dimensions et politique de destruction d'une mission. |
| `MissionMapCatalog` | Resource | Résout une mission stable par son `map_id`. |
| `MissionMapHost2D` | Node2D | Charge, expose et décharge la scène de map courante. |
| `MissionMapRoot2D` | Node2D | Rend visibles les branches contractuelles d'une scène maîtresse et les valide. |
| `MapSegment2D` | Node2D | Décrit un morceau ordonné du rythme et de l'espace de la mission. |
| `MapSpawnPoint2D` | Marker2D | Positionne un départ, checkpoint ou point d'entrée identifié. |
| `MapEncounterMarker2D` | Marker2D | Place une demande auteur d'ennemis dans la progression. |
| `EnemySpawnPatternData` | Resource | Décrit archétype, formation, offsets et intervalle d'apparition d'un motif. |
| `WaveData` | Resource | Ordonne les motifs d'une vague et porte son beat et sa condition d'avancement. |
| `EncounterData` | Resource | Compose les vagues, leur intention et leur effet sur la sortie de mission. |
| `MissionEncounterController` | Node | Déclenche les marqueurs et exécute leur cadence Resource au runtime. |
| `MissionCombatGate2D` | Node2D | Bloque physiquement un passage puis l'ouvre à la fin de sa rencontre. |
| `MissionActorSpawner2D` | Node | Instancie le joueur au spawn demandé dans la map chargée. |
| `MissionEnemySpawner2D` | Node | Traduit les Encounter Markers via l'Enemy Catalog et instancie les ennemis. |
| `MissionCheckpoint2D` | Area2D | Traduit le passage du joueur en changement de spawn de reprise. |
| `MissionRunController` | Node | Suit les rencontres obligatoires et autorise la victoire à la sortie auteur. |
| `RunAndGunCameraProfile` | Resource | Règle anticipation, verrou horizontal, cadrage vertical et lissage. |
| `MissionCameraRig2D` | Camera2D | Suit le joueur et respecte la progression ainsi que les limites de la map. |

### Joueur et acteurs partagés

| Classe | Forme | Responsabilité |
|---|---|---|
| `PlayerCharacter2D` | CharacterBody2D | Racine physique et API publique de la scène joueur canonique. |
| `PlayerMovementProfile` | Resource | Valeurs de course, accélération, saut, gravité et tolérances. |
| `PlayerAimProfile` | Resource | Directions autorisées et quantification de la visée arcade. |
| `PlayerHealthProfile` | Resource | PV maximum et invulnérabilité du joueur. |
| `PlayerMovementComponent` | Node | Possède la vélocité et exécute la locomotion du joueur. |
| `PlayerAimComponent` | Node | Produit la direction de visée et oriente sa présentation. |
| `PlayerHealthComponent` | Node | Possède les PV runtime et émet dégâts, changements et mort. |
| `PlayerWeaponComponent` | Node | Cadence les tirs et émet une demande de projectile découplée. |
| `PlayerPresentationComponent` | Node | Traduit le mouvement en animation et orientation visuelle. |
| `ActorGroundingComponent` | Node2D | Expose le root des pieds et projette une ombre sur le vrai sol. |
| `ActorSlopePresentationComponent` | Node | Incline uniquement la présentation selon la pente mesurée sous les appuis. |
| `ActorStateMachineComponent` | Node | Possède l'état commun et valide les transitions runtime d'un acteur. |

### Ennemis

| Classe | Forme | Responsabilité |
|---|---|---|
| `EnemyArchetypeProfile` | Resource | Règle PV, invulnérabilité, gravité et patrouille d'un archétype. |
| `EnemySceneBinding` | Resource | Relie un `archetype_id` à sa scène canonique. |
| `EnemyCatalog` | Resource | Regroupe les bindings et résout les scènes ennemies. |
| `EnemyCharacter2D` | CharacterBody2D | Racine physique composée et API de dégâts d'un ennemi. |
| `EnemyPatrolComponent` | Node | Possède direction, vélocité et bornes de patrouille. |
| `EnemyHealthComponent` | Node | Possède les PV runtime et la fenêtre d'invulnérabilité. |
| `EnemyAttackComponent` | Node | Détecte la cible, orchestre l'attaque et demande son projectile. |
| `EnemyEjectionComponent` | Node | Traduit la mort d'une coque en apparition différée de son pilote autonome. |
| `EnemyPresentationComponent` | Node | Joue la marche et retourne le sprite selon la direction. |

### Armes, projectiles et effets

| Classe | Forme | Responsabilité |
|---|---|---|
| `WeaponData` | Resource | Décrit projectile, cadence, automatisme et animation de tir d'une arme. |
| `ProjectileData` | Resource | Décrit vol, dégâts, terrain, impact et présentation d'une munition. |
| `Projectile2D` | Area2D | Déplace une occurrence, résout le premier obstacle et applique l'impact. |
| `ProjectileImpact2D` | Node2D | Joue puis libère la présentation d'impact. |
| `ToxicPressureImpact2D` | Node2D | Joue puis libère l'impact animé propre au projectile toxique. |
| `MissionProjectileSpawner2D` | Node | Place les projectiles dans la branche runtime de la mission. |
| `ExplosionData` | Resource | Décrit rayons, dégâts, impulsion, durée et palette d'une explosion. |
| `Explosion2D` | Node2D | Orchestre l'impact avec `AnimationPlayer` et signale les cibles. |

### Terrain

| Classe | Forme | Responsabilité |
|---|---|---|
| `DestructibleTerrainProfile` | Resource | Règle canevas, chunks, textures, couleurs et simplification physique. |
| `DestructibleTerrain2D` | Node2D | Autorité runtime du masque Carvable, de son rendu et de ses collisions. |
| `GroundPieceDefinition` | Resource | Identité, PNG, pivot, géométrie et capacités d'une pièce glissable. |
| `GroundPiece2D` | Node2D | Scène canonique choisissant Permanent, Carvable ou Breakable par instance. |
| `GroundBreakableProfile` | Resource | Règle PV, seuil visuel et politique de disparition d'une pièce Breakable. |
| `GroundBreakableComponent` | Node | Possède l'état runtime et la rupture d'une pièce Breakable. |
| `GroundKitCatalog` | Resource | Présente les scènes de pièces disponibles pour un biome. |
| `PermanentGroundStyle` | Resource | Panneau partagé de textures et couleurs d'un sol permanent. |
| `GroundModule2D` | Node2D | Construit dessin et collision depuis un contour auteur unique. |
| `HazardData` | Resource | Décrit l'apparence, la zone, les dégâts et le rythme d'un danger de terrain. |
| `DamageHazard2D` | Node2D | Applique périodiquement les dégâts d'une HazardData aux acteurs présents. |

### Objets interactifs

| Classe | Forme | Responsabilité |
|---|---|---|
| `ExplosivePropData` | Resource | Décrit l'apparence, les PV, la collision et l'explosion d'un objet explosif. |
| `ExplosiveProp2D` | StaticBody2D | Reçoit les tirs puis instancie et configure l'explosion canonique. |
| `SupplyCrateData` | Resource | Décrit les visuels fermé/ouvert et les modes d'ouverture d'une caisse. |
| `SupplyCrate2D` | StaticBody2D | Ouvre une caisse par tir ou interaction et émet l'événement `opened`. |

### Interface et périphériques

| Classe | Forme | Responsabilité |
|---|---|---|
| `MobileControls` | Control | Place les boutons tactiles et reflète leur état visuel. |

## Comment choisir un nouveau nom

Avant d'ajouter une classe :

1. vérifier qu'un Node ou une Resource Godot ne porte pas déjà ce rôle ;
2. choisir le domaine propriétaire ;
3. choisir un seul suffixe dans le tableau ;
4. vérifier qu'aucune classe existante n'a déjà cette autorité ;
5. créer la scène ou la Resource éditable avant d'étendre le code ;
6. ajouter la classe à ce glossaire et à son contrat de validation.
