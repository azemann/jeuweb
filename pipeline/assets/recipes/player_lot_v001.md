# Recette joueur — lot v001

## Filiations MySpace

- `fighter-sprites-2d` : frames séparées, canevas fixe, root préservé, planche
  et atlas comme dérivés ;
- `horde-brawler` : corps et arme séparés, sockets requis, quatre statuts de
  validation ;
- `serre-mecanique` : détection des composantes alpha avant normalisation,
  contrôle automatisé du format runtime ;
- protocoles génériques : statut candidate/validated/integrated, provenance et
  séparation producteur-consommateur.

## Représentation

```text
renderRepresentation: raster-2d
gameplaySpace: 2d-canvas
animationRepresentation: sprite-frames + transform-tracks
engineOwnsMovement: true
weaponSeparateFromBody: true
```

## Sources ImageGen

### Corps

Planche 4 × 3 du commando canonique, toujours orienté vers la droite, sans
arme, mains en posture de prise stable. Poses : idle, walk contact, walk
passing, run extension, jump rise, jump apex, fall, landing, crouch, aim up,
recoil et hurt. Fond alpha natif, aucun texte, effet ou ombre.

### Arme

Canon de campagne isolé en vue latérale droite : métal olive et anthracite,
chargeur tambour, ligatures magenta, indicateur vert acide. Aucun personnage,
effet, projectile ou ombre.

Références : `da-01-master-board.png`, `da-02-characters.png` et la première
candidate corps pour l'échelle de rendu de l'arme.

Génération : outil imagegen intégré. Les deux sorties sont des candidates.

## Normalisation

```bash
python3 pipeline/assets/tools/process_player_candidates.py
```

Le processeur détecte les 12 composantes alpha, applique une échelle commune,
les aligne sur un root estimé, produit des frames 192 × 192, un atlas 4 × 3,
un canon normalisé et une feuille de revue. Il ne publie rien sous `art/`.

