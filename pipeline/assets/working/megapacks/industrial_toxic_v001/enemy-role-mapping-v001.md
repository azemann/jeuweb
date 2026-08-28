# Mapping des rôles ennemis — Industrial Toxic Megapack v001

Ce document enregistre la correspondance gameplay publiée. Les noms de fichiers
ImageGen restent descriptifs et ne constituent pas les identifiants Godot.

| Source megapack | Rôle gameplay canonique | Identifiant cible | État |
|---|---|---|---|
| `enemies/vacuum-siphoner-source-v001.png` | Grunt | `vacuum_grunt` | publié et intégré |
| `enemies/vacuum-scout-drone-source-v001.png` | Flying enemy | `vacuum_flying` | publié et intégré |
| `enemies/vacuum-brute-source-v001.png` | Boss | `vacuum_boss` | publié et intégré |
| `enemies/alien-hatchling-saboteur-source-v001.png` | Pilote éjecté / Saboteur | `vacuum_pilot_saboteur` | publié et intégré |

## Compatibilité avec l'existant

`vacuum_trooper` reste un archétype distinct et compatible avec la scène déjà
publiée. `vacuum_grunt` désigne désormais exclusivement le Siphoner. Les noms de
sources `vacuum_brute` et `vacuum_siphoner` ne sont pas des identifiants runtime.

## Lifecycle du pilote

`vacuum_trooper` instancie `vacuum_pilot_saboteur` dans `Actors` après le délai
auteur du composant `Ejection`. Le pilote possède son profil, sa collision et
son attaque de contact autodestructrice. Le
`vacuum_boss` possède un lifecycle séparé et ne doit pas être déduit de cette
éjection.

## Autorité et validation

- rôle gameplay : `EnemyArchetypeProfile` ;
- correspondance identifiant → scène : `EnemyCatalog` ;
- identité visuelle : sources et exports dans `pipeline/assets/` puis `art/` ;
- placement : `MapEncounterMarker2D` dans chaque scène de mission ;
- validation : profil valide, scène instanciable, catalogue résolu et test
  runtime de la rencontre.
