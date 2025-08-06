extends Line2D

var path
var path_follow

const POINTS_PER_UNIT = 20  # Higher value = smoother line

func _ready() -> void:
	path = get_parent()
	path_follow = path.get_node("PathFollow2D")

func _process(delta):
	# Draw progressed path
	draw_progressed_path(path_follow.progress_ratio)


func draw_progressed_path(progress_ratio: float):
	var curve = path.curve
	var baked_points = curve.get_baked_points()
	if baked_points.size() < 2:
		return

	# Determine how many points to draw based on progress
	var total_length = curve.get_baked_length()
	var max_length = total_length * progress_ratio

	var points_to_draw := []
	var current_length := 0.0

	for i in range(baked_points.size() - 1):
		var p1 = baked_points[i]
		var p2 = baked_points[i + 1]
		var segment_length = p1.distance_to(p2)

		if current_length + segment_length > max_length:
			# Interpolate partial segment
			var remaining = max_length - current_length
			var direction = (p2 - p1).normalized()
			var interpolated_point = p1 + direction * remaining
			points_to_draw.append(p1)
			points_to_draw.append(interpolated_point)
			break
		else:
			points_to_draw.append(p1)
			current_length += segment_length

	points = points_to_draw
