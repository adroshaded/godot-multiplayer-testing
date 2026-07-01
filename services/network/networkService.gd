extends Node

var player : Player = PlayerService.localPlayer

var host : Player
var connection : ENetConnection

func startServer(address : String = "127.0.0.1", port : int = 42069) -> void:
	connection = ENetConnection.new()
	connection.create_host_bound(address, port, 3)
	host = player

func startClient(address : String = "127.0.0.1", port : int = 42069) -> void:
	connection = ENetConnection.new()
	connection.create_host(1)
	connection.connect_to_host(address, port)
