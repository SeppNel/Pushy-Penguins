extends CanvasLayer

# Notifies `Main` node that the button has been pressed
signal start_game
signal settings_changed(reset : bool)

var playing : bool = false
var hue : float = 0.00
var adView = null
var ads_shown : int = 0

func _ready():
	MobileAds.initialize()
	create_adView()
	$HTTPRequest.request_completed.connect(_on_leaderboard_request_completed)

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
	$SettingsButton.show()
	$LeaderboardButton.show()
	
func update_score(score):
	$ScoreLabel.text = str(score)

func _on_start_button_pressed():
	$StartButton.hide()
	$HighScoreMsg.hide()
	$NewHighScore.hide()
	$SettingsButton.hide()
	$LeaderboardButton.hide()
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

func toggle_non_overlay_visibility():
	$SettingsButton.visible = !$SettingsButton.visible
	$LeaderboardButton.visible = !$LeaderboardButton.visible
	$Message.visible = !$Message.visible
	$HighScoreMsg.visible = !$HighScoreMsg.visible
	$StartButton.visible = !$StartButton.visible
	$ScoreLabel.visible = !$ScoreLabel.visible

func _on_settings_button_pressed():
	toggle_non_overlay_visibility()
	$Settings.show()

func _on_close_settings_button_pressed():
	toggle_non_overlay_visibility()
	$Settings.hide()
	settings_changed.emit(false)

func _on_leaderboard_button_pressed():
	toggle_non_overlay_visibility()
	load_leaderboard()
	$Leaderboard.show()


func _on_close_leaderboard_button_pressed():
	var children = $Leaderboard/ScrollContainer/VBoxContainer.get_children()
	for child in children:
		if child is Label:
			child.free()
	
	toggle_non_overlay_visibility()
	$Leaderboard.hide()


func load_leaderboard():
	$HTTPRequest.request("http://pertusa.myftp.org/.resources/php/ppp/leaderboard_get.php")

func _on_leaderboard_request_completed(result, response_code, headers, body):
	var lb = JSON.parse_string(body.get_string_from_utf8())
	var i = 1
	for name in lb:
		var score = lb[name]

		var label = Label.new()
		label.text = str(i) + "º - " + str(name) + ": " + str(score)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var f = load("res://fonts/Xolonium-Regular.ttf") as FontFile
		label.add_theme_font_override("font", f)
		label.set("theme_override_font_sizes/font_size", 30)
		
		$Leaderboard/ScrollContainer/VBoxContainer.add_child(label)
		i += 1



func _on_reset_score_button_pressed():
	update_high_score(0)
	settings_changed.emit(true)
	
