extends Node2D

@onready var monk_spawner = $MonkSpawner

var MONK = preload("res://monk.tscn")

@export var maxWorkers = 8
var workers = []

@export var maxSprits = 1
var spirits = []

var resources = {
	"Beer": 0,
	"Food": 0,
	"Faith": 0,
	"Knowledge": 0
	}

var maxCap = 100

@onready var faith_progress_bar = $UI/Panel/MarginContainer/HBoxContainer/Faith/ProgressBar
@onready var beer_progress_bar = $UI/Panel/MarginContainer/HBoxContainer/Beer/ProgressBar
@onready var food_progress_bar = $UI/Panel/MarginContainer/HBoxContainer/Food/ProgressBar
@onready var knowledge_progress_bar = $UI/Panel/MarginContainer/HBoxContainer/Knowledge/ProgressBar
@onready var monk_lable = $UI/Panel/MarginContainer/HBoxContainer/Monks/HBoxContainer/MonkLable
@onready var spirit_lable = $UI/Panel/MarginContainer/HBoxContainer/Spirits/HBoxContainer/SpiritLable


func _ready():
	faith_progress_bar.max_value = maxCap
	beer_progress_bar.max_value = maxCap
	food_progress_bar.max_value = maxCap
	knowledge_progress_bar.max_value = maxCap
	
	spawn_monks()


func spawn_monks():
	if not MONK:
		print("MonkScene not loaded")
		return
	else:
		print("MonkScene is loaded, proceeding to spawn monks.")

	var current_workers_count = workers.size()  # Get the current number of spawned monks
	var monks_to_spawn = maxWorkers - current_workers_count  # Calculate how many more monks need to be spawned

	for i in range(monks_to_spawn):
		var new_monk = MONK.instantiate()
		if not new_monk:
			print("Failed to instance monk.")
		else:
			print("Monk instanced successfully.")
		add_child(new_monk)
		new_monk.position = monk_spawner.position  # Ensure monk_spawner is a valid Node2D
		workers.append(new_monk)  # Keep track of workers
		print("Monk positioned at:", new_monk.position)


func _physics_process(delta):
	update_progress_bars()

func update_progress_bars():
	faith_progress_bar.value = resources["Faith"]
	beer_progress_bar.value = resources["Beer"]
	food_progress_bar.value = resources["Food"]
	knowledge_progress_bar.value = resources["Knowledge"]
	monk_lable.text = str(workers.size(), " / ", maxWorkers)
	spirit_lable.text = str(spirits.size(), " / ", maxSprits)

