@tool
extends RigidBody2D

signal despawned(id)

var id: int
const water = preload("res://Water_Splash.tscn")

@export var isBigPenguin : bool = false:
	set(value):
		isBigPenguin = value
		updateScale()

enum ANIMATION {
	WALK_DOWN,
	WALK_UP
}
const anim_map = {
	ANIMATION.WALK_DOWN: "walk",
	ANIMATION.WALK_UP: "up"
}

func init(deathBox, anim: ANIMATION = ANIMATION.WALK_DOWN):
	deathBox.body_entered.connect(on_deathbox_entered)
	$AnimatedSprite2D.play(anim_map[anim])

func _ready():
	updateScale()
	pass

func on_deathbox_entered(body):
	if body != self:
		return
	
	await get_tree().create_timer(0.2).timeout
	var splash_size = 1
	if isBigPenguin:
		splash_size = 2
		
	instanciateSplash(splash_size)
	queue_free()
	despawned.emit(id)

func instanciateSplash(splash_size: int):
	var instance = water.instantiate()
	instance.position = position
	instance.position.y += 10
	instance.scale = Vector2(splash_size,splash_size)
	instance.scale_amount_min = splash_size
	instance.emitting = true
	add_sibling(instance)
	
func updateScale():
	if isBigPenguin:
		$AnimatedSprite2D.scale = Vector2(0.1, 0.1)
		$CollisionShape2D.scale = Vector2(1, 1)
		$Shadow.scale = Vector2(0.6, 0.45)
		$Shadow.modulate = Color(1, 1, 1, 0.35)
	else:
		$AnimatedSprite2D.scale = Vector2(0.05, 0.05)
		$CollisionShape2D.scale = Vector2(0.5, 0.5)
		$Shadow.scale = Vector2(0.4, 0.3)
		$Shadow.modulate = Color(1, 1, 1, 0.23)
	
	notify_property_list_changed()
