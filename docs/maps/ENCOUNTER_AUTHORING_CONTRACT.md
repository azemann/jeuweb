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

Une recette complète reste une `EncounterData` externe enregistrée en `.tres`,
car elle est assignée, dupliquée ou remplacée depuis les Markers. À l'intérieur
de cette recette, une Wave ou un Spawn Pattern utilisé une seule fois reste une
sous-resource éditable. Il devient un fichier `.tres` séparé uniquement lorsque
plusieurs parents le référencent réellement.

```text
EncounterData.tres                 toujours externe
├── WaveData                       intégrée par défaut
│   └── EnemySpawnPatternData      intégré par défaut
└── Resource externe               seulement si réellement partagée
```

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
`Gauntlet`, `Set Piece` et `Arena`. `Combat Gate` reste un vocabulaire réservé,
mais Côte toxique n'instancie aucune barrière physique. La sortie de mission
consomme uniquement `Blocks Mission Exit`. Les verrous caméra propres à Kill
Room/Arena et l'orchestration audiovisuelle des Set Pieces restent séparés.

## Workflow dans Godot

1. créer la recette `EncounterData.tres` dans le dossier de mission ;
2. ajouter ses `WaveData` comme sous-resources et nommer leur beat ;
3. ajouter les `EnemySpawnPatternData` comme sous-resources de leur Wave ;
4. enregistrer une Wave ou un Pattern dans un `.tres` séparé seulement au
   moment où une seconde recette doit réutiliser exactement la même donnée ;
5. glisser ou sélectionner cette Resource sur un `MapEncounterMarker2D` sous
   `Gameplay/EncounterMarkers` ;
6. placer le Marker, régler `Activation Distance` et laisser `Enabled` actif ;
7. choisir explicitement `Blocks Mission Exit` ; le mode Flux Libre réserve ce
   rôle au Boss final et ne crée aucune barrière physique ;
8. vérifier les avertissements de la carte et exécuter
   `encounter_cadence_contract_test.gd`.

### Duplication sûre d'une occurrence

Dupliquer un `MapEncounterMarker2D` duplique volontairement sa référence vers la
même recette, mais recopie aussi son `encounter_id`. Après la duplication :

1. renommer le Marker selon sa nouvelle occurrence ;
2. cliquer `Générer un Encounter ID unique` dans l'Inspector ;
3. conserver la même `EncounterData` si la cadence doit réellement être
   réutilisée, ou enregistrer une nouvelle recette `.tres` avant de la modifier ;
4. décider explicitement si la recette bloque la victoire ; ne pas ajouter de
   porte physique dans une mission Flux Libre.

Un Marker signale désormais directement l'identifiant d'un frère dupliqué et
une `EncounterData` encore intégrée comme sous-resource de la scène maîtresse.
Cette interdiction concerne la recette assignée au Marker, pas ses Waves et
Patterns internes. Modifier une Resource externe partagée modifie toutes ses
occurrences : c'est une réutilisation, pas une copie indépendante.

Le HUD affiche la rencontre et le beat actifs. Il constitue un feedback de
prototype, pas l'autorité du rythme.

## Contrat runtime

- une occurrence ne démarre qu'une fois lorsque le joueur franchit son seuil ;
- l'état transitoire d'une occurrence est un `EncounterRuntimeState` typé ; ses
  phases sont un enum et non des chaînes ou clés de dictionnaire libres ;
- le contrôleur respecte l'ordre des vagues, tous les délais et la condition
  `When Cleared` ou `After Delay` ;
- chaque ennemi est placé avant son `_ready()` afin que Patrol mémorise la
  bonne origine ;
- les morts réduisent la population active de leur rencontre ;
- une rencontre est terminée uniquement après sa dernière vague, l'élimination
  de toute sa population et son `Completion Delay` ;
- `MissionRunController` autorise la sortie lorsque toutes les rencontres
  actives dont `Blocks Mission Exit` est vrai sont terminées ;
- un pilote éjecté n'appartient pas automatiquement à la vague de sa coque.

## Côte toxique v001

```text
Landing Cadence
  Pressure   : 2 Troopers
  Release    : 1 Grunt

Bridge Gauntlet
  Pressure   : 2 Grunts
  Escalation : 2 Flying enemies, progression temporelle
  Escalation : 2 Grunts en Pincer

Foundry Boss Arena
  Pressure   : 2 Grunts
  Escalation : 1 Flying enemy de déplacement
  Payoff     : 1 Boss
```

La scène contient treize apparitions explicites, huit vagues et trois
occurrences. Landing et Pont restent facultatifs ; seule la finale Boss bloque
la victoire, sans porte physique. Les Troopers peuvent en plus éjecter leurs
Saboteurs : cette surprise comportementale ne doit pas être recopiée dans une
WaveData. La courbe globale est
`pressure → release → pressure → double escalation → pressure → escalation → payoff`.

## Validation

`MissionMapRoot2D.validation_errors()` vérifie présence et validité récursive
des Resources. `encounter_resource_structure_test.gd` protège la règle
« recette externe, éléments mono-usage intégrés, éléments réellement partagés
externes ». `encounter_cadence_contract_test.gd` protège les beats,
formations, résolution par `EnemyCatalog`, ordre runtime des rencontres de
progression et égalité entre le contenu de tous les Markers actifs et les
instances réellement enregistrées. `mission_run_contract_test.gd` tue
réellement les vagues successives avant d'autoriser la victoire.
