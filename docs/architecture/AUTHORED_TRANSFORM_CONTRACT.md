# Contrat transversal des transformations auteur

Dans une scène maîtresse Godot, la transformation de l'instance est l'autorité
du placement. L'auteur doit pouvoir utiliser les outils natifs de l'éditeur
sans connaître les limitations internes des systèmes consommateurs.

## Liberté auteur obligatoire

Toute nouvelle famille de pièces ou d'objets placés accepte par défaut :

- translation libre ;
- rotation libre ;
- échelle uniforme ou non uniforme ;
- miroir par échelle négative ;
- composition avec la transformation de ses parents.

Cette règle vaut pour la présentation, la collision, les masques, sockets,
zones d'effet, aperçus et données dérivées. Une définition partageable décrit
la forme locale ; l'instance de scène maîtresse décrit sa transformation finale.

Une échelle nulle reste invalide, car elle produit une transformation
mathématiquement non inversible et aucun objet exploitable.

## Contrat d'implémentation

Un consommateur ne recopie jamais `position`, `rotation` et `scale` dans des
champs parallèles. Il transforme les données locales avec les API natives :
`to_global()`, `to_local()`, `global_transform` ou leur équivalent 3D.

Pour une donnée raster dérivée, chaque pixel cible est ramené dans l'espace
local de la source par la transformation inverse. Visuel et collision utilisent
la même correspondance afin de rester alignés sous rotation, miroir et échelle
non uniforme.

Un drapeau tel que `supports_rotation` ne doit pas servir à cacher une lacune
technique. Une restriction de transformation n'est permise que si elle exprime
une règle créative ou gameplay réellement choisie et documentée dans
l'Inspector.

## Validation

Les tests de chaque nouvelle famille transformable vérifient au minimum une
rotation non nulle et une échelle non uniforme. Lorsqu'elle produit une donnée
physique ou raster, le test contrôle ensemble représentation et collision.

Une transformation auteur légale ne doit jamais invalider toute une carte ni
produire un écran vide. Les validations signalent les données réellement
manquantes ou les transformations dégénérées, pas les limites du code.
