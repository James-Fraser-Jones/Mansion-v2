extends KinematicBody

export var speed = 30

onready var PlayerCameraPivot = get_node("PlayerCameraPivot")

func _physics_process(delta: float) -> void:
	var x = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y = Input.get_action_strength("backward") - Input.get_action_strength("forward")
	if x != 0 or y != 0:
		var angle = atan2(y,x)
		var direction = Vector3(cos(angle), 0, sin(angle))
		move_and_slide(speed * direction.rotated(Vector3.UP, PlayerCameraPivot.rotation.y))