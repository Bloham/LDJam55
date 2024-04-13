extends Node2D

@export var sprite = Texture2D
@export var resource = ""
@export var workersCapacity = 6

@onready var assigning_workers = $BuildingUI/AssigningWorkers
@onready var game_scene = $"../.."
@onready var workers_label = $BuildingUI/BuildingInfo/MarginContainer/VBoxContainer/HBoxContainer/WorkersLabel

var workersAtBuilding = 0
var generatedRessource = 0 


signal newBuildingSelected(building)

func _ready():
	$Sprite2D.texture = sprite
	$BuildingUI/BuildingInfo/MarginContainer/VBoxContainer/BuildingNameLable.text = self.name
	$BuildingUI/BuildingInfo/MarginContainer/VBoxContainer/HBoxContainer/ResourceLabel.text = resource
	workers_label.text = str(workersAtBuilding, " / ", workersCapacity)

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("newBuildingSelected", self)

func show_assigning_workers():
	assigning_workers.visible = true
	
func hide_assigning_workers():
	assigning_workers.visible = false


func _on_add_button_button_down():
	if game_scene.workers >= 1 && workersAtBuilding < workersCapacity:
		game_scene.workers -= 1
		workersAtBuilding += 1
		workers_label.text = str(workersAtBuilding, " / ", workersCapacity)


func _on_take_button_button_down():
	if workersAtBuilding >= 1:
		workersAtBuilding -= 1
		game_scene.workers += 1
		workers_label.text = str(workersAtBuilding, " / ", workersCapacity)

func _physics_process(delta):
	if resource in game_scene.resources and game_scene.resources[resource] < game_scene.maxCap:
		game_scene.resources[resource] += workersAtBuilding * delta
		game_scene.resources[resource] = min(game_scene.resources[resource], game_scene.maxCap)

