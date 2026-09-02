# Contrat transversal — pieds, surfaces marchables et ombres projetées

Ce contrat s'applique à toutes les futures maps, pièces, scènes d'objet
physique, scènes joueur et scènes ennemies. Un acteur ne simule jamais son
contact au sol par un décalage visuel propre à une map.

## Autorités

- root des pieds : `GroundAnchor` dans la scène canonique de l'acteur ;
- volume physique : `CollisionShape2D` de son `CharacterBody2D`, dont le point
  bas correspond au root ;
- contact courant : résultat physique du `CharacterBody2D` et `GroundProbe` ;
- ombre : `ActorGroundingComponent`, projetée sur le collider World rencontré ;
- Permanent et Breakable : `GroundPieceDefinition.authored_outline` ;
- portion marchable du même contour : ses premiers points, désignés par
  `walk_surface_point_count` sans créer une seconde géométrie ;
- Carvable : masque alpha runtime et collisions de chunks reconstruites.

Le PNG reste l'autorité visuelle. Le contour auteur est l'autorité physique des
modes non destructibles par cratère ; le validateur contrôle leur cohérence sans
imposer une forme créative.

## Scène d'acteur obligatoire

```text
CharacterBody2D
├── CollisionShape2D
├── Components
│   └── Grounding (ActorGroundingComponent)
│       ├── GroundAnchor
│       ├── GroundProbe
│       ├── LeftFootProbe
│       ├── RightFootProbe
│       └── GroundShadow
│   └── SlopeAlignment
└── Visuals
    └── GroundPivot
```

`GroundShadow` n'appartient jamais à `Visuals` : une animation, un flip ou
un saut ne déplace pas artificiellement l'ombre. Le probe trouve le sol réel,
oriente l'ellipse selon sa normale et module taille et opacité selon la hauteur.
Il suit donc aussi les cratères Carvable sans code particulier.

Les sondes gauche et droite mesurent la tangente réelle sous la largeur des
appuis. `SlopeAlignment` incline uniquement `GroundPivot` autour du root des
pieds : collisions, arme, visée et logique restent inchangées. Chaque famille
d'acteur règle dans l'Inspector sa largeur d'appui, son ratio de suivi, son
angle maximal, sa zone morte et son lissage.

## Workflow des surfaces

Pour une pièce Permanent ou Breakable :

1. choisir `AUTHORED_OUTLINE` dans la définition ;
2. dessiner un contour fermé local, relatif au pivot publié ;
3. placer ses premiers points de gauche à droite sur le bord marchable ;
4. renseigner `Walk Surface Point Count` ;
5. inspecter le contour magenta et la surface verte dans la scène ou la map ;
6. transformer librement l'instance ; visuel et collision suivent ensemble.

Pour Carvable, l'aperçu auteur de ce contour est volontairement masqué et la
collision locale désactivée. Le masque runtime est la seule autorité après
chaque destruction. Une map qui contient au moins une pièce Carvable doit donc
laisser `Runtime/DestructibleTerrain.generate_on_ready` actif afin que le
joueur et les ennemis rencontrent immédiatement les collisions de chunks.

## Règles visuelles

- le sprite reste droit sur les pentes dans le langage run-and-gun actuel ;
- son root publié reste entre les appuis sur toutes les frames ;
- le bas de la collision et `GroundAnchor` partagent l'origine locale ;
- le point inférieur de la collision est central : capsule, cercle ou polygone
  convexe terminé sur le GroundAnchor ; une large boîte rectangulaire est
  interdite car son coin ferait flotter le root sur les pentes ;
- l'ombre reste au sol pendant le saut, se réduit et pâlit avec la distance ;
- aucun ovale d'ombre fixe ne reste sous `Visuals`.

## Validation

`grounding_walk_surface_contract_test.gd` protège le composant partagé, le
GroundAnchor, la projection sur un sol réel, sa persistance sous un acteur en
hauteur, l'absence des anciennes ombres attachées et la surface auteur de la
première pièce. Les tests Ground Piece continuent de protéger la séparation
Permanent/Breakable/Carvable.
