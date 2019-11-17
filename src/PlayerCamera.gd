extends Camera

var initSize = size #20
var initFOV = fov 	#50

var zoom = 1
var zoom_min = 0
var zoom_max = 2
var zoom_inc = 0.2

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("num_centre"):
		toggleProjection()
	if event.is_action_pressed("num_top_right"):
		zoom(-zoom_inc)
	if event.is_action_pressed("num_bottom_right"):
		zoom(zoom_inc)

func toggleProjection() -> void:
	match projection:
		PROJECTION_PERSPECTIVE:
			set_orthogonal(size, near, far)
		PROJECTION_ORTHOGONAL:
			set_perspective(fov, near, far)

func zoom(inc: float) -> void:
	zoom = clamp(zoom + inc, zoom_min, zoom_max)
	size = initSize * zoom
	fov = initFOV * zoom