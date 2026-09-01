@tool
class_name MissionHUDTheme
extends Resource

@export_category("Identity")
## Identifiant stable utilisé par les missions et futurs catalogues de thèmes.
@export var theme_id: StringName
## Nom lisible dans l'Inspector.
@export var display_name := "HUD"

@export_category("Frames")
## Cadre du portrait, de la vie, de l'armure et des futurs statuts joueur.
@export var player_status_frame: Texture2D
## Cadre de la WeaponData équipée, de son nom et de sa réserve.
@export var weapon_status_frame: Texture2D
## Bannière centrale réservée aux objectifs et beats de rencontre.
@export var objective_frame: Texture2D
## Cadre large de l'intégrité d'un Boss actif.
@export var boss_health_frame: Texture2D
## Tube affiché uniquement pendant une surcharge active.
@export var overdrive_frame: Texture2D
## Plaque utilisée pour les résultats et notifications importantes.
@export var notification_frame: Texture2D
## Illustration plein écran affichée pendant le chargement de la mission.
@export var loading_background: Texture2D

@export_category("Icons")
## Portrait canonique occupant le grand cercle du panneau joueur.
@export var player_portrait: Texture2D
## Petit repère de la statistique de vie, jamais substitut du portrait.
@export var health_icon: Texture2D
## Petit repère de la statistique d'armure.
@export var armor_icon: Texture2D
## Repère du compteur de munitions spéciales.
@export var ammo_icon: Texture2D
## Vocabulaire disponible pour une présentation de surcharge sans duplication.
@export var overdrive_icon: Texture2D
## Repère visuel d'un objectif de mission.
@export var objective_icon: Texture2D
## Vocabulaire Boss disponible pour les présentations sans emblème intégré.
@export var boss_icon: Texture2D
## Vocabulaire réservé à un futur système de grenades réel.
@export var grenade_icon: Texture2D
## Vocabulaire réservé aux notifications de checkpoint.
@export var checkpoint_icon: Texture2D
## Vocabulaire réservé aux futurs slots d'équipement réels.
@export var weapon_icon: Texture2D
## Vocabulaire réservé à un futur statut poison.
@export var poison_icon: Texture2D
## Vocabulaire réservé à un futur statut électrique.
@export var electric_icon: Texture2D
## Vocabulaire réservé à un futur statut feu.
@export var fire_icon: Texture2D

@export_category("Readability")
## Couleur dynamique de remplissage de la vie.
@export var health_fill_color := Color(0.94, 0.04, 0.12, 1.0)
## Couleur dynamique de remplissage de l'armure.
@export var armor_fill_color := Color(0.7, 0.84, 0.08, 1.0)
## Couleur dynamique de remplissage de la surcharge.
@export var overdrive_fill_color := Color(0.58, 0.94, 0.04, 1.0)
## Couleur dynamique de remplissage de la vie du Boss.
@export var boss_fill_color := Color(0.94, 0.02, 0.26, 1.0)
## Couleur opaque couvrant les jauges statiques présentes dans les cadres source.
@export var bar_background_color := Color(0.025, 0.03, 0.025, 0.96)
## Couleur commune des valeurs et libellés principaux.
@export var primary_text_color := Color(0.96, 0.91, 0.74, 1.0)
## Couleur d'accent disponible pour objectifs et confirmations.
@export var accent_text_color := Color(0.72, 0.9, 0.08, 1.0)


func is_valid() -> bool:
	return validation_errors().is_empty()


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if str(theme_id).is_empty():
		errors.append("Theme Id est obligatoire.")
	if display_name.strip_edges().is_empty():
		errors.append("Display Name est obligatoire.")
	for texture in [
		player_status_frame,
		weapon_status_frame,
		objective_frame,
		boss_health_frame,
		overdrive_frame,
		notification_frame,
		loading_background,
		player_portrait,
		health_icon,
		armor_icon,
		ammo_icon,
		overdrive_icon,
		objective_icon,
		boss_icon,
		grenade_icon,
		checkpoint_icon,
		weapon_icon,
		poison_icon,
		electric_icon,
		fire_icon,
	]:
		if texture == null:
			errors.append("Tous les cadres et icônes du thème doivent être assignés.")
			break
	return errors
