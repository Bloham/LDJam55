extends Node2D

@onready var game_scene = $"../.."
@onready var monk_button = $MarginContainer/MonkButton
@onready var spirit_button = $MarginContainer/SpiritButton
@onready var animated_sprite_2d = $AnimatedSprite2D


@export var monkFoodCost = 25
@export var monkFaithCost = 10

var workersAtBuilding = 0
var isFull = false

signal newBuildingSelected(building)

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("newBuildingSelected", self)

func _process(delta):
	if game_scene.resources["Food"] > monkFoodCost && game_scene.resources["Faith"] > monkFaithCost:
		monk_button.disabled = false
	else:
		monk_button.disabled = true

func showMonkButton():
	monk_button.visible = true
	spirit_button.visible = false
	
func showSpiritButton():
	monk_button.visible = false
	spirit_button.visible = true

func _on_monk_button_button_down():
	if game_scene.resources["Food"] > monkFoodCost && game_scene.resources["Faith"] > monkFaithCost:
		print("generate new Monk!")
		game_scene.resources["Food"] -= monkFoodCost
		game_scene.food_flash_red()
		game_scene.resources["Faith"] -= monkFaithCost
		game_scene.faith_flash_red()
		game_scene.maxWorkers += 1
		game_scene.spawn_monks(1, self.position)

func _on_spirit_button_button_down():
	if game_scene.workers.size() > 1:
		var worker = game_scene.workers.pop_back()
		game_scene.spawn_spirit(1, worker.position)
		worker.queue_free()
		print("Monk Geopfert!")

func addWorker(worker):
	if game_scene.current_state == game_scene.NightDay.NIGHT:
		worker.state = worker.States.RITUAL
		#workersAtBuilding += 1
		#game_scene.workers.erase(worker)
		#worker.queue_free()

func ritualMode():
	animated_sprite_2d.play("ritual")

func defaultMode():
	animated_sprite_2d.play("default")
