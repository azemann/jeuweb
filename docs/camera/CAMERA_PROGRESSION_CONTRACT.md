# Contrat de caméra de progression

La caméra appartient à la mission, pas au joueur. Une seule Camera2D est active
au runtime dans l'écran de jeu.

## Autorités

- comportement et réglages arcade : `RunAndGunCameraProfile.tres` ;
- limites spatiales : `MissionMapRoot2D.camera_bounds` ;
- cible runtime : joueur produit par `MissionActorSpawner2D` ;
- progression maximale atteinte : `MissionCameraRig2D` ;
- vitesses relatives du décor : chaque `Parallax2D` de la scène maîtresse.

## Arbre runtime visible

```text
MissionViewport
├── MapHost
├── ActorSpawner
└── MissionCameraRig
    └── Camera2D
```

La `PreviewCamera` d'une carte doit rester désactivée. Le joueur ne possède pas
de Camera2D concurrente.

## Comportement run-and-gun

- la caméra reste centrée sur l'écran au début de la carte ;
- elle commence à avancer lorsque joueur + look-ahead dépasse ce centre ;
- elle avance vers la droite avec le joueur ;
- elle ne recule plus après qu'une portion du niveau a été révélée ;
- elle reste bornée par `camera_bounds` ;
- fond lointain, plan intermédiaire et premier plan utilisent des vitesses de
  parallaxe distinctes.

## Validation

`mission_camera_progression_test.gd` vérifie l'unicité de la caméra runtime,
la cible joueur, l'avance, le verrouillage arrière, la PreviewCamera inactive
et la présence de la parallaxe lointaine.

