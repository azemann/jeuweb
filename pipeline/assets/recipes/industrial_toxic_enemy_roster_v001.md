# Recette — roster ennemi industriel toxique v001

## Intention

Fermer une première tranche jouable avec quatre rôles immédiatement lisibles :
Grunt terrestre, Drone volant, Boss lourd et pilote Saboteur. Les illustrations
isolées du megapack sont les sources visuelles ; Godot possède les règles de
gameplay et les scènes canoniques.

## Génération et sélection

- outil créatif d'origine : ImageGen intégré à Codex ;
- références : planches de direction artistique 01, 03 et 04 ;
- sources retenues : Siphoner, Scout Drone, Brute et Hatchling Saboteur ;
- les quatre planches finales utilisent une grille stricte 4×4 sur fond cyan
  uniforme destiné à l'extraction déterministe ;
- chaque ligne porte respectivement mouvement, attaque, impact et mort ;
- les quatre rôles conservent proportions, palette et identité de leur source.

Structure commune des prompts finaux : transformer la référence en planche
stricte 4×4 de profil droit, avec quatre phases de mouvement, quatre phases de
l'attaque propre au rôle, quatre réactions d'impact et quatre poses de mort ;
root stable, identité conservée, cellules séparées, fond `#00FFFF`, sans texte,
grille, décor, ombre ni fragment traversant les cellules.

Variantes de rôle :

- Grunt/Siphoner : marche mécanique puis décharge toxique par la trompe ;
- Drone : vol stationnaire/déplacement puis tir énergétique frontal ;
- Boss/Brute : avance lourde puis blast magenta par la trompe ;
- Pilote/Saboteur : sprint puis charge suicide au sac-détonateur.

## Normalisation déterministe

```bash
python3 pipeline/assets/tools/process_industrial_toxic_enemy_roster.py
```

Le processeur extrait le fond cyan, retire les fragments de cellules voisines,
normalise les 64 poses sur leurs canevas/root auteurs et produit atlas, revues
sur damier, aperçus animés et QA sous `pipeline/assets/working/`. Le damier
n'entre jamais dans les PNG runtime.

## Statut attendu

Les quatre atlas sont approuvés pour publication. Chaque `SpriteFrames` Godot
porte quatre poses `walk`, `attack`, `hit` et `death`, soit 64 poses runtime.
