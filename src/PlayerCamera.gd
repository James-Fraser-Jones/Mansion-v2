extends Camera

export var zoom_min = 0
export var zoom_max = 2
export var zoom_inc = 0.2
export var zoom_speed = 5

var initSize = size #20
var initFOV = fov 	#50
var zoom = 1

enum {IN, OUT}

var zoom_dir = IN
var zoom_degree = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("num_centre"):
		toggleProjection()
	if event.is_action_pressed("num_top_right"):
		zoom_dir = IN
		zoom_degree = zoom_inc
	if event.is_action_pressed("num_bottom_right"):
		zoom_dir = OUT
		zoom_degree = zoom_inc
		
func _process(delta: float) -> void:
	if zoom_degree > 0:
		var zoom_chunk = min(zoom_inc * zoom_speed * delta, zoom_degree)
		zoom(zoom_chunk if zoom_dir == OUT else -zoom_chunk)
		zoom_degree -= zoom_chunk

func zoom(inc: float) -> void:
	zoom = clamp(zoom + inc, zoom_min, zoom_max)
	size = initSize * zoom
	fov = initFOV * zoom

func toggleProjection() -> void:
	match projection:
		PROJECTION_PERSPECTIVE:
			set_orthogonal(size, near, far)
		PROJECTION_ORTHOGONAL:
			set_perspective(fov, near, far)