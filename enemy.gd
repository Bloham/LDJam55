extends RigidBody2D

# Constants and Enums
enum States {
	SEARCH_TARGET,
	GOING_TO_TARGET,
	FIGHT,
	MOVING_TO_SANCTUARY
	}

var state = States.SEARCH_TARGET

# Exported Variables
@export var health = 2
@export var speed = 150
@export var attack_force = 200
@export var damage = 1

# Node References
@onready var area2d = $Area2D
@onready var animated_sprite = $AnimatedSprite2D

# Movement and target tracking
var target = null
var sanctuary = null
var attack_timer = 1.0
var game_scene

func _ready():
	global_position = Vector2(1150, randf_range(50, 550))
	game_scene = get_tree().get_first_node_in_group("GameManager")
	sanctuary = get_tree().get_first_node_in_group("Sanctuary")
	print("Ghost found Sanctuary! and Game Manager!")

func _integrate_forces(state):
	match self.state:
		States.SEARCH_TARGET:
			search_for_targets()
		States.GOING_TO_TARGET:
			approach_target(state)
		States.FIGHT:
			fight(state)
		States.MOVING_TO_SANCTUARY:
			move_to_sanctuary()

func search_for_targets():
	animated_sprite.play("Run")
	if game_scene.current_state == game_scene.NightDay.NIGHT:
		for spirit in get_tree().get_nodes_in_group("Spirits"):
			target = spirit
			state = States.GOING_TO_TARGET
			return
		for monk in get_tree().get_nodes_in_group("monks"):
			target = monk
			state = States.GOING_TO_TARGET
			return
		if target == null:
			state = States.MOVING_TO_SANCTUARY
	elif game_scene.current_state == game_scene.NightDay.DAY:
		self.queue_free()

func approach_target(state):
	if target and is_instance_valid(target):
		move_towards(target.global_position, speed)
		animated_sprite.play("Run")
	else:
		search_for_targets()

func fight(state):
	animated_sprite.play("Fight")
	if attack_timer <= 0:
		if target == null:
			state = States.SEARCH_TARGET
			search_for_targets()
		else:
			target.take_damage(damage)
			attack_timer = 1.0  # Reset attack timer
	else:
		attack_timer -= state.step

func move_to_sanctuary():
	if sanctuary:
		move_towards(sanctuary.global_position, speed)
		animated_sprite.play("Run")
		if global_position.distance_to(sanctuary.global_position) < 10:
			game_scene.ghostHaveWon = true
			print("Ghost have won!")

func move_towards(target_position, move_speed):
	var direction = (target_position - global_position).normalized()
	var desired_velocity = direction * move_speed
	var velocity_difference = desired_velocity - linear_velocity
	apply_central_impulse(velocity_difference)

func take_damage(amount):
	health -= amount
	if health <= 0:
		die()

func die():
	game_scene.unitDies(self)

func _on_area_2d_body_entered(body):
	if body == target:
		state = States.FIGHT
		
