extends CharacterBody3D

@onready var cam : Camera3D = $"../camera" # : Camera3D

var speed = 10.0
var inputVector = Vector2.ZERO
var lookDir = Vector2.ZERO
var walkDir = Vector2.ZERO
var fallAccel = 35
var jumpHeight = 10

func _enter_tree() -> void:
	print(name, " (", multiplayer.get_unique_id(), ")")
	set_multiplayer_authority(int(name))

func _ready() -> void:
	if is_multiplayer_authority():
		cam.subject = self
		position = Vector3(0, 10, 0)

func _physics_process(delta: float) -> void:
	if multiplayer.get_peers() and !is_multiplayer_authority():
		process_mode = Node.PROCESS_MODE_DISABLED
		return
	
	lookDir = Vector2(-sin(cam.rotation.y), -cos(cam.rotation.y))
	inputVector = Input.get_vector("A", "D", "W", "S").normalized()
	walkDir = Vector2(-lookDir.x * inputVector.y - lookDir.y * inputVector.x, -lookDir.y * inputVector.y + lookDir.x * inputVector.x)
	velocity = Vector3(
		walkDir.x * speed,
		velocity.y,
		walkDir.y * speed
	)
	
	if Input.is_action_pressed("Space") and is_on_floor():
		velocity.y = jumpHeight
	
	if !is_on_floor():
		velocity.y -= fallAccel * delta
	else:
		velocity.y = max(velocity.y, 0)
	
	var oldVel = velocity
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var normal = collision.get_normal()
		var object = collision.get_collider()
		var f = oldVel.length() * oldVel.normalized().dot(normal)
		if object is RigidBody3D:
			object.apply_central_impulse(normal * f * object.mass)
