extends Camera3D

# exported variables
@export var subject : Node3D
@export var subjectFollowRotation : bool
@export var offset : Vector3
@export var relativeOffset : Vector3
@export var relativeOffsetAxis : Vector3
@export var mouseLocked : bool
@export var minZoomDist : float
@export var maxZoomDist : float
@export var zoomAdjustDistance : float
@export var easeRotation : bool
@export var easePosition : bool
@export var easeZoom : bool
@export var rotationSmoothness : float
@export var positionSmoothness : float
@export var zoomAdjustSmoothness : float

# hidden variables
var xRotationLimit : float = 85.0 # in degrees
var sensitivity : float = .2

var targetRotation = Vector3.ZERO
var targetPosition = Vector3.ZERO
var targetZoomDist = 0.0
var zoomDist = 0.0
var rightClickPos = Vector2.ZERO

# functions
func getLookDirection(v := Vector3(999,999,999)) -> Vector3:
	if v == Vector3(999,999,999):
		v = rotation
	return Vector3(
		-sin(v.y) * cos(v.x),
		sin(v.x),
		-cos(v.y) * cos(v.x)
	).normalized()

func shouldIgnoreObject(object : Node3D) -> bool:
	if object.has_meta("cameraIgnore") and object.get_meta("cameraIgnore"):
		return true
	if object is GeometryInstance3D and object.transparency != 0:
		return true
	return false

func toggleMouseLock(value : bool = !mouseLocked) -> void:
	mouseLocked = value
	if mouseLocked:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func clipCamera(origin : Vector3, target : Vector3) -> Vector3:
	var extendedDist = 10 # extra distance for the ray check
	var minDist = .125 # how close the camera can get to a surface
	var exceptions = []
	var spaceState = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(origin, origin + (target - origin) * ((origin - target).length() + extendedDist), 1, exceptions)
	var ray = spaceState.intersect_ray(query)
	if !ray.is_empty():
		var currentPosition = null
		while !ray.is_empty(): # checks all the collisions (so the min dist thing gets applied to all* surfaces)
			if shouldIgnoreObject(ray.collider):
				exceptions.append(ray.rid)
				ray = spaceState.intersect_ray(PhysicsRayQueryParameters3D.create(origin, origin + (target - origin) * ((origin - target).length() + extendedDist), 1, exceptions))
				continue
			var colPos = ray.position
			var normal = ray.normal
			var plane = Plane(normal)
			plane.d = minDist + plane.distance_to(colPos)
			var intersectionPoint = plane.intersects_segment(origin, currentPosition if currentPosition != null else colPos)
			if intersectionPoint:
				currentPosition = intersectionPoint
			exceptions.append(ray.rid)
			ray = spaceState.intersect_ray(PhysicsRayQueryParameters3D.create(origin, origin + (target - origin) * ((origin - target).length() + extendedDist), 1, exceptions))
		currentPosition = currentPosition if currentPosition != null else target
		var distance = (origin - currentPosition).length() # extra camera distance check (to counter the distance added to the ray)
		var safeDistance = min(distance, (origin - target).length())
		var safePos = origin + (currentPosition - origin).normalized() * safeDistance
		#zoomDist = (origin - safePos).length() # awesome effect
		return safePos
	return target

func calculateCameraOffset() -> Vector3:
	return offset + (Vector3(
		cos(rotation.y) * cos(rotation.z) * relativeOffset.x + sin(rotation.y) * sin(rotation.x) * relativeOffset.y + cos(rotation.y) * -sin(rotation.z) * relativeOffset.y + cos(rotation.x) * sin(rotation.y) * cos(rotation.z) * relativeOffset.z,
		sin(rotation.z) * relativeOffset.x + cos(rotation.x) * relativeOffset.y + sin(rotation.x) * -relativeOffset.z,
		sin(rotation.y) * cos(rotation.z) * -relativeOffset.x + sin(rotation.x) * cos(rotation.y) * relativeOffset.y + cos(rotation.x) * sin(rotation.y) * sin(rotation.z) * relativeOffset.y + cos(rotation.x) * cos(rotation.y) * cos(rotation.z) * relativeOffset.z
	) * relativeOffsetAxis).normalized() * relativeOffset.length() # normalizing is a hacky thing and i should calculate this properly someday (doesnt work with any x rotation nearing 90 degrees cuz the vector becomes 0)

func _ready() -> void:
	if mouseLocked:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	targetZoomDist = 3.5 #(minZoomDist + maxZoomDist) / 2

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			return
		targetRotation = Vector3(
				clamp(targetRotation.x - deg_to_rad(event.relative.y * sensitivity), -deg_to_rad(xRotationLimit), deg_to_rad(xRotationLimit)),
				targetRotation.y - deg_to_rad(event.relative.x * sensitivity),
				0
			)
	if event is InputEventMouseButton:
		# zooming
		if event.is_pressed():
			if event.is_action("WheelUp"):
				targetZoomDist = max(targetZoomDist - zoomAdjustDistance, minZoomDist)
				return
			if event.is_action("WheelDown"):
				targetZoomDist = min(targetZoomDist + zoomAdjustDistance, maxZoomDist)
				return
		
		# right click stuff
		if event.is_action("M2"):
			if !mouseLocked:
				if event.is_pressed():
					rightClickPos = get_viewport().get_mouse_position()
					Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				else:
					Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
					get_viewport().warp_mouse(rightClickPos)

var subjectWarned = false
func _process(delta: float) -> void:
	if !PlayerService.isNodeOwnedByPlayer(self, PlayerService.localPlayer):
		return
	
	# warnings
	if !subject:
		if !subjectWarned:
			push_warning("no subject")
			subjectWarned = true
		return
	else:
		subjectWarned = false
	
	# zoom
	if easeZoom:
		zoomDist = lerp(zoomDist, targetZoomDist, min(delta * zoomAdjustSmoothness, 1.0))
	else:
		zoomDist = targetZoomDist
	
	# rotation
	if easeRotation:
		rotation = lerp(rotation, targetRotation, min(delta * rotationSmoothness, 1.0))
	else:
		rotation = targetRotation
	
	# position
	### smoothing can look choppy if the object is moving at a lower fps (like a character in physics process)
	### maybe fix by not using lerp? (using the constant speed thing yeah)
	targetPosition = clipCamera(subject.position, subject.position + calculateCameraOffset() + -getLookDirection() * zoomDist)
	if easePosition:
		position = lerp(position, targetPosition, min(delta * positionSmoothness, 1.0))
	else:
		position = targetPosition
	
	# last checks
	if subjectFollowRotation:
		subject.rotation.y = rotation.y
