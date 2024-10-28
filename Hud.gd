extends CanvasLayer

# Notifies `Main` node that the button has been pressed
signal start_game

var playing : bool = false
var hue : float = 0.00
var adView = null
var ads_shown : int = 0

func _ready():
	MobileAds.initialize()

	#$ScoreLabel.position.y = DisplayServer.get_display_safe_area().position.y
	#draw_debug_point()
	#draw_debug_cutout()
	#draw_debug_safe_area()
	create_adView()

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

	show_ad()
	
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
	$StartButton.hide()
	$HighScoreMsg.hide()
	$NewHighScore.hide()
	playing = true
	start_game.emit()
	
	if ads_shown > 0:
		hide_ad()

func _on_message_timer_timeout():
	$Message.hide()

func show_origin_marker(pos):
	if playing:
		$OriginMarker.position = pos
		$OriginMarker.show()
	
func hide_origin_marker():
	$OriginMarker.hide()
	
func create_adView():
	var unit_id : String
	unit_id = "ca-app-pub-1191566520138423/9053040772"
	#unit_id = "ca-app-pub-3940256099942544/6300978111" # Test Ad

	adView = AdView.new(unit_id, AdSize.BANNER, AdPosition.Values.BOTTOM)
	adView.hide()
	await get_tree().create_timer(1).timeout
	adView.load_ad(AdRequest.new())
	
func show_ad():
	ads_shown += 1
	#$ScoreLabel.position.y += adView.get_height()
	adView.show()
	adView.load_ad(AdRequest.new())

func hide_ad():
	adView.hide()
	#$ScoreLabel.position.y -= adView.get_height()

func destroy_ad():
	if adView == null:
		return

	adView.destroy()
	adView = null

func draw_debug_point():
	var debug_point = ColorRect.new()
	debug_point.size = Vector2(5,5)
	debug_point.color = Color.RED
	debug_point.position.x = get_viewport().get_visible_rect().size.x / 2
	debug_point.position.y = DisplayServer.get_display_safe_area().position.y  # Set the position of the debug point
	add_child(debug_point)

func draw_debug_cutout():
	var cutouts = DisplayServer.get_display_cutouts()
	for r in cutouts:
		var debug_point = ColorRect.new()
		debug_point.size = r.size  # Set size from Rect2's size
		debug_point.color = Color.RED
		debug_point.position = r.position
		add_child(debug_point)

func draw_debug_safe_area():
	var safe = DisplayServer.get_display_safe_area()
	var debug_point = ColorRect.new()
	debug_point.size = safe.size
	debug_point.color = Color(0,0,1, 0.5)
	debug_point.position = safe.position
	add_child(debug_point)

