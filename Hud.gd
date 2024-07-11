extends CanvasLayer

# Notifies `Main` node that the button has been pressed
signal start_game

var playing : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	
func update_high_score(score : int):
	$HighScoreMsg.text = "HighScore: " + str(score)
	
func show_game_over():
	show_message("Game Over")
	playing = false
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout

	$Message.text = "Pushy Penguins!"
	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(0.5).timeout
	$StartButton.show()
	
func update_score(score):
	$ScoreLabel.text = str(score)

func _on_start_button_pressed():
	$StartButton.hide()
	playing = true
	start_game.emit()

func _on_message_timer_timeout():
	$Message.hide()

func show_origin_marker(pos):
	if playing:
		$OriginMarker.position = pos
		$OriginMarker.show()
	
func hide_origin_marker():
	$OriginMarker.hide()
