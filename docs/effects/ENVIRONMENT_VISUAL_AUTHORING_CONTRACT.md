# Contrat auteur des atmosphères environnementales 2D

Les effets environnementaux enrichissent la profondeur et le mouvement d'une
mission sans devenir une autorité gameplay. Ils ne possèdent ni collision, ni
dégâts, ni commande caméra.

## Autorités

- les bitmaps publiés sous `art/` possèdent leur rendu raster ;
- la scène maîtresse possède le placement, l'emprise et les origines des effets ;
- `EnvironmentFXProfile.tres` possède activation, quantité, couleur et intervalle ;
- `EnvironmentFX2D.tscn` possède les Nodes natifs, matériaux de particules et
  l'animation temporelle d'un éclair ;
- le `Timer` d'une instance possède uniquement l'attente runtime courante.

Une même position ne doit pas être copiée dans un profil. L'auteur place
`EnvironmentFX2D` sous `Visual/EnvironmentFX`, puis modifie `Smoke Origin`,
`Fog Origin`, `Sparks Origin` et `Lightning Origin` dans l'Inspector.

## Scène canonique

```text
EnvironmentFX2D
├── Smoke                 GPUParticles2D
├── ToxicFog              GPUParticles2D
├── Sparks                GPUParticles2D
├── Lightning
│   ├── Flash             Polygon2D
│   ├── BoltPrimary       Line2D
│   └── BoltSecondary     Line2D
├── LightningTimer        Timer
└── AnimationPlayer
```

`AnimationPlayer` est l'autorité de la frappe brève. Le script ne construit
aucune animation et se limite à appliquer le profil puis à programmer la
prochaine frappe dans l'intervalle auteur.

## Profondeur de Toxic Coast

```text
SegmentBackgrounds       identité lointaine propre à chaque acte
MidgroundParallax        décor transparent historique, lent et atténué
EnvironmentFX            atmosphère segmentée
Gameplay                 terrain, acteurs et interactions
ForegroundParallax       cadre transparent proche et légèrement plus rapide
```

Les deux parallaxes répètent uniquement un vocabulaire décoratif commun à la
côte. Ils ne remplacent jamais les trois panoramas 2560 × 720, qui restent
l'autorité de l'identité et des transitions de chaque acte.

Le parallaxe et les effets suivent le déplacement réel du viewport. Ils ne
lisent jamais la direction de visée du joueur et ne peuvent donc pas déplacer
la caméra lors d'un demi-tour.

## Workflow auteur

1. créer ou choisir un `EnvironmentFXProfile.tres` ;
2. instancier `environment_fx_2d.tscn` sous `Visual/EnvironmentFX` ;
3. placer l'instance au début du segment ;
4. régler les quatre origines et l'emprise depuis l'Inspector ;
5. utiliser `Prévisualiser l'éclair` lorsque le profil l'active ;
6. vérifier les avertissements de configuration et le contraste en jeu.

## Validation

`environment_fx_contract_test.gd` vérifie les profils, les trois instances de
Toxic Coast, les deux parallaxes et l'application runtime des réglages.
`map_contract_test.gd` protège simultanément l'identité segmentée des
backgrounds et l'existence des couches décoratives.
