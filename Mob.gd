extends RigidBody2D

signal splash

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

	splash.emit(position, splash_size)
	queue_free()
