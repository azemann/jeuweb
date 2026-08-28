# Contrat auteur des ennemis

Un ennemi est une scène canonique composée. Son identité et ses réglages sont
des Resources ; son placement et l'intention de rencontre restent dans la scène
maîtresse de la carte.

## Autorités

- placement final et seuil d'activation : `MapEncounterMarker2D` dans la scène
  maîtresse ; quantité, formation et rythme : `EnemySpawnPatternData`,
  `WaveData` et `EncounterData` ;
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
├── Hurtbox (Area2D, optionnelle si la silhouette dépasse le corps physique)
├── Components
│   ├── Patrol
│   ├── Health
│   ├── Attack
│   ├── StateMachine
│   ├── Animation
│   ├── Grounding (ennemis terrestres)
│       ├── GroundAnchor
│       ├── GroundProbe
│       ├── LeftFootProbe
│       ├── RightFootProbe
│       └── GroundShadow
│   ├── SlopeAlignment (ennemis terrestres)
│   └── Ejection (optionnel)
└── Visuals
    └── GroundPivot (ennemis terrestres)
        └── BodySprite (AnimatedSprite2D)
```

`Components/Animation` est le `EnemyPresentationComponent` qui choisit les
animations ; `Visuals` contient uniquement les sprites et sockets. Ces noms
distincts interdisent l'ancienne ambiguïté de deux enfants `Presentation`.

## Workflow auteur

1. pour une nouvelle animation raster, produire une bande séparée par action,
   vérifier identité, phases, marges et root, puis publier l'atlas depuis le
   pipeline ;
2. assigner l'atlas au `SpriteFrames` de l'ennemi et régler les timings dans
   l'Inspector Godot ;
3. régler l'archétype dans sa Resource sous `characters/enemies/data/` ;
4. assembler ou prévisualiser sa scène canonique dans Godot ;
5. enregistrer sa correspondance dans `enemy_catalog.tres` ;
6. référencer l'archétype depuis un `EnemySpawnPatternData`, puis le composer
   dans une `WaveData` et un `EncounterData` ;
7. placer un `MapEncounterMarker2D` sous `Gameplay/EncounterMarkers`, lui assigner
   la rencontre et régler seulement son placement et sa distance d'activation ;
8. résoudre les avertissements et exécuter les contrats ennemi et animation.

Une action source contient quatre phases explicitement nommées. Le Vacuum
Trooper conserve deux bandes pour sa marche et son attaque à huit poses. Le
pipeline applique une échelle commune à l'action et place le contenu sur le
root auteur ; il ne choisit ni timing ni frame active de gameplay.

Le Transform du marqueur est souverain pour la formation. Les acteurs générés
appartiennent à la branche `Actors` de la map ; aucune scène runtime ne référence
le pipeline.

## Contrat runtime

- `MissionEncounterController` observe la progression et déroule chaque
  `encounter_id` une seule fois ; `MissionEnemySpawner2D` instancie seulement
  les scènes demandées par les Spawn Patterns ;
- le catalogue résout l'archétype sans chemin codé en dur dans la carte ;
- chaque instance reçoit son origine de patrouille depuis sa position générée ;
- Patrol possède la vélocité ; Health possède les PV ; Presentation ne modifie
  aucun état gameplay ;
- le profil choisit locomotion terrestre ou volante ; un volant omet
  `Grounding` et `SlopeAlignment`, et Patrol applique son oscillation auteur ;
- Attack possède le déclenchement, la frame active et l'effet projectile ou
  contact ; la scène conserve `AttackOrigin` comme socket auteur ;
- Grounding est le composant transversal chargé du root des pieds et de l'ombre
  projetée sur le vrai collider World ;
- `EnemyCharacter2D.apply_damage()` transmet uniquement l'intention à Health ;
- lorsqu'une Hurtbox étendue existe, elle possède seule la couche de réception
  des projectiles ; le corps conserve uniquement collision World et mouvement ;
- un dégât accepté suspend Patrol et déclenche `hit` dans Animation ; la
  marche reprend uniquement au signal de fin d'animation ;
- à zéro PV, la coque quitte la couche cible mais conserve sa collision World,
  Patrol ne fournit plus de mouvement horizontal et Animation joue `death` ;
- `EnemyCharacter2D` retire l'instance au signal de fin de `death`, jamais au
  signal `died` lui-même ; Ejection peut instancier un acteur indépendant dans
  `Actors` avant cette suppression.

## Contrat de validation

`enemy_contract_test.gd` protège profils, catalogue, scènes, modes terrestre et
volant, les poses `walk`, `attack`, `hit`, `death` de chaque rôle,
l'arbre canonique, les dégâts, la suppression différée et l'éjection réelle du
Saboteur. `map_contract_test.gd` protège les marqueurs auteur et
`mission_run_contract_test.gd` la victoire après les douze apparitions de la
cadence obligatoire.
Le test tire aussi un vrai `FieldRound2D` sur le bord visible supérieur du Boss
et protège l'autorité unique de sa Hurtbox.
`enemy_animation_roster_v002_test.gd` protège les 88 poses, les sept atlas v002
et surtout leurs dimensions compatibles avec les régions `SpriteFrames`.
`validate_enemy_animation_roster_v002.py` vérifie sources, hashes, alpha,
dimensions et identité binaire entre exports pipeline et copies runtime.
