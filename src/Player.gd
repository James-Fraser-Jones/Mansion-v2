extends KinematicBody

export var speed = 30

var mouse_pos: Vector2
var ray_length: float = 1000
onready var PlayerCamera: Camera = get_node("PlayerCameraPivot/PlayerCamera")
onready var PlayerCameraPivot = get_node("PlayerCameraPivot")
onready var FlashLight = get_node("FlashLight")

func _physics_process(delta: float) -> void:
	var x = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y = Input.get_action_strength("backward") - Input.get_action_strength("forward")
	if x != 0 or y != 0:
		slide(x,y,speed,PlayerCameraPivot.rotation.y)
	
	var from = PlayerCamera.project_ray_origin(mouse_pos)
	var to = from + PlayerCamera.project_ray_normal(mouse_pos) * ray_length
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, [], 4)
	if result: 
		var xdiff = result.position.x - global_transform.origin.x
		var zdiff = result.position.z - global_transform.origin.z
		var angle = atan2(zdiff, xdiff) + PI/2
		FlashLight.set_rotation(Vector3(0, -angle, 0))

func slide(x: float, y: float, speed: float, rotation: float) -> void:
	var angle = atan2(y,x)
	var direction = Vector3(cos(angle), 0, sin(angle))
	move_and_slide(speed * direction.rotated(Vector3.UP, rotation))

func _input(event):
	if event is InputEventMouseMotion: 
		mouse_pos = event.position
	