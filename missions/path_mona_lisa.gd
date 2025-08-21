@tool
extends Path2D

@export_file("*.json") var json_file := "res://missions/mona_lisa.json"
@export var min_point_spacing: float = 1.0  # skip points closer than this (pixels)

func _ready() -> void:
	if Engine.is_editor_hint():
		_build_curve()

func _build_curve() -> void:
	var fa := FileAccess.open(json_file, FileAccess.READ)
	if fa == null:
		push_error("Could not open file: %s" % json_file)
		return

	var data = JSON.parse_string(fa.get_as_text())
	if typeof(data) != TYPE_ARRAY:
		push_error("Invalid JSON format (expected a flat [ [x,y], ... ] array).")
		return

	var curve := Curve2D.new()
	var last_added := Vector2.INF

	for p in data:
		if typeof(p) != TYPE_ARRAY or p.size() < 2:
			continue
		var v := Vector2(float(p[0]), float(p[1]))
		if last_added == Vector2.INF or v.distance_to(last_added) >= min_point_spacing:
			curve.add_point(v)
			last_added = v

	self.curve = curve
