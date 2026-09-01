# Côte toxique — plan auteur v001

La scène maîtresse `toxic_coast.tscn` est l'autorité du placement. La Resource
`toxic_coast.tres` est l'autorité de la longueur totale : 7680 × 720 px.

| Segment | Intervalle | Rôle | Repères de gameplay |
|---|---:|---|---|
| `landing_zone` | 0–2560 | Introduction | Tour, arche, soin, arme acide ; Pressure : 2 Troopers ; Release : 1 Grunt |
| `acid_bridge` | 2560–5120 | Escalade | Culées, mine, évent, ravitaillement, arme électrique ; Gauntlet de six ennemis |
| `vacuum_foundry` | 5120–7680 | Climax | Plateformes, armure, implosion, démolition, mur Breakable, Overdrive et Boss |

## Correspondances Godot

- découpage et intention : `Gameplay/Segments/MapSegment2D` ;
- placement : marqueurs et géométries dans la scène maîtresse ;
- définition des dimensions : `MissionMapDefinition` ;
- sol modifiable : `Area2D` sous `DestructibleZones` puis masque runtime ;
- structure permanente : `StaticBody2D/CollisionPolygon2D` ;
- identité visuelle : trois `Sprite2D` 2560 × 720 sous
  `Visual/SegmentBackgrounds`, centrés sur leurs segments ;
- profondeur commune : `MidgroundParallax` lent et `ForegroundParallax` proche,
  tous deux transparents et sans autorité gameplay ;
- atmosphère : trois `EnvironmentFX2D` profilés sous `Visual/EnvironmentFX`,
  avec placement final dans la scène maîtresse ;
- validation : `MissionMapRoot2D.validation_errors()` et `map_contract_test.gd`.
- cadence : `EncounterData → WaveData → EnemySpawnPatternData` sous
  `maps/encounters/data/toxic_coast/` ;
- progression : mode Flux Libre sans Combat Gate, caméra réversible et Boss
  final seul obligatoire pour valider la sortie.

## Composition kit-first

L'ancien fond opaque v001 reste retiré au profit des trois backgrounds v002.
Son midground transparent et le foreground transparent v002 sont réemployés
comme couches décoratives communes, sans remplacer l'identité des actes. La
géométrie proche est désormais composée avec le `GroundKitCatalog` : tour,
arche, culées, plateformes, barricades et mur destructible. Les 27 sorties
inédites du lot d'expansion sont publiées depuis `pipeline/` et consommées par
des Resources et scènes canoniques ; les 11 doublons restent exclus.
