# Recette — HUD Toxic Commando v001

## Source

Pack autonome `jeuweb-hud-asset-themes-v001`, thème `toxic_commando` :

- `hud-frames-source-v001.png` ;
- `gameplay-icons-source-v001.png` ;
- `controls-slots-source-v001.png`.

Les trois copies immuables vivent sous
`pipeline/assets/sources/ui/hud/toxic_commando_v001/`. La planche de contrôles
est conservée pour une future peau tactile mais ne produit aucun livrable dans
cette tranche.

## Transformation

```bash
python3 pipeline/assets/tools/process_toxic_commando_hud.py
```

L'outil découpe six cadres, normalise douze icônes sur 160 × 160 et dérive un
portrait 192 × 192 depuis la pose idle canonique du lot joueur. Il publie les
PNG sous `art/ui/hud/toxic_commando/` et génère manifeste, provenance et planche
de contrôle. Les exports sont des dérivés reproductibles et ne doivent pas être
édités manuellement.

## Intégration prévue

`MissionHUDTheme.tres` référence les cadres et icônes publiés. La scène
`MissionHUD.tscn` possède le layout ; les composants joueur restent les seules
autorités de la vie, de l'arme, des munitions, de l'armure et de l'Overdrive.
