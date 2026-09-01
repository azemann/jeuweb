# Contrat auteur du joueur

Le joueur est une scène canonique composée. La scène contient commande d'arme
et inventaire de combat, mais définition, projectile, impact et orchestration de
mission restent des scènes et Resources séparées.

## Autorités

- déplacement : `PlayerMovementProfile.tres` ;
- règles de visée : `PlayerAimProfile.tres` ;
- maximum de vie et invulnérabilité : `PlayerHealthProfile.tres` ;
- capacités de munitions spéciales, armure et Overdrive :
  `PlayerCombatInventoryProfile.tres` ;
- arsenal autorisé, arme primaire, armes spéciales et arme de départ :
  `PlayerLoadoutProfile.tres` ;
- arme équipée runtime : `PlayerLoadoutComponent` ;
- définition de chaque arme : `WeaponData.tres` ;
- intensité du recul corporel et de la secousse par arme : `WeaponData.tres` ;
- action d'interaction : Input Map ; sélection de cible : composant Interaction ;
- état runtime correspondant : composant Movement, Aim, Health ou Weapon ;
- collision, présentation et assemblage : `PlayerCharacter2D.tscn` ;
- timings du flash de dégâts et de la disparition de mort : `AnimationPlayer`
  dans `PlayerCharacter2D.tscn` ;
- placement : `MapSpawnPoint2D` dans la scène maîtresse de carte ;
- correspondance carte → joueur : `MissionActorSpawner2D` ;
- correspondance périphériques → actions : Input Map de `project.godot` ;
- règles et UI d'entrée : `docs/input/PLAYER_INPUT_AUTHORING_CONTRACT.md` ;
- la caméra de mission est extérieure au joueur et suit son propre contrat.

Aucune vitesse, vie ou position de spawn ne doit être recopiée dans un autre
script.

## Arbre canonique

```text
PlayerCharacter2D (CharacterBody2D)
├── CollisionShape2D
├── Hurtbox
├── Components
│   ├── Movement
│   ├── Aim
│   ├── Health
│   ├── CombatInventory
│   ├── Loadout
│   ├── Weapon
│   │   └── FireCooldown
│   ├── Animation
│   ├── Recoil
│   │   └── RecoilAnimationPlayer
│   ├── Interaction
│   │   └── InteractionArea
│   ├── Grounding
│       ├── GroundAnchor
│       ├── GroundProbe
│       ├── LeftFootProbe
│       ├── RightFootProbe
│       └── GroundShadow
│   └── SlopeAlignment
├── Visuals
│   ├── GroundPivot
│   │   └── BodySprite
│   └── AimPivot
│       ├── Muzzle
│       │   └── MuzzleFlash
│       └── WeaponFeedback
├── AnimationPlayer
└── InteractionPrompt
```

## Définition / instance / présentation

```text
PROFILES .tres
      ↓
COMPONENTS RUNTIME
      ↓
VISUALS + AnimationPlayer
```

La présentation consomme `player_visual_frames.tres` et un canon séparé dans
`AimPivot`. La scène maîtresse possède l'ajustement final de position et
d'échelle du canon ; la métadonnée source permet d'en dériver `Muzzle`. Les
textures publiées peuvent évoluer sans modifier les composants
ni les profils gameplay. Les poses clés v001 sont validées visuellement ; leur
continuité temporelle reste une donnée provisoire.

## Contrat runtime

- Movement est seul propriétaire de la vélocité de locomotion ;
- Aim est seul propriétaire de `aim_direction` et `facing` ;
- Aim accepte la visée arcade, le stick droit et la position du pointeur sans
  transférer cette autorité à l'UI ;
- Health est seul propriétaire de `current_health` ;
- CombatInventory est seul propriétaire de `special_ammo`, `armor` et
  `overdrive_remaining` ; l'armure absorbe avant que Health reçoive le reliquat ;
- Loadout est seul propriétaire de `equipped_weapon` et refuse toute arme
  absente de son `PlayerLoadoutProfile` ;
- Weapon consomme l'arme équipée, possède uniquement la cadence runtime et émet
  `projectile_requested` sans connaître la carte ;
- Recoil consomme `Weapon.fired`, applique la direction opposée aux pivots du
  corps et du canon, tandis que son AnimationPlayer possède la courbe temporelle ;
- Interaction détecte uniquement les `Area2D` du groupe
  `interaction_targets`, choisit la plus proche et appelle son contrat public
  `can_interact()` / `interact()` sans connaître la caisse ni son contenu ;
- `PlayerCharacter2D` expose uniquement la composition et des commandes
  intentionnelles comme `apply_damage()` ;
- le HUD observe le signal `health_changed` ;
- Animation choisit les animations de locomotion selon l'état du
  CharacterBody2D ; Aim possède le retournement horizontal et la rotation de
  l'arme.
- un dégât accepté place le joueur en `HURT`, affiche la pose `hurt` et joue
  `damage` dans l'AnimationPlayer ; la fin de cette animation rend l'autorité à
  l'état de locomotion courant ;
- à zéro PV, `DEAD` remplace immédiatement `HURT` et joue `death` jusqu'au
  remplacement de l'instance par `MissionActorSpawner2D` ; aucune pose de mort
  raster distincte n'est déclarée tant qu'un atlas validé n'est pas publié.
- Grounding projette l'ombre sur le collider World réel et conserve le
  GroundAnchor à l'origine commune des pieds et du CharacterBody2D.

## Contrat de validation

`player_contract_test.gd` vérifie scène, profils, composants, Input Map,
AnimationPlayer, Muzzle, spawn dans `Runtime/Actors/RuntimePlayer`, collision avec la
carte, déplacement, saut et correspondance Health → HUD.
`player_input_contract_test.gd` vérifie les correspondances clavier, souris,
manette et téléphone ainsi que la scène tactile canonique.
`pickup_interaction_contract_test.gd` protège la sélection de cible,
l'ouverture de caisse, l'apparition du pickup et l'appel autoritaire à Health.
`player_feedback_contract_test.gd` protège la pose Hurt, les animations Damage
et Death, la sortie automatique de Hurt et la disparition avant respawn.
`weapon_projectile_integration_test.gd` protège la cadence, le spawn au Muzzle,
la direction de visée, l'indépendance du projectile, l'impact physique, le
recul directionnel et la stabilité caméra du canon automatique.
`industrial_toxic_expansion_contract_test.gd` protège arsenal, capacités,
consommation, absorption, Overdrive et équipement des armes spéciales.
