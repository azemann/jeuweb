# Cockpit d'édition des missions

Ce contrat adapte la méthode de `rpg-01` au run-and-gun. Le principe repris est
le cockpit éditeur : un panneau Godot liste les correspondances importantes et
ouvre les bons objets d'auteur. Le pipeline Tiled de `rpg-01` n'est pas repris,
car `jeuweb` compose ses missions directement dans des scènes maîtresses Godot.

## Autorités

- liste des missions : `maps/definitions/mission_map_catalog.tres` ;
- identité, scène maître, dimensions, HUD et scène de test :
  `MissionMapDefinition` ;
- composition level design/game art : scène maître sous `maps/missions/` ;
- test jouable : scène déclarée par `MissionMapDefinition.playtest_scene_path` ;
- test runtime depuis le menu principal : `MissionTestSelectScreen`, alimenté
  par `MissionMapCatalog` et lançant `PrototypeMissionScreen` ;
- cockpit éditeur : plugin `addons/mission_authoring`.

## Règles

- Le dock ne code aucun `map_id` en dur ; il lit toujours le catalogue.
- Le bouton `Définition` ouvre la Resource sélectionnée dans l'Inspecteur.
- Le bouton `Scène` ouvre la scène maîtresse autoritaire.
- Le bouton `Tester` lance la scène de playtest déclarée par la mission.
- Une nouvelle mission n'est considérée éditable que si sa définition déclare
  une scène maître et une scène de playtest existantes.
- L'écran de playtest peut hériter de `prototype_mission_screen.tscn` et
  surcharger seulement `mission_definition_override`.
- Le bouton `Mission` du menu principal ne doit pas coder une mission unique :
  il ouvre un sélecteur de test alimenté par le catalogue.
- Le sélecteur runtime ne possède pas le player, le HUD, les spawners ou la
  carte chargée ; il instancie seulement `PrototypeMissionScreen` et lui
  transmet la `MissionMapDefinition` choisie.

## Validation

`tests/mission_authoring_tools_contract_test.gd` protège l'activation du plugin,
les chemins de playtest du catalogue et l'instanciation des scènes de test.
`tests/mission_playtest_selector_contract_test.gd` protège le sélecteur runtime
et le routage du bouton `Mission` vers ce sélecteur.
