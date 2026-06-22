extends MultiplayerSpawner

@export var networkPlayer : PackedScene

func spawnPlayer(id : int) -> void:
	if !multiplayer.is_server(): # only server runs the code
		return
	
	#print(multiplayer.get_unique_id())
	
	var player: Node = networkPlayer.instantiate()
	player.name = str(id)
	
	get_node(spawn_path).call_deferred("add_child", player)

func _ready() -> void:
	multiplayer.peer_connected.connect(spawnPlayer)
