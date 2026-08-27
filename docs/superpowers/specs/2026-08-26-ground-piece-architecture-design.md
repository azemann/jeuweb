# Architecture cible des Ground Pieces

Date : 2026-08-26  
Statut : conception validée verbalement, en attente de revue du document

## Objectif

Permettre à l'auteur de glisser une pièce de terrain depuis le FileSystem Godot
dans une scène de carte, puis de choisir dans l'Inspector si elle est permanente,
creusable façon Worms ou cassable comme un objet possédant des points de vie.

Le même asset visuel doit servir dans les trois modes sans copie parallèle. La
planche de direction artistique reste une référence ; elle ne devient jamais un
atlas ou une collision runtime.

## Hors périmètre de la première tranche

- outil de palette ou dock personnalisé ;
- génération complète du kit Côte toxique ;
- destruction physique en fragments simulés ;
- migration immédiate de tous les sols de la carte ;
- remplacement du système de chunks déjà fonctionnel.

Le premier résultat doit être une fondation validée avec une seule pièce témoin.

## Autorités

| Information | Autorité |
|---|---|
| Direction artistique | planche archivée dans le pipeline |
| Source haute définition d'une pièce | `pipeline/assets/sources/terrain_kits/` |
| Bitmap réellement importé | `art/terrain/pieces/` |
| Texture, masque et réglages par défaut | `GroundPieceDefinition.tres` |
| Mode Permanent/Carvable/Breakable | instance `GroundPiece2D` dans la map |
| Position, rotation, miroir et ordre | scène maîtresse de la map |
| Matière creusée pendant la partie | `DestructibleTerrain2D` |
| Vie courante d'une pièce cassable | composant runtime de son instance |

Un contour ne possède qu'une seule autorité active : alpha du PNG ou contour
auteur, selon `collision_source`. Le contour dérivé de l'alpha est une donnée
générée et ne doit pas être édité manuellement.

## Arborescence cible

```text
pipeline/assets/
├── references/toxic_coast/
├── sources/terrain_kits/toxic_coast/
├── working/terrain_kits/toxic_coast/
├── exports/terrain_kits/toxic_coast/
├── recipes/
├── manifests/
└── provenance/

art/terrain/
├── materials/toxic_coast/
└── pieces/toxic_coast/
    ├── natural/
    ├── military/
    ├── metal/
    └── hazards/

terrain/
├── destructible/
│   ├── destructible_terrain_2d.gd
│   └── profiles/
├── ground_pieces/
│   ├── ground_piece_2d.gd
│   ├── ground_piece_2d.tscn
│   ├── ground_piece_definition.gd
│   ├── ground_kit_catalog.gd
│   └── components/
└── kits/toxic_coast/
    ├── definitions/
    ├── pieces/
    └── toxic_coast_ground_kit.tres
```

Les chemins existants ne sont migrés qu'après mise à jour de leurs consommateurs.
Une étape de migration ne doit jamais laisser une Resource avec une référence
cassée.

## Resource `GroundPieceDefinition`

La Resource décrit ce qu'est une pièce, jamais où elle se trouve ni son état
runtime.

### Identity

- `piece_id: StringName` stable et unique ;
- `display_name: String` ;
- `category: enum Natural, Military, Metal, Hazard` ;
- `tags: PackedStringArray` pour filtrage futur.

### Presentation

- `texture: Texture2D` ;
- `pivot_px: Vector2` exprimé dans le canevas publié ;
- `default_z_index: int` ;
- `default_flip_h: bool` ;
- `destroyed_texture: Texture2D` optionnelle pour le mode cassable.

`texture` est aussi l'aperçu canonique de la scène glissable dans l'Inspector et
le futur catalogue. Aucune vignette PNG distincte n'est entretenue.

### Geometry

- `collision_source: enum Alpha, AuthoredOutline` ;
- `alpha_threshold: float` borné de 0 à 1 ;
- `simplification: float` ;
- `authored_outline: PackedVector2Array` utilisé uniquement lorsque la source
  choisie est `AuthoredOutline` ;
- `material_mask: Texture2D` optionnel. En son absence, l'alpha de `texture`
  possède la matière.

### Recommended behavior

- `recommended_mode: enum Permanent, Carvable, Breakable` ;
- `breakable_profile` optionnel.

`recommended_mode` initialise une scène de kit mais l'instance de map reste
l'autorité du mode réellement choisi.

## Scène canonique `GroundPiece2D`

```text
GroundPiece2D
├── Presentation (Sprite2D)
├── PermanentBody (StaticBody2D)
│   └── Collision (CollisionPolygon2D)
├── DestructibleStamp (Node2D)
├── BreakableComponent (Node)
└── EditorPreview (Node2D)
```

Exports principaux, regroupés dans l'Inspector :

```text
Definition
    Piece Definition

Gameplay
    Ground Mode

Placement
    Flip Horizontally
    Render Priority

Overrides
    Collision Source Override
    Authored Outline Override
```

Le script `@tool` synchronise les enfants depuis la définition et le mode. Les
enfants restent visibles pour expliquer l'architecture, mais ne sont pas des
autorités éditables en parallèle.

## Les trois modes

### Permanent

- `Presentation` est visible ;
- `PermanentBody` porte la collision ;
- `DestructibleStamp` et `BreakableComponent` sont inactifs ;
- les explosions ne peuvent pas modifier la pièce.

### Carvable

- la pièce fournit sa transformation, sa texture et son masque au terrain
  destructible global ;
- son Sprite2D local et son StaticBody2D sont désactivés au runtime pour éviter
  une double représentation et une double collision ;
- `DestructibleTerrain2D` compose les stamps dans un ordre déterministe, puis
  conserve l'autorité du bitmap et des collisions par chunks ;
- une explosion creuse donc continûment plusieurs pièces qui se chevauchent.

### Breakable

- `Presentation` et une collision locale restent actives ;
- `BreakableComponent` possède la vie courante et émet `piece_broken` ;
- la définition fournit éventuellement une texture détruite ;
- cette destruction ne modifie pas le masque Worms global.

## Génération depuis l'alpha

Le PNG transparent est le défaut recommandé. Le pipeline vérifie :

- présence d'un canal alpha réel ;
- absence de pixels opaques sur les bords non raccordables ;
- dimensions et pivot documentés ;
- zone alpha non vide ;
- empreinte et provenance.

Dans Godot, le contour est généré avec seuil et simplification configurables.
Une pièce complexe peut choisir `AuthoredOutline`, auquel cas le tableau de
points de la Resource devient l'unique autorité géométrique.

Les deux sources ne sont jamais fusionnées silencieusement. Une configuration
incomplète produit un avertissement dans l'éditeur.

## Composition du terrain creusable

La scène maîtresse possède une branche unique :

```text
Gameplay
└── GroundPieces
    ├── LandingLedge
    ├── AcidBridgeSoil
    ├── FoundryBlock
    └── MetalBridge
```

Le nom ou la branche ne duplique pas le mode. Celui-ci reste lisible sur chaque
instance dans l'Inspector.

Au démarrage ou lors d'une régénération éditeur :

1. `DestructibleTerrain2D` collecte les `GroundPiece2D` en mode `Carvable` ;
2. il valide définitions et transformations ;
3. il trie par `render_priority`, puis par ordre stable dans la scène ;
4. il applique les masques et textures au canevas global ;
5. il crée le bitmap physique et les chunks ;
6. il désactive la présentation et la collision locales de ces pièces ;
7. les modes Permanent et Breakable demeurent autonomes.

La composition accepte la transformation Godot complète de l'instance :
translation, rotation, miroir, échelle uniforme ou non uniforme et héritage du
parent. Le rééchantillonnage inverse maintient masque, couleur et collision dans
la même correspondance.

## Scènes prêtes à glisser et catalogue

Chaque asset approuvé produit :

```text
definitions/natural_ledge_large.tres
pieces/natural_ledge_large.tscn
```

La petite scène ne duplique aucune donnée : elle instancie la scène canonique,
référence sa définition et applique le mode conseillé.

`GroundKitCatalog.tres` référence les `PackedScene` du kit par catégorie. Il
servira aux validations et, seulement si le volume le justifie, à un futur dock
d'éditeur. La première tranche utilise le glisser-déposer natif du FileSystem.

## Pipeline de fabrication

```text
planche de référence
        ↓
génération de pièces séparées sur alpha
        ↓
sources immuables
        ↓
normalisation, pivot, masque, QA
        ↓
exports candidats
        ↓ validation humaine
PNG publiés dans art/
        ↓
Resources et scènes du kit
```

Les recettes et manifests enregistrent le rôle `reference`, `source`, `export`
ou `runtime`. Une scène Godot ne référence jamais `pipeline/`.

## Erreurs et avertissements d'éditeur

`GroundPiece2D.validation_errors()` doit notamment signaler :

- définition absente ou invalide ;
- texture absente ;
- `piece_id` vide ;
- alpha vide pour une géométrie dérivée ;
- contour auteur de moins de trois points ;
- profil cassable absent en mode Breakable ;
- transformation non inversible parce qu'une composante d'échelle est nulle ;
- identifiant dupliqué dans le catalogue.

Une pièce invalide reste visible en prévisualisation avec un avertissement, mais
n'est pas intégrée silencieusement au terrain destructible.

## Migration depuis l'état actuel

### Tranche 1 — fondation sans régression

- créer Resource, scène canonique et catalogue ;
- adapter `DestructibleTerrain2D` pour lire les pièces Carvable tout en gardant
  temporairement `DestructibleZones` comme source legacy ;
- produire puis intégrer la première vraie pièce
  `natural_ledge_medium_v001`, isolée sur alpha depuis la direction artistique
  Côte toxique et passée par les portes de validation du pipeline ;
- conserver les quatre `GroundModule2D` actuels.

### Tranche 2 — premier kit artistique

- produire un petit lot Côte toxique approuvé ;
- publier les PNG dans `art/terrain/pieces/toxic_coast/` ;
- créer leurs définitions et scènes glissables ;
- remplacer une zone de la séquence `landing_zone` pour validation en jeu.

### Tranche 3 — migration de la carte

- remplacer progressivement `DestructibleZones` et `GroundModule2D` ;
- retirer la compatibilité legacy seulement lorsque la carte et les tests ne
  l'utilisent plus ;
- déplacer les matières existantes uniquement avec mise à jour atomique des
  Resources consommatrices.

### Tranche 4 — outil d'éditeur optionnel

Créer une palette seulement si le nombre de scènes rend le FileSystem pénible.

## Validation automatique

- test de la Resource et de ses avertissements ;
- test des trois modes et de l'activation exclusive de leurs composants ;
- test alpha vers contour avec seuil et simplification déterministes ;
- test d'un cratère traversant deux stamps voisins ;
- test de l'absence de double collision en mode Carvable ;
- test du signal et de la variante détruite en mode Breakable ;
- test d'unicité des identifiants du catalogue ;
- test de contrat interdisant toute référence runtime vers `pipeline/` ;
- tests existants conservés pendant chaque étape de migration.

## Critère de réussite

Sans lire les scripts, l'auteur peut :

1. ouvrir `terrain/kits/toxic_coast/pieces/` ;
2. glisser une scène dans `Gameplay/GroundPieces` ;
3. choisir son mode dans l'Inspector ;
4. voir son image et sa collision dans l'éditeur ;
5. lancer la mission et obtenir soit une collision permanente, soit des cratères,
   soit une structure cassable.
