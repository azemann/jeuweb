# Recette Vacuum Trooper — attaque toxique v001

## Intention

Le lot candidat apporte le télégraphe complet de la première attaque :
détection, anticipation, charge, relâchement, phase active, recul, récupération
et retour prêt. Le projectile doit être émis à la pose `release`, jamais déduit
de la durée totale de l'animation.

## Génération et prompt final

- outil : ImageGen intégré à Codex ;
- références : marche, impact/mort et concept Vacuum Trooper déjà présents ;
- direction canonique : droite ;
- source corrigée : 1774 × 887, RGBA ;
- SHA-256 : `fa9ee236d7a4dae4f0af4d5ad9852ffd5f85099599228a01b8fe0cc4ae3db0f7`.

Prompt final enregistré : planche stricte 4 × 2 transparente du Vacuum Trooper
existant, orienté à droite, avec les huit phases `detect`, `windup`, `charge`,
`release`, `active`, `recoil`, `recover`, `ready`. Pieds et root stables,
identité laiton/olive/magenta/violet inchangée, action de la trompe lisible,
projection toxique verte, sans texte, bordure ni décor. Une passe d'édition a
retiré uniquement le faux damier RGB pour restituer un alpha réel.

## Normalisation déterministe

```bash
python3 pipeline/assets/tools/process_vacuum_trooper_attack_candidate.py
python3 pipeline/assets/tools/validate_vacuum_trooper_attack_candidate.py
```

Les limites de cellules sont explicites : X
`[0, 444, 887, 1331, 1774]`, Y `[0, 444, 887]`. Quatre fragments étrangers
franchissant les cellules sont supprimés avant la normalisation. Les huit poses
partagent le root publié `[128, 180]` dans une frame runtime 256 × 192.

## Statut

Le lot est `candidate` et `technical: passed`. Sa publication reste bloquée
jusqu'à validation visuelle et temporelle, notamment parce que la longue trompe
rend le personnage légèrement plus petit que dans la marche publiée.
