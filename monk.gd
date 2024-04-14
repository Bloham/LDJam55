extends RigidBody2D

# Constants and Enums
enum States { IDLE, ASSIGNED, WORK, RITUAL}
var state = States.IDLE

# Exported Variables
@export var starting_position = Vector2(320, 300)
@export var wander_offset = Vector2(100, 100)

# Node References
@onready var animation_player = $AnimationPlayer
@onready var animated_sprite_2d = $AnimatedSprite2D

var health = 1
var game_scene



# Movement Variables
var speed = 100
var direction = Vector2.ZERO
var current_waypoint = Vector2()
var is_moving = false
var idle_timer = 0.0

# Worker Variables
var assigned_building = null
var target_building = null

# Separation Behaviour
var separation_strength = 200

# Animation
var animationSpeed = 1
var idle_duration = 1.0  # Time in seconds the monk idles at a waypoint

# Signal
signal workerAtBuilding

# Initialization
func _ready():
	game_scene = get_tree().get_first_node_in_group("GameManager")
	print(game_scene.current_state)
	initialize_monk()
	for building in get_tree().get_nodes_in_group("Buildings"):
		building.request_worker.connect(_on_building_request_worker)
		lookForWork()

func lookForWork():
	if game_scene.current_state == game_scene.NightDay.DAY:
		for building in get_tree().get_nodes_in_group("Buildings"):
			#print("Looking for work: ", building)
			if building.isFull == false:
				_on_building_request_worker(building)
	elif game_scene.current_state == game_scene.NightDay.NIGHT:
		for sanctuary in get_tree().get_nodes_in_group("Sanctuary"):
			print("going to sanctuary")
			assign_to_building(sanctuary)

func initialize_monk():
	randomize()
	gravity_scale = 0
	set_random_animation_speed()
	choose_new_waypoint()

func set_random_animation_speed():
	animationSpeed = randf_range(0.2, 2)
	idle_timer = randf_range(0.5, 1)
	idle_duration = randf_range(0.5, 1)
	animation_player.speed_scale = animationSpeed
	
# Building Worker Request Handler
func _on_building_request_worker(building):
	print("Building Assigned: ", assigned_building)
	if assigned_building == null:  # Monk can be re-assigned regardless of its movement
		assign_to_building(building)

func can_assign_to_building(building):
	target_building = building
	state = States.ASSIGNED
	is_moving = true  # Monk should start moving towards the assigned building
	move_to_building(state)

# Physics Processing
func _integrate_forces(state):
	apply_separation_force(state)
	match self.state:
		States.IDLE: handle_idle_state(state)
		States.ASSIGNED: move_to_building(state)
		States.WORK: work_at_building(state)
		States.RITUAL: pray(state)

func pray(state):
	animated_sprite_2d.play("pray")

func apply_separation_force(state):
	var separation_force = get_separation_force()
	state.apply_central_impulse(separation_force)

# Idle State Handling
func handle_idle_state(state):
	if is_moving:
		move_towards_waypoint(state)
		check_arrival_at_waypoint(state)
	else:
		countdown_to_idle_or_choose_waypoint(state)

func move_towards_waypoint(state):
	direction = (current_waypoint - global_position).normalized()
	var desired_velocity = direction * speed
	state.apply_central_impulse(desired_velocity - state.linear_velocity)
	animated_sprite_2d.flip_h = direction.x < 0


func check_arrival_at_waypoint(state):
	if global_position.distance_to(current_waypoint) < 20:
		is_moving = false
		animation_player.play("IDLE")
		animated_sprite_2d.play("default")
		idle_timer = idle_duration
		lookForWork()

func countdown_to_idle_or_choose_waypoint(state):
	if idle_timer > 0:
		idle_timer -= state.step
	else:
		choose_new_waypoint()

# Building Movement
func move_to_building(state):
	if target_building:
		direction = (target_building.global_position - global_position).normalized()
		var desired_velocity = direction * speed
		state.apply_central_impulse(desired_velocity - state.linear_velocity)
		if has_arrived_at_building():
			#print("HAS ARRIVED!", target_building)
			if game_scene.current_state == game_scene.NightDay.NIGHT:
				self.state = States.RITUAL
			else:
				if target_building.isFull == false:
					self.state = States.WORK
					target_building.addWorker(self)
				else:
					self.state = States.IDLE
					lookForWork()
			clear_assigned_building()

func work_at_building(state):
	self.visible = false
	is_moving = false

func become_idle():
	print("Become Idle Again")
	animated_sprite_2d.play("default")
	self.visible = true
	state = States.IDLE
	choose_new_waypoint()

func has_arrived_at_building() -> bool:
	return global_position.distance_to(target_building.global_position) < 80 # adjust if monks get stuck

func clear_assigned_building():
	assigned_building = null
	target_building = null
	is_moving = false

# Worker Assignment
func assign_to_building(building):
	target_building = building
	state = States.ASSIGNED
	is_moving = true
	# More logic can be added here for what happens when a monk is assigned

# Utility Functions
func choose_new_waypoint():
	current_waypoint = starting_position + get_random_wander_offset()
	is_moving = true
	animation_player.play("WALK")
	animated_sprite_2d.play("default")


# Helper function within your monk script
func get_random_wander_offset() -> Vector2:
	return Vector2(
		randf_range(-wander_offset.x, wander_offset.x),
		randf_range(-wander_offset.y, wander_offset.y)
	)

func get_separation_force() -> Vector2:
	var separation_force = Vector2()
	var neighbors = 0
	for body in get_node("Area2D").get_overlapping_bodies():
		if body.is_in_group("monks"):  # Assuming monks are in a 'monks' group
			var to_body = global_position - body.global_position
			if to_body.length() > 0:
				separation_force += to_body.normalized() / to_body.length()
				neighbors += 1
	if neighbors > 0:
		separation_force /= neighbors
	return separation_force * separation_strength

func take_damage(amount):
	health -= amount
	if health <= 0:
		die()

func die():
	game_scene.unitDies(self)
