extends Node

@onready var cam : Camera3D = $".."

var firstPerson = false

func _unhandled_input(event: InputEvent) -> void:
	if !PlayerService.isNodeOwnedByPlayer(cam, PlayerService.localPlayer):
		return
	
	if event is InputEventKey:
		if (event.is_action("Alt") or event.is_action("Esc")) and event.is_pressed():
			cam.toggleMouseLock()

func _process(_delta: float) -> void:
	if !PlayerService.isNodeOwnedByPlayer(cam, PlayerService.localPlayer):
		return
	
	if cam.zoomDist <= .1:
		cam.relativeOffset = Vector3.ZERO
	else:
		cam.relativeOffset = Vector3(1.1,0,0)
