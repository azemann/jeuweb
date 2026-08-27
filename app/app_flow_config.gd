@tool
class_name AppFlowConfig
extends Resource

@export_group("Screens")
## Première scène affichée au lancement ; elle porte logos et avertissements avant le menu.
@export var boot_screen: PackedScene
## Scène du menu principal depuis laquelle le joueur démarre ou consulte la galerie.
@export var start_screen: PackedScene
## Scène optionnelle présentant les planches de direction artistique intégrées.
@export var gallery_screen: PackedScene
## Scène jouable chargée par le bouton de démarrage pendant la phase prototype.
@export var prototype_mission_screen: PackedScene

@export_group("Transitions")
## Durée, en secondes, des fondus entre écrans. Plus elle est longue, plus le flux paraît posé.
@export_range(0.05, 1.0, 0.05) var fade_duration := 0.20
## Couleur recouvrant l'écran pendant les transitions ; son alpha est animé automatiquement.
@export var fade_color := Color("11141d")
