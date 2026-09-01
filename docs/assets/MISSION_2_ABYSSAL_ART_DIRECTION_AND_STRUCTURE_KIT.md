# Mission 2 — DA abyssale et kit de structures

Statut : direction v002, premier kit de structures publié et à éprouver dans
l'éditeur Godot.

## Intention

Mission 2 doit rompre clairement avec la guerre industrielle toxique sans
changer de jeu. Elle reste un run-and-gun lisible, extravagant et destructible,
mais son vocabulaire devient techno-abyssal : ruines organiques, machines de
marée, nacre cassable, corail noir et énergie cyan.

La planche `art/concepts/da-08-abyssal-mission.png` est une référence de style,
pas un sprite gameplay. Les sprites réels passent toujours par
`pipeline/assets/`, puis par `GroundPieceDefinition` et scènes glissables.

## Règles visuelles

- silhouettes de marche nettes, horizontales ou inclinées, visibles même sur
  fond sombre ;
- bord supérieur calme et praticable, détails concentrés dessous ou en arrière ;
- palette dominante : corail noir, bleu pétrole, cyan bioluminescent, violet
  profond, cuivre oxydé et nacre claire ;
- éviter le vert toxique de Mission 1, les aplats noirs opaques et les formes
  qui cachent le joueur ;
- chaque pièce doit fonctionner en miroir et accepter le Transform auteur ;
- le pivot principal reste proche du bord de marche, jamais au centre décoratif.

## Familles de pièces

### Sols primaires

1. `black_coral_platform_small`
2. `black_coral_platform_medium`
3. `black_coral_platform_large`
4. `black_coral_floor_cap_left`
5. `black_coral_floor_cap_right`
6. `black_coral_thin_ledge`

### Raccords de parcours

1. `black_coral_slope_up`
2. `black_coral_slope_down`
3. `black_coral_step_low`
4. `black_coral_step_high`
5. `black_coral_drop_lip`
6. `black_coral_ceiling_hook`

### Structures techno-abyssales

1. `tide_engine_bridge_short`
2. `tide_engine_bridge_medium`
3. `tide_engine_bridge_long`
4. `tide_engine_bridge_broken_left`
5. `tide_engine_bridge_broken_right`
6. `tide_engine_support_pillar`
7. `tide_engine_pipe_arch`
8. `tide_engine_rotor_base`

### Architecture de ruines

1. `abyssal_temple_arch_small`
2. `abyssal_temple_arch_large`
3. `abyssal_temple_column_intact`
4. `abyssal_temple_column_broken`
5. `abyssal_temple_wall_backplate`
6. `abyssal_temple_corner_block`

### Destructibles et secrets

1. `destructible_pearl_wall_small`
2. `destructible_pearl_wall_medium`
3. `destructible_pearl_wall_large`
4. `pearl_shell_barricade`
5. `black_coral_breakable_plug`
6. `nacre_secret_door`

### Décor proche non autoritaire

Ces objets ne doivent pas devenir collision principale sans besoin explicite :

1. `cyan_tide_vent`
2. `nautilus_checkpoint_shrine`
3. `abyssal_supply_chest`
4. `harpoon_totem`
5. `coral_pressure_gauge`
6. `bioluminescent_anemone_cluster`

## Ordre de production conseillé

Lot v002 prioritaire :

- plateformes small, medium, large ;
- cap gauche et cap droit ;
- slope up et slope down ;
- pont short et long ;
- pilier de support ;
- arche traversable ;
- mur nacré small et large.

Ce lot suffit pour composer un acte entier sans créer de grand bitmap de sol.
Les hazards, checkpoints et props viennent ensuite seulement si le parcours les
réclame.

Statut actuel du lot v002 : publié sous
`art/terrain/pieces/abyssal/v002/`, intégré au catalogue abyssal et placé dans
un blockout de deux actes dans `maps/missions/mission2/mission_2.tscn`.

## Leçon de production

Le retour éditeur montre que les grands socles de la rangée basse de DA-08
portent mieux l'identité et le level design que les petites variantes isolées.
À partir de v003 :

- les grands socles DA-08 servent de base de sol principale ;
- les plateformes, caps, pentes et steps v002 servent de raccords ;
- les piliers, arches et colonnes décorent ou soutiennent les grands socles ;
- un fond sombre ne doit jamais masquer la lisibilité du bord de marche.

Cette approche suit les méthodes observées chez d'autres workflows : fabriquer
une palette de pièces éditables avant de composer le niveau, verrouiller pivots
et modules, et éviter de reconstruire le level design pendant l'art pass.

## Autorités

- DA : `art/concepts/da-08-abyssal-mission.png` ;
- sources et recettes : `pipeline/assets/` ;
- bitmap runtime : `art/terrain/pieces/abyssal/` ;
- identité, pivot, contour et surface : `GroundPieceDefinition.tres` ;
- mode, position, rotation, scale et miroir : instance `GroundPiece2D` dans la
  scène de mission ;
- liste offerte à l'auteur : `terrain/kits/abyssal/abyssal_ground_kit.tres`.

## Validation

Chaque ajout de pièce doit vérifier :

- aucun `.gd`, `.tscn` ou `.tres` runtime ne référence `res://pipeline/` ;
- le catalogue abyssal charge chaque scène et refuse les `piece_id` dupliqués ;
- chaque définition possède texture, pivot, contour auteur et surface de marche ;
- Mission 2 reste une `MissionMapRoot2D` valide ;
- `docs/PROJECT_STATE.md` projette les nouveaux IDs de catalogue.
