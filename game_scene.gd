extends Node2D

@onready var monk_spawner = $MonkSpawner

var MONK = preload("res://monk.tscn")
const SPITIT = preload("res://spitit.tscn")
const ENEMY = preload("res://enemy.tscn")
const EXPLOSION = preload("res://explosion.tscn")

@export var maxWorkers = 1
var workers = []

@export var maxSprits = 1
var spirits = []

var enemiesToSpawn = 0
var enemiesAlive = 0

var resources = {
	"Beer": 0,
	"Food": 30,
	"Faith": 21,
	"Knowledge": 0
	}

enum NightDay {
	DAY,
	NIGHT
	}

var current_state = NightDay.DAY
var ghostHaveWon = false

var maxCap = 100

@onready var faith_progress_bar = $UI/Panel/MarginContainer/HBoxContainer/Faith/ProgressBar
@onready var beer_progress_bar = $UI/Panel/MarginContainer/HBoxContainer/Beer/ProgressBar
@onready var food_progress_bar = $UI/Panel/MarginContainer/HBoxContainer/Food/ProgressBar
@onready var knowledge_progress_bar = $UI/Panel/MarginContainer/HBoxContainer/Knowledge/ProgressBar
@onready var monk_lable = $UI/Panel/MarginContainer/HBoxContainer/Monks/HBoxContainer/MonkLable
@onready var spirit_lable = $UI/Panel/MarginContainer/HBoxContainer/Spirits/HBoxContainer/SpiritLable
@onready var night_color_rect = $UI/NightColorRect
@onready var buildings = $Buildings
@onready var square = $Buildings/SQUARE

@onready var audio_arbeiten = $arbeiten
@onready var audio_button = $button
@onready var audio_on_my_way = $onMyWay
@onready var audio_wololo = $wololo
@onready var audio_yes_sir = $yesSir
@onready var audio_day = $day
@onready var audio_night = $night
@onready var audio_arg = $arg




func _ready():
	faith_progress_bar.max_value = maxCap
	beer_progress_bar.max_value = maxCap
	food_progress_bar.max_value = maxCap
	knowledge_progress_bar.max_value = maxCap
	spawn_monks(maxWorkers, monk_spawner.position)
	night_color_rect.modulate.a = 0

func spawn_spirit(ammount, spawnPosition):
	var current_spirit_count = spirits.size()
	var spirits_to_spawn = maxSprits - current_spirit_count
	for i in range(ammount):
		audio_wololo.play()
		var new_spirit = SPITIT.instantiate()
		add_child(new_spirit)
		new_spirit.position = spawnPosition
		spirits.append(new_spirit)
		maxWorkers -= 1
		maxSprits += 1

func spawn_monks(ammount, spawnPosition):
	var current_workers_count = workers.size()  # Get the current number of spawned monks
	var monks_to_spawn = maxWorkers - current_workers_count  # Calculate how many more monks need to be spawned
	
	for i in range(ammount):
		audio_wololo.play()
		var new_monk = MONK.instantiate()
		add_child(new_monk)
		new_monk.position = spawnPosition  # Ensure monk_spawner is a valid Node2D
		workers.append(new_monk)  # Keep track of workers


func _physics_process(delta):
	update_progress_bars()
	if ghostHaveWon == true:
		get_tree().change_scene_to_file("res://start_menue.tscn")

func update_progress_bars():
	faith_progress_bar.value = resources["Faith"]
	beer_progress_bar.value = resources["Beer"]
	food_progress_bar.value = resources["Food"]
	knowledge_progress_bar.value = resources["Knowledge"]
	monk_lable.text = str(workers.size(), " / ", maxWorkers)
	spirit_lable.text = str(spirits.size(), " / ", maxSprits)


func food_flash_red():
	flash_red(food_progress_bar)

func faith_flash_red():
	flash_red(faith_progress_bar)

func beer_flash_red():
	flash_red(beer_progress_bar)

func knowledge_flash_red():
	flash_red(knowledge_progress_bar)

func flash_red(thing):
	var tween = get_tree().create_tween()
	tween.tween_property(thing, "self_modulate", Color(1, 0, 0, 1), 0.2).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(thing, "self_modulate", Color(1, 1, 1, 1), 0.2).set_delay(0.2).set_trans(Tween.TRANS_LINEAR)

func _on_night_and_day_timeout():
	match current_state:
		NightDay.DAY:
			audio_night.play()
			print("Switching to night")
			fade_to(0.75, 2)
			current_state = NightDay.NIGHT
			enemiesToSpawn += 1
			spawnGhosts(enemiesToSpawn)
			buildings._on_square_new_building_selected(monk_spawner) # monkspawner is just here because it need a variable
			emptyBuildings()
			square.showSpiritButton()
			square.ritualMode()
			#for worker in workers:
			#	worker.state = worker.States.IDLE
			#	worker.animated_sprite_2d.play("default")
		NightDay.NIGHT:
			audio_day.play()
			print("Switching to day")
			fade_to(0, 2)
			current_state = NightDay.DAY
			for monk in workers:
				monk.become_idle()
			square.showMonkButton()
			square.defaultMode()


func spawnGhosts(gohstsToSpawn):
	for i in gohstsToSpawn:
		audio_button.play()
		print("Spawn Enemy")
		var new_enemy = ENEMY.instantiate()
		add_child(new_enemy)
		new_enemy.position = Vector2(1150, randf_range(50,550)) 
		enemiesAlive += 1

func fade_to(target_alpha, duration):
	var tween = get_tree().create_tween()
	tween.tween_property(night_color_rect, "modulate:a", target_alpha, duration).set_trans(Tween.TRANS_LINEAR)

func emptyBuildings():
	audio_wololo.play()
	for building in get_tree().get_nodes_in_group("Buildings"):
		for open_positions in building.open_positions:
			building._on_take_button_button_down()

func explosion(position):
	audio_arg.play()
	var new_explosion = EXPLOSION.instantiate()
	new_explosion.position = position
	add_child(new_explosion)

func unitDies(unit):
	explosion(unit.position)
	for i in workers:
		if i == unit:
			workers.erase(unit)
			print("Removed WORKER: ", unit, " from Array")
			unit.queue_free()
			maxWorkers -= 1
			return
			
	for i in spirits:
		if i == unit:
			spirits.erase(unit)
			print("Removed SPIRIT: ", unit, " from Array")
			unit.queue_free()
			maxSprits -= 1
			return
	
	if unit.is_in_group("is_enemy") == true:
		print("Removed: ", unit)
		unit.queue_free()
		enemiesAlive -= 1
		if enemiesAlive == 0:
			switchToDay()
		return

func switchToDay():
	print("Switch to day")
	$NightAndDay.start(30)
	_on_night_and_day_timeout()
