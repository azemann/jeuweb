# Contrat auteur des cartes run-and-gun

Une carte n'est pas un script qui dessine un niveau. C'est une scène maîtresse
Godot dont les quatre graphes restent visibles et séparés :

1. `Visual` décrit arrière-plan, `TileMapLayer`, décoration et premier plan ;
2. `Gameplay` décrit segments, spawns, rencontres, dangers, interactions et sorties ;
3. `DestructibleZones` désigne la matière modifiable tandis que
   `IndestructibleGeometry` protège la structure du niveau ;
4. `CameraZones` complète les limites globales portées par la racine.

Les nouvelles pièces illustrées sont rangées sous `Gameplay/GroundPieces`.
Les branches `DestructibleZones` et `IndestructibleGeometry` restent présentes
pendant la migration des anciens volumes et `GroundModule2D`.

## Autorités

- `MissionMapDefinition.tres` possède identité, scène maîtresse, aperçu,
  dimensions et politique de destruction ;
- la scène maîtresse possède le placement final ;
- les `MapSegment2D` possèdent le découpage, l'ordre et l'intention des séquences ;
- les `TileMapLayer` possèdent le décor répétitif lorsqu'un TileSet existe ;
- les marqueurs Godot possèdent les rôles de gameplay ;
- le futur masque raster possédera uniquement la matière destructible runtime.
- chaque `GroundModule2D.outline` possède simultanément la forme visuelle et
  physique de son morceau de sol permanent ;
- `PermanentGroundStyle.tres` possède ses matières, couleurs et largeur de
  surface, jamais son placement ou sa géométrie.

Une même information ne doit pas être encodée dans le nom d'un Node, dans une
Resource et dans un script en parallèle.

## Branches obligatoires

```text
MissionMapRoot2D
├── Visual
├── Gameplay
│   ├── Segments
│   ├── SpawnPoints
│   ├── EnemySpawns
│   ├── Encounters
│   ├── GroundPieces
│   ├── DestructibleZones
│   ├── IndestructibleGeometry
│   ├── Hazards
│   ├── Interactions
│   ├── CameraZones
│   └── Exits
└── Actors
```

La racine doit retourner zéro erreur avec `validation_errors()`. Chaque
`spawn_id` et chaque `encounter_id` est stable et unique dans la carte.

## Segments de progression

Chaque enfant direct de `Gameplay/Segments` est un `MapSegment2D`. Les segments
sont ordonnés par `sequence_index`, commencent à `x = 0`, se suivent sans trou
ni chevauchement et couvrent exactement `MissionMapDefinition.world_size`.
Leur contour est visible dans l'éditeur, jamais au runtime.

Un segment décrit une intention de level design, pas la possession de ses
Nodes. Spawns, dangers et géométrie restent rangés dans leurs branches métier ;
leur position dans la scène détermine le segment auquel ils appartiennent.

## Panoramas et répétition

Un panorama n'est pas étiré pour simuler un niveau long. Le `Parallax2D`
possède sa vitesse relative et sa période via `repeat_size`. La répétition est
acceptable comme transition de production ; les futurs modules visuels
distinctifs seront placés dans les `TileMapLayer` ou comme scènes de décor.

Un plan de cadrage conserve une opacité franche. Sa lisibilité vient de sa
composition : faible intrusion verticale dans le couloir jouable et raccords
latéraux conçus pour sa période de répétition. L'opacité ne doit pas servir à
masquer une planche mal adaptée.

## Destruction

La destruction n'est jamais implicite. La `MissionMapDefinition` choisit :

- `NONE` : aucune matière modifiable ;
- `AUTHORED_ZONES` : seuls les volumes explicitement dessinés sont convertis
  en masque destructible ;
- `FULL_RASTER` : toute la matière raster de la carte peut être modifiée.

Les limites, sorties, supports critiques et volumes de caméra ne dépendent
jamais d'une matière destructible.

## Sol permanent sans TileSet

Une structure illustrée importante devient une instance de la scène canonique
`GroundModule2D` sous `Gameplay/IndestructibleGeometry` :

```text
GroundModule2D
├── Fill (Polygon2D)
├── Surface (Line2D)
└── Body (StaticBody2D)
    └── Collision (CollisionPolygon2D)
```

L'auteur modifie `Outline` et `Surface Path` sur l'instance dans l'Inspector.
Le script `@tool` recopie `Outline` vers `Fill` et `Collision` ; ces enfants ne
sont donc jamais édités comme autorités parallèles. La Resource de style peut
être remplacée par segment sans modifier la forme physique.

Un `WorldShell` séparé est interdit lorsqu'un module possède déjà sa collision.
Les TileMapLayer restent disponibles pour de la décoration répétitive future,
mais ne sont pas nécessaires à l'autorité du sol permanent.

## Ground Pieces glissables

Une pièce publiée possède une correspondance directe et traçable :

```text
PNG runtime et preview
        ↓
GroundPieceDefinition.tres
        ↓
GroundPiece2D.tscn préconfigurée
        ↓
instance sous Gameplay/GroundPieces
```

Le PNG publié est aussi l'aperçu canonique de la scène `.tscn`. Il ne faut pas
fabriquer une seconde vignette qui pourrait diverger du rendu réel.

Workflow auteur :

1. ouvrir `terrain/kits/<kit>/pieces/` dans le FileSystem Godot ;
2. glisser la scène choisie sous `Gameplay/GroundPieces` ;
3. placer, tourner, redimensionner ou miroiter librement l'instance ;
4. choisir `Permanent`, `Carvable` ou `Breakable` dans l'Inspector ;
5. utiliser « Régénérer depuis les zones » sur `DestructibleTerrain2D` ;
6. résoudre tous les avertissements de configuration avant de sauvegarder.

`Carvable` désactive la collision et le Sprite locaux au runtime puis compose
le PNG et son masque dans le terrain destructible global. `Permanent` conserve
une collision locale. `Breakable` conserve une vie locale et ne contamine pas
le masque Worms.

Le Transform de chaque instance est souverain. Les trois modes acceptent
rotation arbitraire, échelle uniforme ou non uniforme et miroir. En mode
Carvable, `DestructibleTerrain2D` applique la transformation inverse au bitmap
source ; masque, couleur et collisions par chunks restent donc alignés. Seule
une échelle nulle, mathématiquement non inversible, est invalide.

Cette règle appartient au contrat transversal
`docs/architecture/AUTHORED_TRANSFORM_CONTRACT.md` et s'applique aussi aux
futures familles d'objets auteur.

Pour Permanent et Breakable, la définition utilise un `Authored Outline` fermé.
Ses premiers points, identifiés par `Walk Surface Point Count`, constituent le
bord de marche sans dupliquer la collision. Godot affiche le contour en magenta
et la portion marchable en vert dans l'éditeur. En Carvable, ce contour local
n'est pas l'autorité : masque et collisions runtime suivent la destruction.

Pour qu'une pièce soit réellement utilisable en `Breakable`, sa
`GroundPieceDefinition` référence un `GroundBreakableProfile.tres` externe.
Ce panneau fixe ses PV et sa politique de rupture. Si `Remove After Break` est
désactivé, une `Destroyed Texture` est obligatoire ; sinon le validateur affiche
un avertissement jaune. Le mode reste choisi instance par instance dans la map.
