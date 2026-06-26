extends Node3D

@export var holder : CSGBox3D

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("3"):
		holder.use_collision = false
		holder.visible = false
	if Input.is_action_just_pressed("R"):
		holder.use_collision = true
		holder.visible = true
