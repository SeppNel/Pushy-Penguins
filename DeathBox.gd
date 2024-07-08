extends Area2D

const waterRatio = 0.2

var screen_size

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	position.y = screen_size.y
	$WaterTexture.position.y = screen_size.y * (1 - waterRatio) - screen_size.y
	$CollisionShape2D.shape.extents = Vector2(screen_size.x, screen_size.y * waterRatio / 2 - 25)
	$CollisionShape2D.position.y = -($CollisionShape2D.shape.get_rect().size.y) / 2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	"""
	screen_size = get_viewport_rect().size
	position.y = screen_size.y
	"""
