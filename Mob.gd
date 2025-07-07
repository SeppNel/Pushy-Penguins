extends RigidBody2D

const water = preload("res://Water_Splash.tscn")

var isBigPenguin : bool = false

func init(deathBox):
	deathBox.body_entered.connect(on_deathbox_entered)

func _ready():
	$AnimatedSprite2D.play("walk")

func on_deathbox_entered(body):
	if body != self:
		return
	
	await get_tree().create_timer(0.2).timeout
	var splash_size = 1
	if isBigPenguin:
		splash_size = 2
		
	instanciateSplash(splash_size)
	queue_free()

func instanciateSplash(splash_size: int):
	var instance = water.instantiate()
	instance.position = position
	instance.position.y += 10
	instance.scale = Vector2(splash_size,splash_size)
	instance.scale_amount_min = splash_size
	instance.emitting = true
	add_sibling(instance)
