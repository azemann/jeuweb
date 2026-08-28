# Contrat auteur des rencontres et de l'enemy cadence

Une rencontre est une composition de Resources éditables, jamais une suite de
timers ou d'identifiants enfouis dans un script.

```text
EnemyArchetypeProfile / EnemyCatalog
                 ↓
       EnemySpawnPatternData
                 ↓
              WaveData
                 ↓
           EncounterData
                 ↓
      MapEncounterMarker2D
                 ↓
 MissionEncounterController
                 ↓
      MissionEnemySpawner2D
```

## Autorités

- famille comportementale : `EnemyArchetypeProfile` et sa correspondance dans
  `EnemyCatalog` ;
- archétype injecté, quantité, formation, offsets et intervalle :
  `EnemySpawnPatternData` ;
- beat, ordre des motifs, respiration initiale et condition d'avancement :
  `WaveData` ;
- ordre des vagues, type de rencontre, délai final et blocage de la sortie :
  `EncounterData` ;
- position finale, identité de l'occurrence, activation et neutralisation :
  `MapEncounterMarker2D` dans la scène maîtresse ;
- ennemis actifs et rencontres déjà déclenchées :
  `MissionEncounterController` au runtime ;
- traduction archétype vers scène et instanciation : `MissionEnemySpawner2D`.

Une quantité ou un archétype n'est jamais recopié sur le Marker. Un identifiant
d'occurrence de map (`encounter_id`) reste distinct de l'identité réutilisable
de la recette (`cadence_id`).

## Ressources auteur

### EnemySpawnPatternData

Les formations disponibles sont `Centered Line`, `Left To Right`,
`Right To Left`, `Vertical Stack`, `Pincer` et `Custom Offsets`. Le Transform du
Marker est souverain ; tous les offsets sont exprimés dans son repère auteur.
`Delay Before` sépare deux motifs et `Spawn Interval` transforme une formation
simultanée en injection cadencée.

### WaveData

Chaque vague déclare un beat : `Pressure`, `Release`, `Escalation` ou `Payoff`.
`When Cleared` attend l'élimination de la population active avant de continuer.
`After Delay` permet le chevauchement volontaire de menaces et construit un
Gauntlet. Les motifs d'une même vague sont exécutés dans l'ordre affiché.

### EncounterData

Les intentions disponibles sont `Standard`, `Combat Gate`, `Kill Room`,
`Gauntlet`, `Set Piece` et `Arena`. La cadence, les barrières physiques
`MissionCombatGate2D` et la sortie de mission possèdent un comportement complet.
Les verrous caméra propres à Kill Room/Arena et l'orchestration audiovisuelle
des Set Pieces restent des tranches séparées.

## Workflow dans Godot

1. créer ou réutiliser les `EnemySpawnPatternData` dans le dossier de mission ;
2. composer les motifs dans des `WaveData` et nommer leur beat ;
3. composer les vagues dans une `EncounterData` ;
4. glisser ou sélectionner cette Resource sur un `MapEncounterMarker2D` sous
   `Gameplay/EncounterMarkers` ;
5. placer le Marker, régler `Activation Distance` et laisser `Enabled` actif ;
6. placer un `MissionCombatGate2D` sous `Gameplay/CombatGates` avec le même
   `encounter_id` lorsque la rencontre bloque la sortie ;
7. vérifier les avertissements de la carte et exécuter
   `encounter_cadence_contract_test.gd`.

Le HUD affiche la rencontre et le beat actifs. Il constitue un feedback de
prototype, pas l'autorité du rythme.

## Contrat runtime

- une occurrence ne démarre qu'une fois lorsque le joueur franchit son seuil ;
- le contrôleur respecte l'ordre des vagues, tous les délais et la condition
  `When Cleared` ou `After Delay` ;
- chaque ennemi est placé avant son `_ready()` afin que Patrol mémorise la
  bonne origine ;
- les morts réduisent la population active de leur rencontre ;
- une rencontre est terminée uniquement après sa dernière vague, l'élimination
  de toute sa population et son `Completion Delay` ;
- chaque `MissionCombatGate2D` correspondant reste fermé puis perd visuel et
  collision à la fin de la rencontre ;
- `MissionRunController` autorise la sortie lorsque toutes les rencontres
  actives dont `Blocks Mission Exit` est vrai sont terminées ;
- un pilote éjecté n'appartient pas automatiquement à la vague de sa coque.

## Côte toxique v001

```text
Landing Cadence
  Pressure   : 2 Troopers
  Release    : 1 Grunt

Landing Cadence 2 (occurrence auteur non bloquante)
  Pressure   : 2 Troopers
  Release    : 1 Grunt

Bridge Gauntlet
  Pressure   : 2 Grunts
  Escalation : 2 Flying enemies, progression temporelle
  Escalation : 2 Grunts en Pincer

Foundry Boss Gate
  Pressure   : 2 Grunts
  Payoff     : 1 Boss
```

La scène actuellement éditée contient donc 15 apparitions, neuf vagues et quatre
occurrences. `LandingCadence2` réutilise volontairement les deux vagues Landing
sans bloquer la sortie. Les trois rencontres de progression conservent la courbe
globale `pressure → release → pressure → escalation → payoff`.

## Validation

`MissionMapRoot2D.validation_errors()` vérifie présence et validité récursive
des Resources. `encounter_cadence_contract_test.gd` protège les beats,
formations, résolution par `EnemyCatalog`, ordre runtime des rencontres de
progression et égalité entre le contenu de tous les Markers actifs et les
instances réellement enregistrées. `mission_run_contract_test.gd` tue
réellement les vagues successives avant d'autoriser la victoire.
