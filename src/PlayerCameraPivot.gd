extends Spatial

var increment = 15
var x_lock = 45

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("num_left"):
		rotate(Vector3.UP, toRad(-increment))
	if event.is_action_pressed("num_right"):
		rotate(Vector3.UP, toRad(increment))
	if event.is_action_pressed("num_up"):
		rotate_object_local(Vector3.RIGHT, toRad(max(-increment, -x_lock - rotation_degrees.x)))
	if event.is_action_pressed("num_down"):
		rotate_object_local(Vector3.RIGHT, toRad(min(increment, x_lock - rotation_degrees.x)))
		
func toRad(deg: float) -> float:
	return deg * PI / 180