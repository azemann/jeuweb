# Pipeline de création des assets

Ce dossier est volontairement invisible pour l'importeur Godot grâce à
`pipeline/.gdignore`. Il contient le travail de fabrication, jamais des
Resources consommées par une scène.

```text
sources/  → originaux immuables et fichiers maîtres
working/  → essais et fichiers intermédiaires remplaçables
exports/  → candidats validés avant publication
recipes/  → prompts, transformations, versions et décisions
profiles/ → espace canonique, représentation et règles de livraison
manifests/→ inventaire et statut planned/candidate/validated/integrated
provenance/→ outil, références, transformations, empreintes et limites
tools/    → transformations et portes de validation déterministes
                         │
                         ▼ publication contrôlée
                    res://art/
```

Une scène ou une Resource Godot ne doit jamais référencer `res://pipeline/`.
Après validation visuelle et technique, le livrable est copié dans `art/` avec
un nom versionné, puis ajouté à `art/ASSET_MANIFEST.md`.

Une planche ImageGen reste `candidate`. Une planche n'est pas un atlas jouable,
et un export technique n'est pas `validated` sans revue humaine. Les statuts
sont : `planned → candidate → validated → integrated`, avec `rejected` et
`deferred` lorsque nécessaire.
