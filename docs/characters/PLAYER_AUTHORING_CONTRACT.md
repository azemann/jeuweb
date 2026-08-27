# Contrat auteur du joueur

Le joueur est une scène canonique composée. La scène contient un composant de
commande d'arme, mais définition, projectile, impact et orchestration de mission
restent des scènes et Resources séparées. Aucun pouvoir spécial n'est prévu.

## Autorités

- déplacement : `PlayerMovementProfile.tres` ;
- règles de visée : `PlayerAimProfile.tres` ;
- maximum de vie et invulnérabilité : `PlayerHealthProfile.tres` ;
- arme équipée : `WeaponData.tres` ;
- état runtime correspondant : composant Movement, Aim, Health ou Weapon ;
- collision, présentation et assemblage : `PlayerCharacter2D.tscn` ;
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
│   ├── Weapon
│   │   └── FireCooldown
│   ├── Presentation
│   └── Grounding
│       ├── GroundAnchor
│       ├── GroundProbe
│       ├── LeftFootProbe
│       ├── RightFootProbe
│       └── GroundShadow
│   └── SlopePresentation
├── Presentation
│   ├── SlopeVisual
│   │   └── BodySprite
│   └── AimPivot
│       ├── Muzzle
│       │   └── MuzzleFlash
│       └── WeaponFeedback
└── AnimationPlayer
```

## Définition / instance / présentation

```text
PROFILES .tres
      ↓
COMPONENTS RUNTIME
      ↓
PRESENTATION + AnimationPlayer
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
- Weapon est seul propriétaire de la cadence runtime et émet
  `projectile_requested` sans connaître la carte ;
- `PlayerCharacter2D` expose uniquement la composition et des commandes
  intentionnelles comme `apply_damage()` ;
- le HUD observe le signal `health_changed` ;
- Presentation choisit les animations de locomotion selon l'état du
  CharacterBody2D ; Aim possède le retournement horizontal et la rotation de
  l'arme.
- Grounding projette l'ombre sur le collider World réel et conserve le
  GroundAnchor à l'origine commune des pieds et du CharacterBody2D.

## Contrat de validation

`player_contract_test.gd` vérifie scène, profils, composants, Input Map,
AnimationPlayer, Muzzle, spawn dans `Actors/RuntimePlayer`, collision avec la
carte, déplacement, saut et correspondance Health → HUD.
`player_input_contract_test.gd` vérifie les correspondances clavier, souris,
manette et téléphone ainsi que la scène tactile canonique.
`weapon_projectile_integration_test.gd` protège la cadence, le spawn au Muzzle,
la direction de visée, l'indépendance du projectile et l'impact physique.
