# Côte toxique — plan auteur v001

La scène maîtresse `toxic_coast.tscn` est l'autorité du placement. La Resource
`toxic_coast.tres` est l'autorité de la longueur totale : 3840 × 720 px.

| Segment | Intervalle | Rôle | Repères de gameplay |
|---|---:|---|---|
| `landing_zone` | 0–1280 | Introduction | spawn joueur, patrouille, premier cratère, bassin toxique |
| `acid_bridge` | 1280–2560 | Escalade | brute, colonne de siphonneurs, pont destructible |
| `vacuum_foundry` | 2560–3840 | Climax | checkpoint, garde lourde, ruissellement, sortie de mission |

## Correspondances Godot

- découpage et intention : `Gameplay/Segments/MapSegment2D` ;
- placement : marqueurs et géométries dans la scène maîtresse ;
- définition des dimensions : `MissionMapDefinition` ;
- sol modifiable : `Area2D` sous `DestructibleZones` puis masque runtime ;
- structure permanente : `StaticBody2D/CollisionPolygon2D` ;
- profondeur visuelle : trois `Parallax2D` répétés tous les 1920 px ;
- validation : `MissionMapRoot2D.validation_errors()` et `map_contract_test.gd`.

## Limite visuelle assumée

Les panoramas v001 couvrent 1920 px et sont répétés, sans redimensionnement,
pour rendre immédiatement jouable toute la progression. La prochaine passe
d'assets devra produire des modules spécifiques au pont et à la fonderie ; ils
seront publiés depuis `pipeline/` vers `art/` puis assemblés dans la scène.
