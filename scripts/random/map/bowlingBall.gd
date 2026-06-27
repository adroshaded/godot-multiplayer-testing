extends RigidBody3D

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("3"):
		linear_velocity = Vector3(0,0,-10)
