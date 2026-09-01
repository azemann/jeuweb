# Abyssal Ground Kit v001

## Intention

Publier les premières pièces de sol de Mission 2 depuis le pack source
`jeuweb-abyssal-asset-pack-v001`, sans considérer les PNG sources comme assets
runtime définitifs.

## Sources

Sources locales copiées dans :
`pipeline/assets/sources/terrain_kits/abyssal/`.

Origine externe lue en entrée, non modifiée :
`/home/evan/Dev/Dev-github/my-space/projets/jeuweb-abyssal-asset-pack-v001`,
branche `agent/ajoute-serre-mecanique`, commit `e2b81a5`.

## Traitement

`pipeline/assets/tools/process_abyssal_ground_kit.py` :

- nettoie l'alpha faible ;
- extrait la silhouette par alpha ;
- normalise chaque pièce sur canevas transparent 768 x 384 ;
- dérive un raccord incliné depuis la plateforme de corail noir ;
- écrit les exports et copies runtime publiées.

## Livraison

Les fichiers publiés sont copiés sous `art/terrain/pieces/abyssal/` et
référencés uniquement par `GroundPieceDefinition.tres`.

Statut visuel : candidat intégré v001. Les contours auteur et pivots sont prêts
pour blockout, mais devront être ajustés après essai dans l'éditeur.

## Lot v002

Le même processeur publie aussi `abyssal-ground-kit-v002`, destiné au premier
vrai travail de level design Mission 2. Il ajoute seize sorties : plateformes
small/large, caps gauche/droite, pentes up/down, steps low/high, ponts
short/long, pilier de support, arche traversable, colonnes intacte/brisée et
murs nacrés small/large.

Ces pièces restent des livrables runtime versionnés sous
`art/terrain/pieces/abyssal/v002/`. Les réglages de gameplay et collisions
restent dans les `GroundPieceDefinition`, pas dans le script de pipeline.
