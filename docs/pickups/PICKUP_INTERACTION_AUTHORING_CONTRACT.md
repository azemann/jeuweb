# Contrat auteur des interactions, pickups et stations

La première chaîne canonique est entièrement visible dans l'éditeur : une
caisse placée dans la carte référence son contenu, le joueur expose son
composant d'interaction et le pickup référence son effet. Aucun script de map ne
fabrique ou ne recopie ces données.

## Autorités

- intention périphérique : action `player_interact` de l'Input Map ;
- sélection runtime : `PlayerInteractionComponent` et son `InteractionArea` ;
- contenu d'une caisse : `SupplyCrateData.contents_scene` dans l'Inspector ;
- état fermé/ouvert : instance `SupplyCrate2D` ;
- identité, texture, effet, quantité et rayon : `PickupData.tres` ;
- vie courante : `PlayerHealthComponent`, modifiée uniquement par `heal()` ;
- munitions spéciales, armure et Overdrive :
  `PlayerCombatInventoryComponent`, réglé par
  `PlayerCombatInventoryProfile.tres` ;
- service, usages et arme accordée par une station : `ServiceStationData` ;
- arsenal autorisé et arme équipée runtime : `PlayerLoadoutProfile` puis
  `PlayerLoadoutComponent` ;
- placement de la caisse : instance sous `Gameplay/Interactions` ;
- placement initial du contenu : `ContentsOrigin` dans la scène de caisse.

## Correspondance canonique

```text
Input Map.player_interact
          ↓
Player/Components/Interaction
          ↓ groupe interaction_targets + couche Interactable
SupplyCrate2D ← SupplyCrateData.contents_scene
          ↓ ContentsOrigin
       Pickup2D ← PickupData
          ↓ collect(PlayerCharacter2D)
PlayerHealthComponent.heal(amount)
ou PlayerCombatInventoryComponent
ou PlayerLoadoutComponent.equip_weapon(WeaponData)
```

## Workflow auteur

1. Publier le bitmap sous `art/` depuis un lot traçable du pipeline.
2. Créer une `PickupData` et régler ses champs dans l'Inspector.
3. Dupliquer ou instancier la scène canonique `pickup_2d.tscn`, puis assigner la
   Resource sans coder l'effet dans la scène.
4. Assigner la scène de pickup à `Contents Scene` sur la `SupplyCrateData`, ou
   glisser directement le pickup sous `Gameplay/Interactions`.
5. Pour une station, créer une `ServiceStationData`, choisir soin,
   ravitaillement ou armurerie et assigner l'éventuelle `WeaponData`.
6. Glisser la scène canonique sous `Gameplay/Interactions` et régler son Transform.

Le pickup instancié est `top_level` afin de conserver sa taille publiée même si
la caisse est redimensionnée dans la carte. Une caisse déjà ouverte n'est plus
une cible d'interaction et ne peut produire son contenu qu'une seule fois.

## Contrat runtime

- le joueur choisit la cible valide la plus proche dans sa zone ;
- la cible possède l'acceptation de l'interaction, pas le joueur ;
- la caisse possède uniquement l'ouverture et l'instanciation de son contenu ;
- le pickup demande l'effet au composant autoritaire et ne disparaît que si cet
  effet est accepté ; un soin à vie maximale reste donc disponible ;
- aucune classe de pickup ne lit directement une touche physique ;
- chaque effet appelle son composant autoritaire et ne modifie jamais son état
  public directement ;
- une armurerie demande l'équipement de la `WeaponData` choisie au Loadout et
  peut fournir des munitions, sans recopier cadence, projectile ou
  représentation de l'arme.

## Validation

- `pickup_interaction_contract_test.gd` vérifie détection, prompt, ouverture,
  occurrence unique, spawn sans héritage d'échelle, collecte et soin ;
- `player_input_contract_test.gd` protège clavier, manette et bouton tactile ;
- `toxic_coast_content_pack_test.gd` protège la caisse publiée et son contenu ;
- `asset_pipeline_contract_test.gd` protège la frontière pipeline → `art/`.
- `industrial_toxic_expansion_contract_test.gd` protège les trois pickups, les
  deux stations de service et les quatre variantes d'armurerie.
