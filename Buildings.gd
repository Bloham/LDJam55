extends Node2D

@onready var brewery = $Brewery
@onready var skriptorium = $Skriptorium
@onready var field = $Field
@onready var church = $Church


func _on_brewery_new_building_selected(building):
	print(building.name, " selected!")
	building.show_assigning_workers()
	skriptorium.hide_assigning_workers()
	field.hide_assigning_workers()
	church.hide_assigning_workers()

func _on_skriptorium_new_building_selected(building):
	print(building.name, " selected!")
	building.show_assigning_workers()
	brewery.hide_assigning_workers()
	field.hide_assigning_workers()
	church.hide_assigning_workers()

func _on_field_new_building_selected(building):
	print(building.name, " selected!")
	building.show_assigning_workers()
	skriptorium.hide_assigning_workers()
	brewery.hide_assigning_workers()
	church.hide_assigning_workers()

func _on_church_new_building_selected(building):
	print(building.name, " selected!")
	building.show_assigning_workers()
	skriptorium.hide_assigning_workers()
	field.hide_assigning_workers()
	brewery.hide_assigning_workers()
