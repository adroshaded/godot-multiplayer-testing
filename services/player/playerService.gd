extends Node

var localPlayer : Player

func createPlayer() -> Player:
	var player = Player.new()
	get_node("/root/main/players").add_child(player)
	return player

func isNodeOwnedByPlayer(node : Node, player : Player) -> bool:
	if node.has_meta("owner") and node.get_meta("owner") == player:
		return true
	return false

func _ready() -> void:
	localPlayer = createPlayer()
