extends Node2D


@onready var game_scene = $"../.."
@onready var monk_button = $MarginContainer/MonkButton
@onready var spirit_button = $MarginContainer/SpiritButton


var workersAtBuilding = 0

signal newBuildingSelected(building)


func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("newBuildingSelected", self)


func showMonkButton():
	monk_button.visible = true
	spirit_button.visible = false
	
func showSpiritButton():
	monk_button.visible = false
	spirit_button.visible = true


func _on_monk_button_button_down():
	print("generate new Monk!")
	game_scene.maxWorkers += 1
	game_scene.spawn_monks()



func _on_spirit_button_button_down():
	print("generate new Spirit!")
