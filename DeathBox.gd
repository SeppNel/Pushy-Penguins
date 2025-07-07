extends Area2D

@export var WATER_RATIO = 0.2

var screen_size

func _ready():
	screen_size = get_viewport_rect().size
	position.y = screen_size.y
	$WaterTexture.position.y = screen_size.y * (1 - WATER_RATIO) - screen_size.y
	$CollisionShape2D.shape.extents = Vector2(screen_size.x, screen_size.y * WATER_RATIO / 2 - 25)
	$CollisionShape2D.position.y = -($CollisionShape2D.shape.get_rect().size.y) / 2
