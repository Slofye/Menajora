extends CharacterBody2D

# Animated sprite and collision shape references
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collider: CollisionShape2D = $CollisionShape2D

# Movement direction and speed
var direction = Vector2.ZERO
var speed := 80.0
var gravity := 400.0

# Dev tools 
var is_being_dragged := false
var drag_offset := Vector2.ZERO


# Time ranges for idle and movement durations
var idle_time_range = Vector2(1.0, 4.0)
var move_time_range = Vector2(2.0, 8.0)

# Movement state
var is_moving = false

# Behavior weights and animations
var behavior_pool = [
	{"type": "idle", "anim": "Idle", "weight": 5},
	{"type": "idle", "anim": "Sniff", "weight": 2},
	{"type": "move", "anim": "Walk", "weight": 5},
	{"type": "move", "anim": "Run", "weight": 2},
	{"type": "move", "anim": "RunFast", "weight": 1},
	{"type": "idle", "anim": "HappyDance", "weight": 1},
	{"type": "move", "anim": "SniffAndWalk", "weight": 1},
	{"type": "jump", "anim": "Jump", "weight": 1}
]

# Tracks if the dog has already hit the edge (to prevent print spam)
var was_outside_bounds := false


func _ready():
	randomize()
	_start_behavior()


func _physics_process(delta):
	# Always apply gravity
	velocity.y += gravity * delta
	
	# Move or stay idle
	if is_moving:
		move_and_slide()

	else:
		velocity.x = 0.0  # Only stop horizontal movement
		move_and_slide()

	# Clamp to screen bounds based on collider shape
	var collider_extents = Vector2.ZERO
	if collider.shape is RectangleShape2D:
		collider_extents = collider.shape.extents
	else:
		push_warning("Non-rectangle collider – clamping logic may be inaccurate.")

	var min = ScreenBounds.rect.position + collider_extents
	var max = ScreenBounds.rect.position + ScreenBounds.rect.size - collider_extents

	# Clamp position and prevent repeated print spam
	if global_position.x < min.x or global_position.x > max.x \
	or global_position.y < min.y or global_position.y > max.y:
		if not was_outside_bounds:
			print("Dog found boundary")
			was_outside_bounds = true
	else:
		was_outside_bounds = false

	global_position = global_position.clamp(min, max)


func pick_weighted_behavior():
	var total_weight = 0
	for b in behavior_pool:
		total_weight += b.weight

	var roll = randi() % total_weight
	var current = 0

	for b in behavior_pool:
		current += b.weight
		if roll < current:
			return b

	return behavior_pool[0]  # Fallback


func _start_behavior():
	var behavior = pick_weighted_behavior()
	match behavior.type:
		"idle":
			_play_idle(behavior.anim)
		"move":
			_start_move(behavior.anim)
		"jump":
			_start_jump()


func _play_idle(anim_name):
	is_moving = false
	sprite.play(anim_name)
	print(anim_name)

	await get_tree().create_timer(randf_range(idle_time_range.x, idle_time_range.y)).timeout

	if anim_name == "RunFast" or anim_name == "Jump":
		_sitting_sequence()
	else:
		_start_behavior()


func _sitting_sequence():
	sprite.play("Sit")
	print("Sitting")
	await get_tree().create_timer(0.6).timeout

	sprite.play("Sat")
	await get_tree().create_timer(randf_range(1.5, 5.0)).timeout

	_start_behavior()


func _start_move(anim_name):
	is_moving = true
	sprite.play(anim_name)
	print(anim_name)

	var move_dir = randf_range(-1.0, 1.0)
	direction = Vector2(move_dir, 0).normalized()
	sprite.flip_h = direction.x < 0

	speed = 40.0 if anim_name == "Walk" else 60.0 if anim_name == "Run" else 90.0
	velocity = direction * speed

	await get_tree().create_timer(randf_range(move_time_range.x, move_time_range.y)).timeout

	is_moving = false
	_start_behavior()


func _start_jump():
	is_moving = true
	print("Jumping")
	sprite.play("Jump")
	velocity = Vector2(0, -150)

	while not is_on_floor():
		await get_tree().process_frame

	is_moving = false
	_sitting_sequence()
	
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			is_being_dragged = true
			drag_offset = global_position - get_global_mouse_position()
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			is_being_dragged = false
			
func _unhandled_input(event):
	if is_being_dragged and event is InputEventMouseMotion:
		global_position = get_global_mouse_position() + drag_offset
	
	if is_being_dragged:
		print("Dragging dog to ", global_position)

		
