# Industrial Toxic Boot & Start Flow v001 — recette

## But

Fournir des sources visuelles modulaires pour les états suivants : splash,
transition/loading, écran titre, menu principal et sélection de mission.

## Direction et prompts

Le prompt set complet est conservé dans
`projets/jeuweb-boot-start-flow-assets-v001/PROMPTS.md`. ImageGen a utilisé la
planche `da-01-master-board.png` comme référence de style uniquement.

- rendu : illustration 2D comics peinte ;
- palette : olive, fer sombre, laiton, magenta et lime toxique ;
- fonds : 16:9, sans texte ni UI pré-peinte ;
- éléments composables : véritables PNG avec alpha ;
- marqueurs et ornements : planches strictes `3x2` à découper ;
- typographie : toujours rendue par Godot, jamais incluse dans le raster.

## Publication

Le processeur `process_boot_start_flow.py` préserve les quatre backgrounds,
normalise les trois éléments transparents autonomes, découpe les deux planches
3 × 2 et publie dix-neuf livrables sous
`art/ui/flows/industrial_toxic/`. Les cadres sont affichés avec conservation de
leur ratio : ils ne sont pas traités comme des NinePatch arbitrairement
extensibles. Godot compose tous les textes et états de focus par-dessus.
