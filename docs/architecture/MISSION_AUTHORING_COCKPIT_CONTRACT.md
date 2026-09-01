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

## Validation

`tests/mission_authoring_tools_contract_test.gd` protège l'activation du plugin,
les chemins de playtest du catalogue et l'instanciation des scènes de test.
