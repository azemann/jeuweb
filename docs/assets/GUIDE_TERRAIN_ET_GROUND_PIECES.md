# Guide de repérage — terrain et Ground Pieces

Ce document indique où trouver chaque élément du décor et quelle information
fait autorité. Il distingue l'état actuel du projet de l'organisation cible en
cours de conception.

Spécification technique correspondante :
`docs/superpowers/specs/2026-08-26-ground-piece-architecture-design.md`.

## La règle courte

```text
PLANCHE DE RÉFÉRENCE
        ↓ inspiration seulement
SOURCE ISOLÉE DANS LE PIPELINE
        ↓ traitement et validation
PNG PUBLIÉ DANS ART
        ↓ référencé par
RESOURCE + SCÈNE GODOT
        ↓ glissée dans
SCÈNE MAÎTRESSE DE LA MAP
```

Une planche de référence n'est jamais découpée ou utilisée directement par le
terrain runtime.

## Les trois types d'images à ne pas confondre

### 1. Planche de référence

Elle montre la direction artistique, les silhouettes et les familles d'objets.
Elle ne possède ni collision, ni masque destructible, ni découpe runtime.

Emplacement actuel publié pour la galerie :

```text
art/concepts/da-03-environment-destruction.png
```

Emplacement autoritaire cible :

```text
pipeline/assets/references/toxic_coast/environment-destruction-v001.png
```

La copie sous `art/concepts/` restera un livrable de galerie uniquement.

### 2. Matières répétables

Ce sont les textures de terre, de profondeur et de surface répétées par le
système destructible ou par un remplissage de sol permanent.

Emplacement actuel :

```text
art/terrain/toxic_coast/
├── toxic-soil-shallow-v001.png
├── toxic-soil-main-v001.png
├── toxic-soil-deep-v001.png
├── toxic-surface-intact-v001.png
└── toxic-surface-fresh-v001.png
```

Organisation cible :

```text
art/terrain/materials/toxic_coast/
```

Ces images décrivent une matière. Elles ne décrivent pas un rocher, un pont ou
une plateforme particulière.

### 3. Pièces illustrées

Ce sont des PNG transparents et isolés : rocher, berge, bloc militaire,
plateforme métallique, tuyau, passerelle ou bassin toxique.

Organisation cible :

```text
art/terrain/pieces/toxic_coast/
├── natural/
├── military/
├── metal/
└── hazards/
```

Chaque image publiée sera utilisée par une Resource puis par une scène Godot
glissable. Le PNG publié est également l'aperçu canonique de cette scène : une
vignette séparée est interdite afin d'éviter deux représentations divergentes.

Exemple de pièce intégrée :

```text
art/terrain/pieces/toxic_coast/natural/natural-ledge-medium-v001.png
        ↓
terrain/kits/toxic_coast/definitions/natural_ledge_medium.tres
        ↓
terrain/kits/toxic_coast/pieces/natural_ledge_medium.tscn
```

## Fabrication hors de Godot

Tout ce qui sert à créer les images reste sous `pipeline/`, rendu invisible à
l'importeur Godot par `.gdignore`.

```text
pipeline/assets/
├── references/toxic_coast/              # planches d'inspiration
├── sources/terrain_kits/toxic_coast/     # sources isolées immuables
├── working/terrain_kits/toxic_coast/     # essais remplaçables
├── exports/terrain_kits/toxic_coast/     # candidats à valider
├── recipes/                              # fabrication reproductible
├── manifests/                            # liste et statut des fichiers
└── provenance/                           # origine et transformations
```

Godot ne doit jamais référencer une image située sous `pipeline/`.

## Intégration dans Godot

Architecture désormais amorcée :

```text
terrain/
├── destructible/
│   ├── destructible_terrain_2d.tscn
│   └── profiles/
├── ground_pieces/
│   ├── ground_piece_2d.tscn
│   ├── ground_piece_definition.gd
│   └── composants spécialisés
└── kits/toxic_coast/
    ├── definitions/
    ├── pieces/
    └── toxic_coast_ground_kit.tres
```

Une pièce prête à glisser prendra cette forme :

```text
GroundPiece2D
├── Presentation
├── PermanentBody
├── DestructibleStamp
├── BreakableComponent
└── EditorPreview
```

L'instance dans la map choisira son mode depuis l'Inspector :

- `Permanent` : collision statique, jamais creusée ;
- `Carvable` : contribution au terrain raster et cratères façon Worms ; la
  collision joueur/ennemis vient de `DestructibleTerrain2D` généré au lancement,
  pas d'une collision locale parallèle dans la pièce ;
- `Breakable` : objet entier possédant une vie et une variante détruite.

## Catalogue extensible pour les futurs niveaux

`GroundKitCatalog.tres` est la bibliothèque auteur des scènes disponibles pour
un biome ou une famille visuelle. Son tableau `pieces` est volontairement
extensible dans l'Inspector : les quatre entrées publiées aujourd'hui ne
constituent ni une limite ni une liste définitive.

Pour enrichir un kit, l'auteur publie une nouvelle `GroundPieceDefinition`,
l'associe à une scène canonique `GroundPiece2D`, puis ajoute cette `PackedScene`
au tableau `pieces` du catalogue concerné. Son `piece_id` stable permet aux
outils et validations de la retrouver. Les scènes maîtresses des futurs niveaux
peuvent ensuite glisser et configurer ces pièces sans dépendre de la carte Côte
toxique actuelle.

Un nouveau biome peut posséder son propre `GroundKitCatalog.tres`. Aucun test ne
doit figer le nombre total de pièces ; les contrats vérifient plutôt que chaque
entrée est instanciable, canonique, identifiée de façon unique et valide.

## Où modifier quoi ?

| Besoin | Emplacement ou autorité |
|---|---|
| Revoir la direction artistique | planche sous `pipeline/assets/references/` |
| Modifier la source d'un morceau | `pipeline/assets/sources/terrain_kits/` |
| Régénérer un export | recette et outil sous `pipeline/assets/` |
| Voir le PNG réellement importé | `art/terrain/pieces/` |
| Changer texture, masque ou contour par défaut | `GroundPieceDefinition.tres` |
| Choisir Permanent, Carvable ou Breakable | instance `GroundPiece2D` dans l'Inspector |
| Déplacer un morceau | scène maîtresse de la map |
| Modifier les cratères runtime | `DestructibleTerrain2D` |
| Changer la vie d'une structure cassable | Resource ou composant Breakable |

La première corniche possède son panneau réutilisable sous
`terrain/kits/toxic_coast/breakables/natural_ledge_breakable.tres`. Sa valeur de
PV reste celle réglée dans l'Inspector. À `Damaged Health Ratio` (35 % par
défaut), `Damaged Texture` remplace l'image intacte. À zéro PV,
`Destroyed Texture` devient la ruine finale et la collision disparaît.
`Remove After Break` reste donc désactivé pour cette pièce.

## État actuel du projet

Aujourd'hui :

- `DestructibleTerrain2D` génère un masque global depuis
  `Gameplay/DestructibleZones` ;
- `GroundModule2D` représente les sols permanents avec un polygone auteur et
  des matières répétées ;
- `PermanentGroundStyle.tres` et `DestructibleTerrainProfile.tres` réutilisent
  les mêmes matières Côte toxique ;
- quatre pièces Côte toxique sont publiées aujourd'hui : corniche naturelle,
  bloc bunker, passerelle industrielle et pont-tuyau ; cette liste est un état
  courant appelé à s'enrichir pour l'édition des futurs niveaux ;
- `GroundPieceDefinition`, `GroundPiece2D`, les trois modes et le catalogue
  extensible Côte toxique sont implémentés ;
- `Gameplay/GroundPieces/LandingNaturalLedge` valide le workflow dans la map ;
- les anciens chemins de matières et `GroundModule2D` restent temporairement
  actifs pour une migration sans régression.

## Autorité unique

| Information | Autorité cible |
|---|---|
| Direction artistique | planche du pipeline |
| Source haute définition isolée | source du pipeline |
| Bitmap livré au jeu | fichier publié sous `art/` |
| Définition d'une pièce | `GroundPieceDefinition.tres` |
| Liste des pièces disponibles dans un kit | tableau `pieces` de `GroundKitCatalog.tres` |
| Mode de destruction | instance dans la scène maîtresse |
| Placement et transformation | scène maîtresse de la map |
| Matière creusée pendant la partie | `DestructibleTerrain2D` |
| Vie d'une pièce cassable | composant runtime de la pièce |

## Budgets physiques

Le `DestructibleTerrainProfile` est l'autorité des budgets de chunks, de formes
physiques et de chunks reconstruits par flush. `DestructibleTerrain2D` expose
`collision_shape_count()` et `performance_budget_errors()` pour permettre aux
tests de vérifier ces limites sans figer la géométrie exacte d'une carte.

`TerrainCollisionBuilder` contient uniquement la transformation géométrique
pure contour → pièces convexes. Il ne possède ni état, ni Node, ni autorité :
le masque, les chunks sales, les corps et leur cycle de vie restent dans le
`DestructibleTerrain2D` visible sous `Runtime/DestructibleTerrain`.

Chaque contour solide est triangulé de façon déterministe, puis les triangles
adjacents sont fusionnés tant que leur union reste convexe. Le terrain conserve
ainsi un vrai volume physique — nécessaire aux détections d'`Area2D` — tout en
évitant un `CollisionShape2D` séparé pour chaque triangle lorsque plusieurs
triangles peuvent former une seule pièce convexe.

## Test mental avant toute modification

Avant d'ajouter ou de modifier un élément de terrain, répondre à ces questions :

1. Est-ce une référence, une source, un export, une donnée Godot ou une instance ?
2. Quel fichier est l'autorité de l'information modifiée ?
3. Est-ce une matière répétable ou une pièce illustrée ?
4. La pièce doit-elle être permanente, creusable ou cassable ?
5. La modification survivra-t-elle à une régénération du pipeline ?
