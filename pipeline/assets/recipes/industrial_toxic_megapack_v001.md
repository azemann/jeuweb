# Industrial Toxic Megapack v001 — recette source

## Intention

Lot candidat pour élargir le vocabulaire visuel du run-and-gun 2D `jeuweb` :
terrain modulaire, accessoires interactifs, ennemis, pickups et quatre familles
d'armes avec projectile et impact.

La direction associe une base militaire tropicale extravagante à une industrie
toxique : métal olive, acier sombre, laiton usé, accents magenta et énergie lime.
Les silhouettes épaisses et les contours comics privilégient la lecture immédiate
en vue latérale.

## Recette de génération

- usage ImageGen : `stylized-concept` ;
- sujet isolé et centré, entièrement visible ;
- illustration 2D peinte, cohérente avec un run-and-gun comics ;
- vue latérale ou trois-quarts faible selon la fonction de l'objet ;
- contraste fort et contour sombre lisible à petite taille ;
- palette : olive militaire, fer sombre, laiton, magenta et lime toxique ;
- fond réellement transparent avec canal alpha ;
- sans texte, logo, watermark, décor environnant ni ombre portée extérieure ;
- pour les impacts : planche `3x2`, six phases séparées et non chevauchantes.

## Contenu

- 9 pièces de terrain : plateformes, murs, passerelles, tuyaux et dangers ;
- 9 props : ravitaillement, soin, couverture, mine, éclairage et décor technique ;
- 4 ennemis : brute, siphonneur, drone éclaireur et saboteur ;
- 4 pickups : santé, munitions, armure et surmultiplication ;
- 12 assets d'armes répartis en quatre triptyques arme/projectile/impact :
  acide, électrique, implosion et roquette.

## Traitements déjà effectués

1. génération des sources raster ;
2. extraction/correction du fond lorsque nécessaire ;
3. conservation des originaux candidats par catégorie ;
4. contrôle automatisé du canal alpha et des coins transparents ;
5. création d'une planche de contact pour revue humaine.

## Portes avant publication

Ce lot reste dans `pipeline/assets/` et ne doit pas être référencé au runtime.
Avant toute copie vers `art/`, chaque famille doit recevoir :

1. sélection visuelle humaine ;
2. dimensions runtime et densité de pixels normalisées ;
3. découpage des planches d'impacts et validation temporelle ;
4. pivot, socket de tir, collision ou hurtbox selon le type ;
5. test de lisibilité sur une vraie scène de gameplay ;
6. export final et publication via une recette dédiée.

