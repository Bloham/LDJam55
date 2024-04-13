extends RigidBody2D

@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D

enum States { IDLE, ASSIGNED, RITUAL}
var state = States.IDLE
var speed = 150  # Adjusted for forces; might need tuning
var target_building = null

var current_waypoint = Vector2()
@export var starting_position = Vector2()
var wander_offset = Vector2(80, 80)
var is_moving = false
var idle_timer = 0.0
var idle_duration = 1.0  # Time in seconds the monk idles at a waypoint

var animationSpeed = 1 
var direction = Vector2.ZERO

# For wandering behavior

func _ready():
	randomize() 
	print("Starting position set to:", starting_position)
	idle_timer = randf_range(0.5, 1)
	idle_duration = randf_range(0.5, 1)
	animationSpeed = randf_range(0.2, 2)
	animation_player.speed_scale = animationSpeed
	gravity_scale = 0
	choose_new_waypoint()

func _integrate_forces(state):
	match self.state:
		States.IDLE:
			wander(state)
		States.ASSIGNED:
			move_to_building(state)
		States.RITUAL:
			pass # Implement logic for defensive behavior

func wander(state):
	if is_moving:
		direction = (current_waypoint - global_position).normalized()
		var desired_velocity = direction * speed
		state.apply_central_impulse(desired_velocity - state.linear_velocity)
		sprite_2d.flip_h = direction.x < 0
		if global_position.distance_to(current_waypoint) < 5:
			is_moving = false
			animation_player.play("IDLE")
			idle_timer = idle_duration
	else: # Handle idling
		if idle_timer > 0:
			idle_timer -= state.step
		else: # Choose a new waypoint after idling
			choose_new_waypoint()


func choose_new_waypoint():
	var new_x = randf_range(-wander_offset.x, wander_offset.x)
	var new_y = randf_range(-wander_offset.y, wander_offset.y)
	current_waypoint = starting_position + Vector2(new_x, new_y)
	is_moving = true
	animation_player.play("WALK")

func move_to_building(state):
	if target_building:
		direction = (target_building.global_position - global_position).normalized()
		var desired_velocity = direction * speed
		state.apply_central_impulse(desired_velocity - state.linear_velocity)
		if global_position.distance_to(target_building.global_position) < 10:
			self.state = States.IDLE # Change state to IDLE or another appropriate state upon reaching

func assign_to_building(building):
	state = States.ASSIGNED
	target_building = building
