# Fondation editor-first du run-and-gun — Spécification

Date : 2026-08-25  
Moteur cible : Godot 4.7.1  
Portée : première tranche visible et navigable dans l’éditeur, sans gameplay de combat définitif

> Statut historique : cette spécification décrit la fondation du 25 août 2026.
> La scène autonome `levels/prototype/prototype_mission.tscn` qu'elle proposait
> a depuis été retirée. L'écran actif `PrototypeMissionScreen` consomme désormais
> une `MissionMapDefinition` et la scène maîtresse canonique Côte toxique via
> `MissionMapHost2D`. Les mentions de `PrototypeMission.tscn` ci-dessous sont
> conservées uniquement comme trace de la conception initiale.

## Résultat attendu

Créer un projet Godot ouvrable directement depuis `project.godot`. Son lancement présente un court Boot Flow, puis un Start Flow donnant accès à une galerie des sept planches de direction artistique et à une mission prototype mise en scène. Cette tranche rend le projet compréhensible depuis le `SceneTree` et prépare les futurs systèmes sans les simuler prématurément.

Le jeu n’a pas encore de titre définitif. Le Start Flow utilise donc un emblème original sans mot-symbole, accompagné d’intitulés fonctionnels en français. Aucun nom provisoire ne doit contaminer les Resources ou les scènes.

## Principes et autorités

| Information | Autorité | Dérivés / consommateurs |
|---|---|---|
| ordre et métadonnées des planches | `GalleryCatalog.tres` | galerie runtime |
| images de concept | PNG sous `art/concepts/` | `Texture2D` importées par Godot |
| navigation applicative locale | `Main.tscn` + `AppFlowConfig.tres` | écrans instanciés |
| composition de chaque écran | scène `.tscn` | script local minimal |
| apparence UI commune | `GameUITheme.tres` | scènes `Control` |
| transitions temporelles | `AnimationPlayer` de `Main.tscn` et des écrans | propriétés visuelles |
| composition de la mission | `PrototypeMission.tscn` | marqueurs et aperçus runtime |

Il n’y a aucun Autoload dans cette tranche. Le flux d’application appartient à la scène racine tant qu’il ne s’agit que d’une navigation locale entre quatre écrans.

## Arborescence du projet

```text
res://
├── project.godot
├── art/
│   └── concepts/                       # planches existantes, références et non sprites runtime
├── app/
│   ├── main.tscn
│   ├── main.gd
│   ├── app_flow_config.gd
│   └── app_flow_config.tres
├── screens/
│   ├── boot/
│   │   ├── boot_flow.tscn
│   │   └── boot_flow.gd
│   ├── start/
│   │   ├── start_flow.tscn
│   │   └── start_flow.gd
│   ├── gallery/
│   │   ├── art_direction_gallery.tscn
│   │   ├── art_direction_gallery.gd
│   │   ├── gallery_catalog.gd
│   │   ├── gallery_entry.gd
│   │   └── gallery_catalog.tres
│   └── prototype/
│       ├── prototype_mission_screen.tscn
│       └── prototype_mission_screen.gd
├── levels/
│   └── prototype/
│       └── prototype_mission.tscn
├── ui/
│   └── themes/
│       └── game_ui_theme.tres
└── tests/
    └── foundation_smoke_test.gd
```

Les domaines restent séparés : `screens/` décrit les interfaces applicatives, tandis que `levels/` contient le monde 2D. La galerie ne devient pas une dépendance du gameplay.

## Flux applicatif

```text
Main
  └─ BootFlow
       └─ terminé ou ignoré
            ↓
         StartFlow
          ├─ Mission prototype ──→ PrototypeMissionScreen
          ├─ Galerie DA ─────────→ ArtDirectionGallery
          └─ Quitter

ArtDirectionGallery ── retour ──→ StartFlow
PrototypeMissionScreen ─ retour → StartFlow
```

`Main.gd` reçoit des signaux d’intention (`completed`, `open_gallery_requested`, `open_mission_requested`, `back_requested`, `quit_requested`) et remplace uniquement l’enfant du conteneur `ScreenHost`. Les écrans ne connaissent jamais le chemin ou le type concret de l’écran suivant.

`AppFlowConfig` est une Resource exposant les quatre `PackedScene`. `Main.gd` contient uniquement l’orchestration d’instanciation, la connexion des signaux et le déclenchement des animations de fondu. Les scripts locaux de Boot, Start, Galerie et Mission traduisent les interactions de leurs Nodes en signaux d’intention, sans choisir l’écran suivant.

## Scènes et Nodes

### `Main.tscn`

```text
Main (Control)
├── Background (ColorRect)
├── ScreenHost (Control)
├── TransitionLayer (CanvasLayer)
│   └── Fade (ColorRect)
└── AnimationPlayer
```

`AnimationPlayer` possède les animations `fade_in` et `fade_out`. Le changement d’écran intervient entre les deux animations. Le fondu ne doit pas être interpolé manuellement dans `_process`.

### `BootFlow.tscn`

```text
BootFlow (Control)
├── Backdrop (TextureRect)
├── Shade (ColorRect)
├── Center (CenterContainer)
│   └── EmblemPanel (PanelContainer)
│       └── EmblemGlyph (Label)
├── ContinueHint (Label)
├── AutoContinueTimer (Timer)
└── AnimationPlayer
```

Le Boot Flow dure au maximum 2,5 secondes, peut être ignoré avec les actions `ui_accept` ou `ui_cancel`, et émet `completed` une seule fois. `AnimationPlayer` orchestre l’apparition de l’emblème et le signal final ; `Timer` constitue le garde-fou de durée. L’emblème initial est une composition typographique et géométrique native au Theme, sans nouveau bitmap ni nom provisoire.

### `StartFlow.tscn`

```text
StartFlow (Control)
├── Backdrop (TextureRect)
├── Overlay (ColorRect)
├── SafeArea (MarginContainer)
│   └── Layout (VBoxContainer)
│       ├── EmblemPanel (PanelContainer)
│       ├── MissionButton (Button)
│       ├── GalleryButton (Button)
│       └── QuitButton (Button)
└── AnimationPlayer
```

Les boutons utilisent les libellés `MISSION PROTOTYPE`, `GALERIE DA` et `QUITTER`. Leur navigation clavier/manette est explicite. Le premier bouton obtient le focus à l’entrée dans l’arbre.

### `ArtDirectionGallery.tscn`

```text
ArtDirectionGallery (Control)
├── Backdrop (ColorRect)
├── SafeArea (MarginContainer)
│   └── Layout (VBoxContainer)
│       ├── Header (HBoxContainer)
│       │   ├── BackButton (Button)
│       │   ├── Title (Label)
│       │   └── Counter (Label)
│       ├── BoardFrame (PanelContainer)
│       │   └── BoardTexture (TextureRect)
│       ├── BoardName (Label)
│       └── Navigation (HBoxContainer)
│           ├── PreviousButton (Button)
│           └── NextButton (Button)
└── AnimationPlayer
```

Le `GalleryCatalog` référence exactement les sept PNG actuels. Chaque entrée contient un titre français court, une `Texture2D` et une catégorie. La galerie offre navigation boutons, actions `ui_left` / `ui_right`, retour avec `ui_cancel`, boucle en fin de catalogue et transition courte par `AnimationPlayer`.

### `PrototypeMissionScreen.tscn`

```text
PrototypeMissionScreen (Control)
├── MissionViewport (SubViewportContainer)
│   └── MissionViewport (SubViewport)
│       └── PrototypeMission (instance)
├── HUD (MarginContainer)
│   └── HUDLayout (HBoxContainer)
├── DesignReferencePanel (PanelContainer)
│   └── ReferenceTexture (TextureRect)
├── BackButton (Button)
└── AnimationPlayer
```

Le panneau de référence est visible par défaut dans l’éditeur et masqué au lancement. Il permet de conserver la planche environnement à côté de la composition sans transformer celle-ci en asset de niveau.

### `PrototypeMission.tscn`

```text
PrototypeMission (Node2D)
├── Background (Sprite2D)
├── Parallax2D
│   ├── FarLayer (Sprite2D)
│   └── MidLayer (Sprite2D)
├── World
│   ├── TerrainPreview (Polygon2D)
│   ├── IndestructibleAnchors (Node2D)
│   ├── PlayerSpawn (Marker2D)
│   ├── EnemySpawns (Node2D)
│   │   ├── VacuumTrooperSpawn (Marker2D)
│   │   └── VacuumBruteSpawn (Marker2D)
│   └── CameraBounds (ReferenceRect)
├── PreviewActors (Node2D)
│   ├── PlayerSilhouette (Polygon2D)
│   └── EnemySilhouettes (Node2D)
└── Camera2D
```

Cette scène est une composition visuelle, pas encore un niveau jouable. Les silhouettes et marqueurs rendent les futures responsabilités visibles dans le `SceneTree`. Les références aux futures scènes de joueur, d’ennemi et de terrain ne sont pas inventées dans cette tranche.

## Resources et Inspector

### `AppFlowConfig`

- groupe `Screens` : Boot, Start, Gallery, Prototype Mission ;
- groupe `Transitions` : durée du fondu, couleur du fondu ;
- chaque scène est obligatoire et validée par `Main.gd` en mode `@tool`, qui expose un avertissement de configuration lorsque la Resource ou une référence manque.

### `GalleryEntry`

- `display_name: String` ;
- `category: StringName` ;
- `board_texture: Texture2D`.

### `GalleryCatalog`

- `entries: Array[GalleryEntry]` ;
- l’ordre de l’Inspector constitue l’ordre de navigation ;
- aucune recherche dynamique de fichiers au runtime.

### `Theme`

`GameUITheme.tres` configure les types natifs `Button`, `Label`, `PanelContainer` et `ProgressBar`. La palette reprend charbon, olive, magenta, vert toxique, orange danger et crème. Les styles sont centralisés dans le Theme ; les scènes ne dupliquent pas arbitrairement couleurs et tailles.

## Entrées

Les actions natives `ui_accept`, `ui_cancel`, `ui_left` et `ui_right` suffisent à cette tranche. Aucun mapping gameplay n’est ajouté avant l’apparition du joueur contrôlable.

Souris, clavier et manette doivent permettre d’atteindre toutes les commandes. Le projet cible une fenêtre 1280 × 720 avec étirement `canvas_items` et ratio `keep`.

## Gestion des erreurs

- une scène absente de `AppFlowConfig` produit un `push_error`, conserve l’écran courant et ne plante pas ;
- une entrée de galerie sans texture affiche un panneau d’erreur visuel et reste navigable ;
- un catalogue vide affiche `AUCUNE PLANCHE` et garde le bouton Retour fonctionnel ;
- chaque script `@tool` pertinent expose `_get_configuration_warnings()` pour les dépendances Inspector manquantes ;
- aucune scène ne dépend d’un chemin de Node profond appartenant à une autre scène.

## Validation

Le script `foundation_smoke_test.gd`, lancé avec Godot en mode headless, vérifie :

1. le chargement de `Main.tscn` et des quatre écrans ;
2. la présence et le type des quatre `PackedScene` dans `AppFlowConfig.tres` ;
3. les sept entrées du catalogue, toutes munies d’une texture existante ;
4. les signaux publics attendus sur chaque écran ;
5. la présence des marqueurs `PlayerSpawn`, `VacuumTrooperSpawn` et `VacuumBruteSpawn` dans la mission ;
6. l’absence d’Autoload dans `project.godot` ;
7. le démarrage de la scène principale pendant quelques images sans erreur de script.

Une seconde vérification ouvre puis ferme le projet avec Godot 4.7.1 en mode éditeur headless afin d’importer les PNG et de détecter les erreurs de parsing des `.tscn`, `.tres` et `.gd`.

## Hors portée

Cette tranche ne crée pas encore : contrôleur du joueur, tir, dégâts, IA ennemie, éjection du pilote, véritable terrain destructible, sauvegarde, options, audio, logo définitif, sprites découpés ou animations de gameplay. Les planches restent des références artistiques ; elles ne sont pas découpées automatiquement en sprites.

La tranche suivante pourra traiter le premier personnage contrôlable et sa visée arcade classique, une fois cette fondation visible et validée dans Godot.

## Critères d’acceptation

- ouvrir `project.godot` affiche une arborescence lisible sans erreur ;
- F6 permet d’inspecter séparément Boot, Start, Galerie et Mission prototype ;
- F5 parcourt Boot → Start puis ouvre et ferme Galerie et Mission ;
- les sept planches sont consultables dans la galerie ;
- la mission prototype montre clairement décor, terrain, caméra, joueur et deux emplacements ennemis ;
- modifier l’ordre du `GalleryCatalog.tres` dans l’Inspector modifie l’ordre de la galerie sans code ;
- modifier les références de `AppFlowConfig.tres` remplace les écrans sans modifier `Main.gd` ;
- les validations headless terminent avec un code de sortie nul.
