# Jeuweb — Boot & Start Flow Assets v001

Lot de neuf sources candidates pour composer le démarrage de `jeuweb` sans
imposer une implémentation d'interface.

## Contenu

- `sources/boot/backgrounds/` : splash d'ouverture et transition/loading ;
- `sources/start/backgrounds/` : écran titre et carte de sélection de mission ;
- `sources/shared/branding/` : emblème sans texte ;
- `sources/shared/frames/` : plaque de titre vierge et cadre de menu ;
- `sources/shared/sheets/` : ornements de navigation et marqueurs de mission ;
- `review/` : planche de contact pour validation humaine.

## Pourquoi ces assets

Les arrière-plans portent l'ambiance et la narration. Les cadres, marqueurs et
ornements restent séparés pour que Godot puisse gérer le texte, les états de
focus, l'accessibilité, l'animation et les différentes résolutions. Aucun texte
n'est peint dans les images : le contenu pourra donc être localisé sans refaire
les illustrations.

Toutes les images sont des candidates. Elles ne sont ni intégrées dans une scène,
ni publiées dans `art/`.

