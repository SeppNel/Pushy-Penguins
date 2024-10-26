extends CanvasLayer

# Notifies `Main` node that the button has been pressed
signal start_game

var playing : bool = false
var hue : float = 0.00
var adView = null
var initialScorePosition

func _ready():
	initialScorePosition = $ScoreLabel.position
	MobileAds.initialize()

func _process(delta):
	if $NewHighScore.visible: # Rainbow effect for NewHighscore
		var shadowColor = Color.from_hsv(hue, 1, 1, 1)
		$NewHighScore.add_theme_color_override("font_shadow_color", shadowColor)
		
		hue += 0.1 * delta
		if hue > 1.0:
			hue = 0.00

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	
func update_high_score(score : int):
	$HighScoreMsg.text = "HighScore: " + str(score)
	
func show_game_over():
	var fontColor : Color = Color(1, 0 , 0, 1)
	$Message.add_theme_color_override("font_color", fontColor)
	$Message.add_theme_constant_override("shadow_offset_x", 1)
	$Message.add_theme_constant_override("shadow_offset_y", 45)
	show_message("Game Over")
	playing = false
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout
	$ScoreLabel.position.y += 100
	create_ad()
	
	$Message.remove_theme_color_override("font_color")
	$Message.add_theme_constant_override("shadow_offset_x", 6)
	$Message.add_theme_constant_override("shadow_offset_y", 6)
	$Message.text = "Pushy Penguins!"
	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(0.5).timeout
	$StartButton.show()
	
func update_score(score):
	$ScoreLabel.text = str(score)

func _on_start_button_pressed():
	$ScoreLabel.position = initialScorePosition
	$StartButton.hide()
	$HighScoreMsg.hide()
	$NewHighScore.hide()
	playing = true
	start_game.emit()
	
	destroy_ad()

func _on_message_timer_timeout():
	$Message.hide()

func show_origin_marker(pos):
	if playing:
		$OriginMarker.position = pos
		$OriginMarker.show()
	
func hide_origin_marker():
	$OriginMarker.hide()
	
func create_ad():
	var unit_id : String
	unit_id = "ca-app-pub-1191566520138423/9053040772"
	#unit_id = "ca-app-pub-3940256099942544/6300978111" # Test Ad

	adView = AdView.new(unit_id, AdSize.BANNER, AdPosition.Values.TOP)
	adView.load_ad(AdRequest.new())
	
func destroy_ad():
	if adView == null:
		return
		
	adView.destroy()
	adView = null
