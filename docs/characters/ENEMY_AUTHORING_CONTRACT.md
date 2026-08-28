# Contrat auteur des ennemis

Un ennemi est une scène canonique composée. Son identité et ses réglages sont
des Resources ; son placement et l'intention de rencontre restent dans la scène
maîtresse de la carte.

## Autorités

- placement, quantité, espacement et seuil d'activation :
  `MapEncounterMarker2D` dans la scène maîtresse ;
- correspondance `enemy_archetype` → scène : `EnemyCatalog.tres` ;
- PV, mode de locomotion, vitesse, amplitude de patrouille et vol ondulant :
  `EnemyArchetypeProfile.tres` ;
- vie courante : `EnemyHealthComponent` ;
- vélocité et retournements de patrouille : `EnemyPatrolComponent` ;
- animation et orientation visuelle : `EnemyPresentationComponent` ;
- collision et composition : scène canonique de l'ennemi ;
- attaque, frame de relâchement, projectile ou dégâts de contact :
  `EnemyAttackComponent` dans la scène canonique ;
- éjection optionnelle et scène du pilote : `EnemyEjectionComponent` ;
- bitmap livré : `art/`, avec source, recette et QA sous `pipeline/assets/`.

Une valeur de gameplay n'est jamais recopiée dans le spawner ou le script de
présentation.

## Arbre canonique

```text
EnemyCharacter2D (CharacterBody2D)
├── CollisionShape2D
├── Components
│   ├── Patrol
│   ├── Health
│   ├── Attack
│   ├── StateMachine
│   ├── Presentation
│   ├── Grounding (ennemis terrestres)
│       ├── GroundAnchor
│       ├── GroundProbe
│       ├── LeftFootProbe
│       ├── RightFootProbe
│       └── GroundShadow
│   ├── SlopePresentation (ennemis terrestres)
│   └── Ejection (optionnel)
└── Presentation
    └── SlopeVisual
        └── BodySprite (AnimatedSprite2D)
```

## Workflow auteur

1. régler l'archétype dans sa Resource sous `characters/enemies/data/` ;
2. assembler ou prévisualiser sa scène canonique dans Godot ;
3. enregistrer sa correspondance dans `enemy_catalog.tres` ;
4. placer un `MapEncounterMarker2D` sous `Gameplay/EnemySpawns` ;
5. choisir archétype, nombre, espacement et distance d'activation dans
   l'Inspector ;
6. résoudre les avertissements et exécuter `enemy_contract_test.gd`.

Le Transform du marqueur est souverain pour la formation. Les acteurs générés
appartiennent à la branche `Actors` de la map ; aucune scène runtime ne référence
le pipeline.

## Contrat runtime

- `MissionEnemySpawner2D` observe la progression du joueur et déclenche chaque
  `encounter_id` une seule fois ;
- le catalogue résout l'archétype sans chemin codé en dur dans la carte ;
- chaque instance reçoit son origine de patrouille depuis sa position générée ;
- Patrol possède la vélocité ; Health possède les PV ; Presentation ne modifie
  aucun état gameplay ;
- le profil choisit locomotion terrestre ou volante ; un volant omet
  `Grounding` et `SlopePresentation`, et Patrol applique son oscillation auteur ;
- Attack possède le déclenchement, la frame active et l'effet projectile ou
  contact ; la scène conserve `AttackOrigin` comme socket auteur ;
- Grounding est le composant transversal chargé du root des pieds et de l'ombre
  projetée sur le vrai collider World ;
- `EnemyCharacter2D.apply_damage()` transmet uniquement l'intention à Health ;
- un dégât accepté suspend Patrol et déclenche `hit` dans Presentation ; la
  marche reprend uniquement au signal de fin d'animation ;
- à zéro PV, la coque quitte la couche cible mais conserve sa collision World,
  Patrol ne fournit plus de mouvement horizontal et Presentation joue `death` ;
- `EnemyCharacter2D` retire l'instance au signal de fin de `death`, jamais au
  signal `died` lui-même ; Ejection peut instancier un acteur indépendant dans
  `Actors` avant cette suppression.

## Contrat de validation

`enemy_contract_test.gd` protège profils, catalogue, scènes, modes terrestre et
volant, les quatre poses `walk`, `attack`, `hit`, `death` de chaque rôle,
l'arbre canonique, les dégâts, la suppression différée et l'éjection réelle du
Saboteur. `map_contract_test.gd` protège les marqueurs auteur et
`mission_run_contract_test.gd` la victoire après les sept ennemis obligatoires.
Le validateur Python du roster vérifie 64 poses, dimensions, alpha et identité
binaire entre exports pipeline et copies runtime.
