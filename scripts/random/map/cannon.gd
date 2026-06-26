extends Node3D

@export var pillsContainer : Node3D
@export var fatass : Node3D

@onready var head = $head
var power = 120

func applyVelocity(pill : RigidBody3D) -> void:
	var dir = Vector3(
		-sin(head.rotation.z),
		0,
		0
	)
	pill.apply_impulse(dir * power)

func resetPills() -> void:
	for i : RigidBody3D in pillsContainer.get_children():
		i.position = i.get_meta("originalPosition")
		i.linear_velocity = Vector3.ZERO
		i.angular_velocity = Vector3.ZERO
	fatass.position = fatass.get_meta("originalPosition")
	fatass.linear_velocity = Vector3.ZERO
	fatass.angular_velocity = Vector3.ZERO

func _ready() -> void:
	for i in pillsContainer.get_children():
		i.set_meta("originalPosition", i.position)
	fatass.set_meta("originalPosition", fatass.position)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("3"):
		for i in pillsContainer.get_children():
			applyVelocity(i)
	if Input.is_action_just_pressed("R"):
		resetPills()
