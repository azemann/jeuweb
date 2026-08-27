# Recette Vacuum Trooper — impacts et mort v001

## Intention

Le lot candidat contient quatre poses d'impact/récupération puis quatre poses
de mort comique non sanglante. La coque s'ouvre et le petit pilote est éjecté.
L'identité olive, laiton, magenta et violet reste celle du Vacuum Trooper.

## Source et génération

- outil : ImageGen intégré ;
- source : `vacuum-trooper-hit-death-sheet-candidate-v001.png` ;
- source contrôlée : 2079 × 756, RGBA ;
- SHA-256 : `336b73c59be18335a713aa9a331662f8a4774b8d64ff6020b7d7e5109c5ecde1`.

Le propriétaire du projet décrit le prompt final comme une planche 4 × 2
stricte, transparente, orientée à droite, avec root au sol stable, mort comique
non sanglante et fidélité à trois références existantes. La seconde passe a
uniquement remplacé le faux damier par une transparence réelle. Cette
description est enregistrée comme résumé, pas comme citation textuelle du
prompt complet.

## Reconstruction déterministe

La largeur de 2079 px n'est pas divisible par quatre. Les limites de colonnes
sont donc explicitement `[0, 520, 1040, 1560, 2079]`.

La fumée de l'ouverture et le haut du pilote éjecté franchissent la séparation
des rangées. Les poses supérieures finissent avant `y=330` ; le processeur
récupère donc la bande source `y=330..378` pour les frames concernées. Aucun
pixel n'est inventé, repeint ou généré pendant cette opération.

## Normalisation

```bash
python3 pipeline/assets/tools/process_vacuum_trooper_hit_death_candidate.py
python3 pipeline/assets/tools/validate_vacuum_trooper_hit_death_candidate.py
```

Le root est celui déjà publié pour la marche : `[256, 360]` sur le canevas
canonique 512 × 384, puis `[128, 180]` sur les frames runtime 256 × 192. Les
huit poses utilisent une échelle commune. Deux prévisualisations séparées
permettent de juger l'impact et la mort sans confondre leurs timings.

## Publication

Le propriétaire du projet a validé visuellement et temporellement le lot le
2026-08-27. L'atlas est publié sous `art/characters/enemies/vacuum_trooper/`,
référencé par le `SpriteFrames` canonique et relié aux signaux de Health. La
suppression de l'instance intervient après la fin de `death`.
