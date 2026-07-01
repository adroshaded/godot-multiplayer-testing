extends Control

func _on_server_pressed() -> void:
	NetworkService.startServer()
	$id.text = "id: " + str(multiplayer.get_unique_id()) + " (server)"
	print("attempt server start (", multiplayer.get_unique_id(), ")")

func _on_client_pressed() -> void:
	NetworkService.startClient()
	$id.text = "id: " + str(multiplayer.get_unique_id())
	print("attempt client start (", multiplayer.get_unique_id(), ")")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Ctrl"):
		visible = !visible
