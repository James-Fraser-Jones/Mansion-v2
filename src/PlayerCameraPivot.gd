extends Spatial

var increment = 15 * PI / 180

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("num_up"):
		rotate_x(increment)
	if event.is_action_pressed("num_down"):
		rotate_x(-increment)
	if event.is_action_pressed("num_left"):
		rotate_y(increment)
	if event.is_action_pressed("num_right"):
		rotate_y(-increment)