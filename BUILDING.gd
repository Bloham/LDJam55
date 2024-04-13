extends Node2D

@export var sprite = Texture2D
@export var resource = ""

@onready var assigning_workers = $BuildingUI/AssigningWorkers
@onready var game_scene = $"../.."
@onready var workers_label = $BuildingUI/BuildingInfo/MarginContainer/VBoxContainer/HBoxContainer/WorkersLabel

var workersAtBuilding = 0
var open_positions = 0
var generatedRessource = 0 
var isFull = true


signal newBuildingSelected(building)
signal request_worker(building)

func _ready():
	$Sprite2D.texture = sprite
	$BuildingUI/BuildingInfo/MarginContainer/VBoxContainer/BuildingNameLable.text = self.name
	$BuildingUI/BuildingInfo/MarginContainer/VBoxContainer/HBoxContainer/ResourceLabel.text = resource
	update_Label()

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("newBuildingSelected", self)

func show_assigning_workers():
	assigning_workers.visible = true
	
func hide_assigning_workers():
	assigning_workers.visible = false

func _on_add_button_button_down():
	#if game_scene.workers.size() >= 1 && workersAtBuilding.size() < open_positions:
	request_workers(1)

func addWorker(worker):
	workersAtBuilding += 1
	game_scene.workers.erase(worker)
	worker.queue_free()
	checkIfFull()
	update_Label()

func checkIfFull():
	if workersAtBuilding == open_positions:
		isFull = true
	else:
		isFull = false

func freeWorker(worker):
	workersAtBuilding.erase(worker)
	workers_label.text = str(workersAtBuilding)
	game_scene.workers.append(worker)
	worker.become_idle()

func _on_take_button_button_down():
	if open_positions == 0:
		return
	open_positions -= 1
	if workersAtBuilding > 0:
		workersAtBuilding -= 1
		game_scene.spawn_monks(1, self.position)
	update_Label()

func _physics_process(delta):
	if resource in game_scene.resources and game_scene.resources[resource] < game_scene.maxCap:
		game_scene.resources[resource] += workersAtBuilding * delta
		game_scene.resources[resource] = min(game_scene.resources[resource], game_scene.maxCap)

func request_workers(count):
	open_positions += count
	checkIfFull()
	update_Label()
	emit_signal("request_worker", self)
	print("Request worker, open positions: ", open_positions)

func update_Label():
		workers_label.text = str(workersAtBuilding, " / ", open_positions)
