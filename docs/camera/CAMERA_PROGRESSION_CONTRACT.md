# Contrat de caméra de progression

La caméra appartient à la mission, pas au joueur. Une seule Camera2D est active
au runtime dans l'écran de jeu.

## Autorités

- comportement et réglages arcade : `RunAndGunCameraProfile.tres` ;
- limites spatiales : `MissionMapRoot2D.camera_bounds` ;
- cible runtime : joueur produit par `MissionActorSpawner2D` ;
- centre horizontal courant : `MissionCameraRig2D` ;
- bornes et fréquence des secousses : `RunAndGunCameraProfile.tres` ;
- intensité et durée demandées par un tir : `WeaponData.tres` ;
- backgrounds segmentés : `Visual/SegmentBackgrounds` de la scène maîtresse.

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
- elle commence à avancer lorsque le joueur dépasse ce centre ;
- elle suit librement le joueur vers la droite comme vers la gauche ;
- le profil de la Côte toxique conserve un look-ahead nul : changer de direction
  sans déplacement du joueur ne déplace jamais la caméra ;
- d'autres profils peuvent activer explicitement un look-ahead directionnel ;
- elle reste bornée par `camera_bounds` ;
- les secousses utilisent uniquement `Camera2D.offset` et ne modifient jamais
  la position du Rig ;
- le canon automatique courant demande une amplitude nulle ; une secousse reste
  une commande optionnelle réservée aux événements lourds ;
- les backgrounds restent bornés par les segments de la scène maîtresse.

## Validation

`mission_camera_progression_test.gd` vérifie l'unicité de la caméra runtime,
la cible joueur, l'avance, le retour arrière, l'absence de mouvement au demi-tour,
la PreviewCamera inactive et les backgrounds segmentés.
`weapon_projectile_integration_test.gd` vérifie qu'un vrai tir automatique
conserve un offset nul. Le contrat caméra vérifie séparément qu'une demande
lourde explicite déplace puis restaure l'offset sans déplacer le Rig.
