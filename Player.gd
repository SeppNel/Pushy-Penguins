extends RigidBody2D

signal fell
signal touch(pos)
signal splash(pos, size)

const SPEED_LIMIT = 1000
const MIN_SCREEN_CLAMP_OFFSET = Vector2(20, 30) # Left, Top
const MAX_SCREEN_CLAMP_OFFSET = Vector2(20, 0) # Right, Bottom
const ROTATION_CAP = 0.5
const ROTATION_SPEED = 100.0  # Adjust for smoother or faster rotation
const ROTATION_AV_CAP = 4.0
#const ROTATION_SPRITES = ["up", "upright", "right", "downright", "down", "downleft", "left", "upleft", "up"]
const ROTATION_SPRITES = ["up", "up", "up", "down", "down", "down", "down", "up", "up"]

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
	$AnimatedSprite2D.play("down")
	hide()

func handleRotation():
	# Smooth rotation to 0 (Look forward)
	rotation = clamp(rotation, -ROTATION_CAP, ROTATION_CAP)
	var angle_diff = angle_difference(rotation, 0)
	var torque = angle_diff * ROTATION_SPEED
	apply_torque_impulse(torque)

	# Clamping like before causes weird behaivour, so manual it is
	if angular_velocity > ROTATION_AV_CAP:
		angular_velocity = ROTATION_AV_CAP
	elif angular_velocity < -ROTATION_AV_CAP:
		angular_velocity = -ROTATION_AV_CAP

# Called every frame.
func _integrate_forces(s):
	if is_dead:
		linear_velocity = Vector2.ZERO
		angular_velocity = 0
		position = start_position
		rotation = 0
	
	# Stop sideways velocity at borders
	if position.x < MIN_SCREEN_CLAMP_OFFSET.x || position.x > screen_size.x - MAX_SCREEN_CLAMP_OFFSET.x:
		linear_velocity.x = 0
	
	# Limit position to screen borders and velocity to custom limit
	position = position.clamp(MIN_SCREEN_CLAMP_OFFSET, screen_size - MAX_SCREEN_CLAMP_OFFSET)
	linear_velocity = linear_velocity.clamp(Vector2(-SPEED_LIMIT, -SPEED_LIMIT), Vector2(SPEED_LIMIT, SPEED_LIMIT))

	# Handle player rotation, we want to woddle a bit but still look forward
	handleRotation()

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

func sprite_rotation():
	var angle = rad_to_deg(linear_velocity.angle()) + 90 # +90 bcs 0 is right and I want it up
	if angle < 0:
		angle += 360
	var angle_index = round(angle / 45)
	$AnimatedSprite2D.play(ROTATION_SPRITES[angle_index])

func _process(delta):
	if is_touching and current_touch_position != null and !is_dead :
		var direction = current_touch_position - initial_touch_position
		apply_joystick_force(direction)
		
	sprite_rotation()

func apply_joystick_force(direction):
	# Normalize direction to get the direction vector
	var normalized_direction = direction.normalized()
	var force_magnitude = direction.length()
	
	var force = normalized_direction * force_magnitude * 0.8 # Adjust the multiplier as needed
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
	if body != self:
		return
		
	splash.emit(position, 1)
	is_dead = true
	hide() # Player disappears after being hit.
	fell.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
