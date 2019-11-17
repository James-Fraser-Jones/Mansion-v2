extends Camera

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("num_centre"):
		toggleProjection()

func toggleProjection() -> void:
	match self.projection:
		PROJECTION_PERSPECTIVE:
			set_orthogonal(self.size, self.near, self.far)
		PROJECTION_ORTHOGONAL:
			set_perspective(self.fov, self.near, self.far)
