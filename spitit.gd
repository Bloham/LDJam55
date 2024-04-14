extends RigidBody2D

# Constants and Enums
enum States {
	IDLE,
	GOING_TO_ENEMY,
	FIGHT
	}

@export var health = 5

var attack_timer = 0.0
var target_enemy = null

var state = States.IDLE
var game_scene

# Exported Variables
@export var idle_position = Vector2(randf_range(200, 400), randf_range(200, 400))
@export var search_radius = 100.0
@export var speed = 200
@export var attack_force = 20
@export var damage = 1

# Node References
@onready var area2d = $Area2D
@onready var animated_sprite = $AnimatedSprite2D

# Initialization
func _ready():
	game_scene = get_tree().get_first_node_in_group("GameManager")
	state = States.IDLE
	global_position = idle_position

# Physics Processing
func _integrate_forces(state):
	match self.state:
		States.IDLE:
			handle_idle()
		States.GOING_TO_ENEMY:
			approach_enemy(state)
		States.FIGHT:
			fight(state)

func handle_idle():
	speed = 20
	animated_sprite.play("Idle")
	check_for_enemies()
	if global_position.distance_to(idle_position) > 200:
		move_towards(idle_position, speed)
	if game_scene.current_state == game_scene.NightDay.NIGHT:
		for enemy in get_tree().get_nodes_in_group("is_enemy"):
			target_enemy = enemy
			state = States.GOING_TO_ENEMY
			if enemy == null:
				state = States.IDLE


func approach_enemy(state):
	speed = 200
	if target_enemy and is_instance_valid(target_enemy):
		var direction = (target_enemy.global_position - global_position).normalized()
		var impulse = direction * attack_force
		state.apply_central_impulse(impulse)
		animated_sprite.play("Run")
	else:
		target_enemy = null
		state = States.IDLE
		check_for_enemies()

func fight(state):
	if attack_timer <= 0:
		animated_sprite.play("Fight")
		if target_enemy and is_instance_valid(target_enemy):
			target_enemy.take_damage(damage)
			attack_timer = 1.0
		else:
			target_enemy = null
			state = States.IDLE
			check_for_enemies()
	else:
		attack_timer -= state.step
		animated_sprite.play("Run")

func _on_body_entered(body):
	if body.is_in_group("is_enemy"):
		body == target_enemy
		state = States.FIGHT

func _on_body_exited(body):
	if target_enemy == body:
		target_enemy = null
		state = States.IDLE

# Helper functions
func move_towards(target_position, move_speed):
	var direction = (target_position - global_position).normalized()
	var desired_velocity = direction * move_speed
	var velocity_difference = desired_velocity - linear_velocity
	apply_central_impulse(velocity_difference)

# Utility method for dealing damage to an enemy
func take_damage(amount):
	health -= amount
	if health <= 0:
		die()

func die():
	game_scene.unitDies(self)

func check_for_enemies():
	var enemies = get_tree().get_nodes_in_group("is_enemy")
	if enemies.is_empty():
		state = States.IDLE
	else:
		#print("Enemies still present")
		pass
