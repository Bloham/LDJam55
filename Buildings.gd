extends Node2D

@onready var brewery = $Brewery
@onready var skriptorium = $Skriptorium
@onready var field = $Field
@onready var church = $Church
@onready var game_scene = $".."

func _ready():
	_on_square_new_building_selected(field)

func _on_brewery_new_building_selected(building):
	if game_scene.current_state == game_scene.NightDay.DAY:
		print(building.name, " selected!")
		building.show_assigning_workers()
		skriptorium.hide_assigning_workers()
		field.hide_assigning_workers()
		church.hide_assigning_workers()
	else:
		_on_square_new_building_selected(building)

func _on_skriptorium_new_building_selected(building):
	if game_scene.current_state == game_scene.NightDay.DAY:
		print(building.name, " selected!")
		building.show_assigning_workers()
		brewery.hide_assigning_workers()
		field.hide_assigning_workers()
		church.hide_assigning_workers()
	else:
		_on_square_new_building_selected(building)

func _on_field_new_building_selected(building):
	if game_scene.current_state == game_scene.NightDay.DAY:
		print(building.name, " selected!")
		building.show_assigning_workers()
		skriptorium.hide_assigning_workers()
		brewery.hide_assigning_workers()
		church.hide_assigning_workers()
	else:
		_on_square_new_building_selected(building)

func _on_church_new_building_selected(building):
	if game_scene.current_state == game_scene.NightDay.DAY:
		print(building.name, " selected!")
		building.show_assigning_workers()
		skriptorium.hide_assigning_workers()
		field.hide_assigning_workers()
		brewery.hide_assigning_workers()
	else:
		_on_square_new_building_selected(building)

func _on_square_new_building_selected(building):
	print(building.name, " selected!")
	church.hide_assigning_workers()
	skriptorium.hide_assigning_workers()
	field.hide_assigning_workers()
	brewery.hide_assigning_workers()

func _on_idle_area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("IDLE AREA")
		church.hide_assigning_workers()
		skriptorium.hide_assigning_workers()
		field.hide_assigning_workers()
		brewery.hide_assigning_workers()
