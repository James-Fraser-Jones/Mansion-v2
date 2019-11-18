extends Spatial

export var x_lock = 45
export var x_inc = 15
export var x_speed = 5
export var y_inc = 90
export var y_speed = 5

enum {UP, DOWN, LEFT, RIGHT}

var turn_dir = UP
var turn_degree = 0

func _input(event: InputEvent) -> void:
	if turn_degree <= 0:
		if event.is_action_pressed("num_left"):
			turn_dir = LEFT
			turn_degree = y_inc
		if event.is_action_pressed("num_right"):
			turn_dir = RIGHT
			turn_degree = y_inc
		if event.is_action_pressed("num_up"):
			turn_dir = UP
			turn_degree = x_inc
		if event.is_action_pressed("num_down"):
			turn_dir = DOWN
			turn_degree = x_inc

func _process(delta: float) -> void:
	if turn_degree > 0:
		var turn_inc
		var turn_speed
		match turn_dir:
			UP, DOWN:
				turn_inc = x_inc
				turn_speed = x_speed
			LEFT, RIGHT:
				turn_inc = y_inc
				turn_speed = y_speed
		var turn_chunk = min(turn_inc * turn_speed * delta, turn_degree)
		turn_camera(turn_dir, turn_chunk, x_lock)
		turn_degree -= turn_chunk

func turn_camera(dir: int, deg: float, x_lock: float) -> void:
	match dir:
		UP: rotate_object_local(Vector3.RIGHT, toRad(max(-deg, -x_lock - rotation_degrees.x)))
		DOWN: rotate_object_local(Vector3.RIGHT, toRad(min(deg, x_lock - rotation_degrees.x)))
		LEFT: rotate(Vector3.UP, toRad(-deg))
		RIGHT: rotate(Vector3.UP, toRad(deg))

func toRad(deg: float) -> float:
	return deg * PI / 180