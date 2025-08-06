extends CanvasLayer

var playing : bool = true
var hue : float = 0.00

func _process(delta):
	if $CompleteLabel.visible: # Rainbow effect for NewHighscore
		var shadowColor = Color.from_hsv(hue, 1, 1, 1)
		$CompleteLabel.add_theme_color_override("font_shadow_color", shadowColor)
		
		hue += 0.1 * delta
		if hue > 1.0:
			hue = 0.00

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func update_score(score):
	$ScoreLabel.text = str(score)

func _on_retry_button_pressed():
	get_tree().reload_current_scene()

func _on_message_timer_timeout():
	$Message.hide()

func show_origin_marker(pos):
	if playing:
		$OriginMarker.position = pos
		$OriginMarker.show()
	
func hide_origin_marker():
	$OriginMarker.hide()

func hideAllButScore():
	$RetryButton.hide()
	$BackButton.hide()
	$CompleteLabel.hide()
	$OriginMarker.hide()
	
func showAll():
	$RetryButton.show()
	$BackButton.show()
	$CompleteLabel.show()
	$OriginMarker.show()

func showFailedMenu(lastMission: bool = false):
	playing = false
	$RetryButton.show()
	$BackButton.show()
	$Message.text = "Mission Failed"
	$MessageTimer.stop()
	$Message.show()
	if not lastMission:
		$NextButton.show()
	
	$CompleteLabel.hide()
	$OriginMarker.hide()

func showCompleteMenu(lastMission: bool = false):
	playing = false
	$RetryButton.show()
	$BackButton.show()
	$CompleteLabel.show()
	if not lastMission:
		$NextButton.show()
	
	$Message.hide()
	$OriginMarker.hide()
	
func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			# Start touch
			show_origin_marker(event.position)
		else:
			# End touch
			hide_origin_marker()
