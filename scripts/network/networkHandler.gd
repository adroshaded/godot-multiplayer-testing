extends Node

var ip = "localhost"
var port = 42069

var peer : ENetMultiplayerPeer

func startServer() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer

func startClient() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
