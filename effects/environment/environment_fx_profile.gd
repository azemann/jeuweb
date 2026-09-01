@tool
class_name EnvironmentFXProfile
extends Resource

@export_category("Identity")
## Nom lisible du climat visuel dans l'Inspector.
@export var display_name := "Atmosphère"

@export_category("Smoke")
## Active les panaches lents placés dans la scène maîtresse.
@export var smoke_enabled := true
## Quantité de particules de fumée simultanées.
@export_range(1, 64, 1) var smoke_amount := 18
## Teinte appliquée au matériau de fumée canonique.
@export var smoke_color := Color(0.23, 0.29, 0.25, 0.42)

@export_category("Toxic Fog")
## Active la nappe toxique proche du couloir jouable.
@export var fog_enabled := true
## Quantité de particules constituant la nappe.
@export_range(1, 48, 1) var fog_amount := 12
## Teinte de la nappe atmosphérique.
@export var fog_color := Color(0.55, 0.72, 0.08, 0.16)

@export_category("Sparks")
## Active les étincelles industrielles du segment.
@export var sparks_enabled := false
## Quantité d'étincelles simultanées.
@export_range(1, 96, 1) var sparks_amount := 28
## Teinte des étincelles.
@export var sparks_color := Color(1.0, 0.47, 0.08, 0.9)

@export_category("Lightning")
## Active les éclairs environnementaux non interactifs.
@export var lightning_enabled := false
## Délai minimal entre deux éclairs.
@export_range(1.0, 30.0, 0.5, "suffix:s") var lightning_interval_min := 7.0
## Délai maximal entre deux éclairs.
@export_range(1.0, 45.0, 0.5, "suffix:s") var lightning_interval_max := 13.0
## Couleur du flash et des branches d'éclair.
@export var lightning_color := Color(0.74, 0.91, 1.0, 1.0)


func is_valid() -> bool:
	return validation_errors().is_empty()


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if display_name.strip_edges().is_empty():
		errors.append("Display Name ne peut pas être vide.")
	if smoke_amount <= 0 or fog_amount <= 0 or sparks_amount <= 0:
		errors.append("Les quantités de particules doivent être positives.")
	if lightning_interval_min <= 0.0:
		errors.append("Lightning Interval Min doit être positif.")
	if lightning_interval_max < lightning_interval_min:
		errors.append("Lightning Interval Max doit être supérieur ou égal au minimum.")
	return errors
