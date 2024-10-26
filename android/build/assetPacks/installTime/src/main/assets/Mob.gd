extends RigidBody2D

signal splash

var isBigPenguin : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var deathBox = get_parent().get_node("DeathBox")
	deathBox.body_entered.connect(on_deathbox_entered)
	
	$AnimatedSprite2D.play("walk")

func on_deathbox_entered(body):
	if body != self:
		return
	
	await get_tree().create_timer(0.2).timeout
	var splash_size = 2 if isBigPenguin else 1
	splash.emit(position, splash_size)
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
