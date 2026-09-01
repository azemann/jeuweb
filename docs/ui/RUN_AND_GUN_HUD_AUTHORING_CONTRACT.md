# Contrat auteur du HUD run-and-gun

Le HUD de mission privilégie la lecture périphérique immédiate et laisse le
centre du gameplay libre. Il observe les systèmes runtime sans posséder leur
état.

## Autorités

- `HealthComponent` possède la vie ;
- `PlayerCombatInventoryComponent` possède munitions spéciales, armure et
  Overdrive ;
- `PlayerLoadoutComponent` possède l'arme équipée ;
- `PlayerWeaponComponent.weapon` est la copie consommée pour cadence et tir ;
- `EnemyHealthComponent` possède la vie du Boss ;
- `MissionHUDTheme.tres` possède cadres, icônes, portrait et couleurs ;
- `MissionHUD.tscn` possède le layout et la hiérarchie visuelle ;
- `WeaponWheelOverlay` possède uniquement l'affichage temporaire et la commande
  de sélection d'une arme autorisée ;
- `MissionMapDefinition.hud_theme` choisit la peau d'une mission ;
- l'écran de mission relie événements de chargement, rencontre et victoire au
  HUD, sans recopier les données observées.

## Matrice sémantique Toxic Commando

| Emplacement graphique | Information autorisée | Source runtime |
|---|---|---|
| grand cercle du panneau joueur | portrait du commando | `MissionHUDTheme.player_portrait` |
| petite icône près de la barre rouge | repère santé | `MissionHUDTheme.health_icon` |
| barre rouge | vie courante / maximum | `PlayerHealthComponent` |
| petite icône près de la barre verte | repère armure | `MissionHUDTheme.armor_icon` |
| barre verte | armure courante / maximum | `PlayerCombatInventoryComponent` |
| quatre slots inférieurs | futurs statuts temporaires | aucun tant que le système n'existe pas |
| fenêtre du panneau arme | bitmap de l'arme équipée | `WeaponData.weapon_texture` |
| compteur arme | réserve spéciale ou infini | `WeaponData.uses_special_ammo` + inventaire |
| roue d'armes temporaire | armes autorisées et arme sélectionnée | `PlayerLoadoutComponent` |
| bannière centrale | objectif ou beat courant | contrôleur de mission/rencontre |
| cadre Boss | nom, vie et valeur du Boss | `EnemyArchetypeProfile` + santé |
| tube de surcharge | durée restante | inventaire |

Le cadre Boss contient déjà une tête monstrueuse et le tube Overdrive contient
déjà un pictogramme radioactif. Ajouter `boss_icon` ou `overdrive_icon` dans ces
zones constitue une duplication visuelle interdite.

Le cœur ne remplace jamais le portrait. Une icône décrit une statistique ; un
portrait identifie l'acteur auquel appartiennent les statistiques.

## Scène canonique

```text
MissionHUD
├── PlayerStatus
│   ├── PlayerFrame
│   ├── PlayerPortrait
│   ├── HealthIcon + Health + HealthValue
│   └── ArmorIcon + Armor + ArmorValue
├── WeaponStatus
│   ├── WeaponFrame
│   ├── WeaponPreview
│   ├── WeaponName
│   └── AmmoIcon + AmmoValue
├── ObjectiveStatus
├── BossStatus
├── OverdriveStatus
├── WeaponWheel
├── MissionStatusPanel
└── ResultPanel
```

Le bouton Retour ne fait pas partie du HUD de gameplay. Il reste masqué pendant
la mission et n'apparaît provisoirement qu'après une erreur ou une victoire, en
attendant le menu Pause/Options.

## Pipeline et thèmes futurs

Les planches sources ne sont jamais chargées par Godot. Le pipeline découpe et
normalise les livrables sous `art/ui/hud/<theme_id>/`. Une nouvelle mission :

1. publie son lot graphique ;
2. crée un `MissionHUDTheme.tres` ;
3. assigne cette Resource dans sa `MissionMapDefinition` ;
4. réutilise la scène `MissionHUD.tscn` et ses contrats de données.

Changer de thème ne doit jamais modifier `MissionHUD.gd`, les composants joueur
ou les contrôleurs de mission.

## Évolution de l'arsenal

Le panneau arme n'est jamais spécialisé pour le canon de campagne. Il consomme
à chaque équipement :

- `WeaponData.display_name` pour le libellé ;
- `WeaponData.weapon_texture` pour la fenêtre de prévisualisation ;
- `WeaponData.uses_special_ammo` et `ammo_cost` pour le compteur ;
- le signal `PlayerWeaponComponent.weapon_changed` pour la synchronisation.

Cette version couvre déjà canon principal, pulvérisateur acide, fusil électrique,
canon imploseur et lanceur de démolition sans branche conditionnelle sur leurs
identifiants.

L'autorité actuelle reste une arme équipée et une réserve spéciale partagée.
L'arsenal autorisé existe maintenant dans `PlayerLoadoutProfile`, mais le
gameplay possède encore une seule arme équipée et une réserve spéciale
partagée. La roue d'armes v001 sert à tester rapidement les cinq armes
autorisées : elle observe `PlayerLoadoutComponent.available_weapons()` et
appelle `equip_weapon()` au relâchement de `player_weapon_wheel`. Pour permettre
le test immédiat des projectiles spéciaux, son export
`refill_special_ammo_on_select` remplit la réserve partagée via
`PlayerCombatInventoryComponent.add_ammo()` lorsqu'une arme consommatrice est
choisie. Elle ne crée pas de slots persistants, de réserves par arme ou de
nouvel inventaire. Le jour où le gameplay introduit plusieurs emplacements
simultanés ou
des réserves par famille, le HUD observera les signaux de Loadout et affichera
alors les slots réels. Il est interdit de simuler dès maintenant des slots
vides, des quantités par arme ou une sélection que le gameplay ne possède pas
encore.

Les icônes grenade, checkpoint, arme, poison, électricité et feu sont déjà
publiées dans `MissionHUDTheme` comme vocabulaire visuel disponible ; leur
présence dans la Resource n'autorise pas leur affichage sans système runtime
correspondant.

## Validation

`mission_hud_contract_test.gd` protège la distinction portrait/icône, la fenêtre
d'arme, la roue d'armes branchée au Loadout, les signaux de l'inventaire et
l'absence d'emblèmes dupliqués.
`player_contract_test.gd`, `mission_run_contract_test.gd` et
`encounter_cadence_contract_test.gd` vérifient l'intégration en situation.
