# Instructions permanentes — projet Godot

Avant toute modification significative, lire intégralement :

1. `docs/architecture/GODOT_EDITOR_FIRST_RESOURCE_FIRST.md` ;
2. `docs/PROJECT_STATE.md` ;
3. le contrat auteur du système concerné ;
4. `docs/assets/ASSET_PIPELINE_CONTRACT.md` pour tout travail visuel ou audio.

La doctrine obligatoire est :

```text
                    CONCEPT
                       ↓
                   AUTORITÉ
              ┌────────┼────────┐
              ↓        ↓        ↓
           SOURCE     DATA    RUNTIME
              ↓        ↓        ↓
          Pipeline  Resource    Node
              └────────┼────────┘
                       ↓
             CORRESPONDANCE / SCÈNE
                       ↓
                    INSPECTOR
                       ↓
              COMPOSANTS / SIGNAUX
                       ↓
                 CODE MINIMAL
                       ↓
                  VALIDATION
```

Avant toute implémentation Godot, répondre explicitement ou mentalement à ces
quatre questions :

1. Qui est l'autorité de chaque donnée ?
2. Où l'auteur modifie-t-il cela dans Godot ?
3. Quelle correspondance relie cette donnée aux autres systèmes ou outils ?
4. Comment vérifier automatiquement que cette architecture reste vraie ?

Une même information ne possède jamais deux autorités. Toute responsabilité
majeure doit idéalement être visible dans le SceneTree ou l'Inspector. Pour un
système important, maintenir ensemble contrat runtime, contrat auteur et
contrat de validation.

Ne jamais traiter Godot comme un simple runtime piloté par une architecture
entièrement en scripts. Préserver un projet editor-first, scene-first,
resource-first, data-driven et composé.

Après chaque tranche significative, appliquer
`docs/PROJECT_MEMORY_CONTRACT.md` afin que le projet reste reprenable après une
pause.
