# Contrat du pipeline d'assets

Le pipeline de création et le système de fichiers Godot sont deux autorités
distinctes.

## Flux obligatoire

```text
SOURCE              WORKING             EXPORT
pipeline/assets/ → pipeline/assets/ → pipeline/assets/
   sources/            working/            exports/
                                               │
                                      validation humaine
                                               │
                                               ▼
RUNTIME OUTPUT       GODOT IMPORT       INTEGRATION
res://art/       →   fichier .import → Resource / scène
```

## Règles

1. `pipeline/` contient sources, prompts, fichiers de travail et exports non
   publiés ; `pipeline/.gdignore` empêche Godot de les importer.
2. `art/` ne contient que des livrables que Godot peut réellement consommer,
   ainsi que les planches explicitement utilisées par la galerie interne.
3. Aucune scène, Resource ou script runtime ne référence `res://pipeline/`.
4. Un fichier maître ou éditable ne reste pas dans `art/` s'il n'est pas un
   livrable runtime.
5. La publication est une copie contrôlée vers `art/`, avec nom versionné et
   entrée dans `art/ASSET_MANIFEST.md`.
6. Les `.import` appartiennent à la frontière Godot et ne remontent jamais
   dans le pipeline auteur.
7. Régénérer un asset ne modifie pas silencieusement la version publiée. Une
   nouvelle version est validée puis intégrée explicitement.
8. Une sortie ImageGen est toujours une candidate : grille, nombre de poses,
   pivot, alpha et continuité temporelle doivent être vérifiés.
9. Une spritesheet est un dérivé ; les frames normalisées sur canevas fixe,
   leur root, les sockets et les métadonnées en sont les autorités de livraison.
10. Les statuts `visual`, `temporal`, `technical` et `gameplay` sont indépendants.
    Un export techniquement valide peut rester visuellement ou temporellement
    refusé.

## Autorités

- original et recette de fabrication : `pipeline/assets/` ;
- bitmap livré au jeu : `art/` ;
- réglages gameplay et assemblage : Resource et scène Godot ;
- état d'intégration et provenance : `art/ASSET_MANIFEST.md`.
