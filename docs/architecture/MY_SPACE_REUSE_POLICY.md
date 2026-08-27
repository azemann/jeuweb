# Utilisation de `my-space`

`my-space` est une bibliothèque de recettes pour l'ensemble de ce jeu, pas une
dépendance monolithique à recopier.

Pour chaque nouveau système :

1. rechercher les projets ayant déjà résolu une partie du problème ;
2. extraire l'autorité, le contrat auteur, les correspondances Godot et les
   validations utiles ;
3. adapter les responsabilités au run-and-gun ;
4. copier du code uniquement lorsqu'il reste générique et sans dépendance au
   jeu source ;
5. conserver dans ce dépôt ses propres Resources, scènes et réglages.

Premières filiations retenues :

- `rpg-01` : scènes maîtresses de cartes, identités stables, marqueurs et
  validation structurelle ;
- `worms-revisite` : masque raster destructible, collisions par chunks,
  explosions et outils d'Inspector ;
- `serre-mecanique` : séparation pipeline générique / profil de jeu et calques
  `TileMapLayer` inspectables ;
- `horde-brawler` : Resources agrégatrices, aperçu éditeur et progression
  reproductible lorsque des segments procéduraux seront nécessaires.
- `fighter-sprites-2d` : canevas fixe, root préservé, frames individuelles et
  séparation identité/mouvement/gameplay/rendu ;
- `horde-brawler` : profil de production raster, corps et arme séparés, sockets
  et statuts visual/temporal/technical/gameplay ;
- `serre-mecanique` : extraction alpha déterministe, normalisation des frames
  et contrôle d'import Godot ;
- protocoles et contrats transversaux MySpace : cycle de vie
  planned/candidate/validated/integrated, provenance et empreintes.

Les choix propres à un autre jeu ne deviennent jamais automatiquement des
valeurs par défaut ici.
