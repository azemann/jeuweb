# Jeuweb — run-and-gun 2D solo

Projet Godot 4.7.1 editor-first, scène-first et Resource-first.

## Contrôles du prototype

- déplacement : Q/A et D ou flèches gauche/droite ;
- saut : Espace ;
- visée verticale : Z/W et S ou flèches haut/bas ;
- visée souris : déplacer le pointeur autour du joueur ;
- tir automatique : maintenir J, X ou le clic gauche ;
- manette : stick gauche/croix pour déplacement et visée classique, stick droit
  pour la visée libre, A pour sauter, X/RB/gâchette droite pour tirer ;
- téléphone : croix tactile, SAUT et TIR, affichés automatiquement sur écran
  tactile.

Le contrat durable des entrées se trouve dans
[`docs/input/PLAYER_INPUT_AUTHORING_CONTRACT.md`](docs/input/PLAYER_INPUT_AUTHORING_CONTRACT.md).

## Reprendre le projet après une pause

1. Lire [`docs/PROJECT_STATE.md`](docs/PROJECT_STATE.md).
2. Lire la dernière entrée de [`docs/WORKLOG.md`](docs/WORKLOG.md).
3. Consulter le contrat du système à modifier.
4. Pour la direction artistique, consulter
   [`art/ASSET_MANIFEST.md`](art/ASSET_MANIFEST.md).
5. Rejouer les validations indiquées dans l'état courant.

La règle durable de documentation et de versionnement est définie dans
[`docs/PROJECT_MEMORY_CONTRACT.md`](docs/PROJECT_MEMORY_CONTRACT.md).

La doctrine Godot obligatoire est conservée dans
[`docs/architecture/GODOT_EDITOR_FIRST_RESOURCE_FIRST.md`](docs/architecture/GODOT_EDITOR_FIRST_RESOURCE_FIRST.md)
et activée pour les sessions Codex par `AGENTS.md`.

Le vocabulaire officiel, les suffixes architecturaux et le catalogue des
`class_name` sont définis dans
[`docs/architecture/GLOSSARY_CLASSES_AND_VOCABULARY.md`](docs/architecture/GLOSSARY_CLASSES_AND_VOCABULARY.md).
La comparaison avec les recommandations officielles Godot, Unreal et Unity se
trouve dans
[`docs/research/GAME_ARCHITECTURE_RESEARCH.md`](docs/research/GAME_ARCHITECTURE_RESEARCH.md).

La fabrication des images est isolée de Godot sous `pipeline/assets/`. La
frontière de publication vers `art/` est définie dans
[`docs/assets/ASSET_PIPELINE_CONTRACT.md`](docs/assets/ASSET_PIPELINE_CONTRACT.md).

## Principe d'architecture

```text
Concept → autorité → source/data/runtime → pipeline/Resource/Node
        → correspondance/scène → Inspector → composants/signaux
        → code minimal → validation
```

Questions obligatoires : qui est l'autorité, où l'auteur modifie-t-il la
donnée, quelle correspondance la relie aux autres systèmes et quel test protège
cette architecture ?

Le Transform d'un objet placé dans une scène maîtresse est souverain. Rotation,
échelle non uniforme et miroir doivent être suivis par les systèmes dérivés ;
voir [`docs/architecture/AUTHORED_TRANSFORM_CONTRACT.md`](docs/architecture/AUTHORED_TRANSFORM_CONTRACT.md).
