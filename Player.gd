extends RigidBody2D

signal fell
signal touch(pos)

const kb_speed = 20
const speed_limit = 1000

var screen_size # Size of the game window.
var initial_touch_position := Vector2.ZERO
var current_touch_position
var is_touching := false
var is_dead := false
var start_position

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	process_mode = Node.PROCESS_MODE_DISABLED
	hide()

# Called every frame. Controls for keyboard and reset logic
func _integrate_forces(s):
	if is_dead:
		linear_velocity = Vector2.ZERO
		angular_velocity = 0
		position = start_position
		rotation = 0
	else:
		var lv = s.get_linear_velocity()
		if Input.is_action_pressed("move_right"):
			lv.x += kb_speed
		if Input.is_action_pressed("move_left"):
			lv.x -= kb_speed
		if Input.is_action_pressed("move_down"):
			lv.y += kb_speed
		if Input.is_action_pressed("move_up"):
			lv.y -= kb_speed
		s.set_linear_velocity(lv)
		
	position = position.clamp(Vector2(20,30), screen_size - Vector2(20, 0))
	linear_velocity = linear_velocity.clamp(Vector2(-speed_limit, -speed_limit), Vector2(speed_limit, speed_limit))

#TouchScreen Input
func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			# Start touch
			initial_touch_position = event.position
			is_touching = true
			touch.emit(initial_touch_position)
		else:
			# End touch
			is_touching = false
			current_touch_position = null
			touch.emit(Vector2.INF)
	elif event is InputEventScreenDrag and is_touching:
		# Update touch position
		current_touch_position = event.position

func _process(delta):
	if is_touching and current_touch_position != null and !is_dead :
		var direction = current_touch_position - initial_touch_position
		apply_joystick_force(direction)

func apply_joystick_force(direction):
	# Normalize direction to get the direction vector
	var normalized_direction = direction.normalized()
	var force_magnitude = direction.length()
	
	var force = normalized_direction * force_magnitude * 1 # Adjust the multiplier as needed
	# Apply force to the character
	apply_force(force)

func start(pos):
	show()
	start_position = pos
	position = start_position
	$CollisionShape2D.disabled = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	is_dead = false

func _on_death_box_body_entered(body):
	is_dead = true
	hide() # Player disappears after being hit.
	fell.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
