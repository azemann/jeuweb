# Mapping des rôles ennemis — Industrial Toxic Megapack v001

Ce document est une proposition de migration gameplay. Les noms de fichiers
ImageGen restent descriptifs et ne constituent pas les identifiants Godot.

| Source megapack | Rôle gameplay canonique | Identifiant cible | État |
|---|---|---|---|
| `enemies/vacuum-siphoner-source-v001.png` | Grunt | `vacuum_grunt` | à normaliser |
| `enemies/vacuum-scout-drone-source-v001.png` | Flying enemy | `vacuum_flying` | à normaliser |
| `enemies/vacuum-brute-source-v001.png` | Boss | `vacuum_boss` | à normaliser |
| `enemies/alien-hatchling-saboteur-source-v001.png` | Pilote éjecté / Saboteur | `vacuum_pilot_saboteur` | à normaliser |

## Compatibilité avec l'existant

`vacuum_trooper` reste temporairement un identifiant legacy pour la scène
actuelle et ses animations déjà publiées. Il ne doit pas être renommé en
`vacuum_grunt` tant que le Siphoner n'a pas reçu sa scène canonique, son profil,
sa collision et son comportement de Grunt.

Les anciens identifiants `vacuum_brute` et `vacuum_siphoner` restent lisibles
pendant la migration. Une fois les nouvelles scènes intégrées, ils pourront
devenir des alias de compatibilité ou être retirés après validation de toutes
les cartes et tests.

## Lifecycle futur du pilote

`vacuum_boss` expose un événement d'éjection à la fin de `death`. Le système
instancie alors `vacuum_pilot_saboteur` dans `Actors`, avec son propre profil,
sa propre Hurtbox et son comportement. L'animation actuelle d'éjection reste
une présentation visuelle tant que cette scène n'est pas publiée.

## Autorité et validation

- rôle gameplay : `EnemyArchetypeProfile` ;
- correspondance identifiant → scène : `EnemyCatalog` ;
- identité visuelle : sources et exports dans `pipeline/assets/` puis `art/` ;
- placement : `MapEncounterMarker2D` dans chaque scène de mission ;
- validation : profil valide, scène instanciable, catalogue résolu et test
  runtime de la rencontre.
