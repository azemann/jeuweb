# Contrat auteur des entrées joueur

Le système d'entrée prend en charge clavier, souris, manette et écran tactile
sans dupliquer les règles de gameplay. Tous les périphériques rejoignent les
mêmes actions abstraites avant d'atteindre les composants du joueur.

## Autorités

- correspondance périphérique → action : `Project Settings > Input Map`,
  sérialisé dans `project.godot` ;
- règles de visée classique et pointeur : `PlayerAimProfile.tres` ;
- interprétation runtime de la direction : `PlayerAimComponent` ;
- disposition et apparence des commandes tactiles :
  `ui/mobile/mobile_controls.tscn` ;
- activation tactile runtime : disponibilité d'un écran tactile signalée par
  `DisplayServer`, avec `Show On Desktop` comme prévisualisation auteur ;
- mouvement, saut et tir restent respectivement sous l'autorité des composants
  Movement et Weapon : l'UI tactile n'implémente aucun gameplay.

Une liaison physique ne doit pas être recopiée dans un composant ou une scène
de gameplay. Un `TouchScreenButton` référence une action de l'Input Map, jamais
une méthode du joueur.

## Correspondance canonique

| Intention | Clavier / souris | Manette | Téléphone |
|---|---|---|---|
| déplacement | Q/A, D, flèches gauche/droite | stick gauche X, croix gauche/droite | boutons gauche/droite |
| saut | Espace | A | bouton SAUT |
| visée classique verticale | Z/W, S, flèches haut/bas | stick gauche Y, croix haut/bas | boutons haut/bas |
| visée libre | position de la souris | stick droit | — |
| tir automatique | J, X, clic gauche | X, RB, gâchette droite | bouton TIR |
| interaction | F | Y | bouton INTERAGIR |

Le stick gauche conserve la visée arcade classique : son axe horizontal
déplace et fixe l'orientation, son axe vertical vise. Le stick droit et la
souris ajoutent une visée indépendante sans modifier cette règle.

## Points d'édition dans Godot

1. Modifier les touches, boutons et axes dans `Project > Project Settings >
   Input Map`.
2. Modifier deadzone et activation de la souris dans la Resource
   `characters/player/data/classic_aim.tres` depuis l'Inspector.
3. Modifier taille, marge et prévisualisation des commandes téléphone sur le
   Node `MobileControls` de l'écran de mission.
4. Modifier la composition tactile dans sa scène canonique, en conservant un
   `TouchScreenButton` par action et un Node visuel séparé qui ignore la souris.

Les contrôles téléphone utilisent des primitives Godot et le Theme du projet ;
ils ne créent aucun bitmap ni pipeline artistique parallèle.

## Contrat runtime

- `InputMap` fusionne clavier, souris, manette et actions produites par les
  `TouchScreenButton` ;
- Movement consomme uniquement mouvement et saut ;
- Weapon consomme uniquement `player_fire` ;
- Interaction consomme uniquement `player_interact` ;
- Aim consomme la visée classique et le stick droit ;
- un mouvement de souris active la visée pointeur ; une entrée clavier,
  manette ou tactile rend l'autorité à la visée arcade ;
- la scène tactile est visible automatiquement sur écran tactile et reste
  présente, inspectable et prévisualisable dans le SceneTree ;
- le projet mobile est explicitement orienté en paysage ;
- aucun Autoload n'est requis.

## Contrat de validation

`player_input_contract_test.gd` protège :

- les neuf actions canoniques ;
- la présence des familles d'événements clavier, souris et manette ;
- les axes et boutons principaux de la manette ;
- les sept `TouchScreenButton` et leur correspondance d'action ;
- l'intégration de `MobileControls` à l'écran de mission ;
- la commande de visée vers une position globale.

`player_contract_test.gd` continue de protéger le résultat fonctionnel : spawn,
déplacement, saut, visée, arme et HUD.
