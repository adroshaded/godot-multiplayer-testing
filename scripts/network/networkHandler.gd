extends Node

# servver signals
signal peerConnected(id : int)
signal peerDisconnected(id : int)
signal packetRecieved(from : int, packet : PackedByteArray)

# client signals
signal clientConnected()
signal clientDisconnected()

# server variables
var availablePeerIds = range(255, -1, -1)
var clientPeers = {}

# client variables
var serverPeer : ENetPacketPeer

# general variables
var connection : ENetConnection
var isServer = false

func startServer(address : String = "127.0.0.1", port : int = 42069):
	connection = ENetConnection.new()
	connection.create_host_bound(address, port)
	isServer = true

func startClient(address : String = "127.0.0.1", port : int = 42069):
	connection = ENetConnection.new()
	connection.create_host(1)
	serverPeer = connection.connect_to_host(address, port)

func onPeerConnect(peer : ENetPacketPeer):
	var id = availablePeerIds.pop_back()
	peer.set_meta("id", id)
	clientPeers[id] = peer
	
	peerConnected.emit(id)

func onPeerDisconnect(peer : ENetPacketPeer):
	var id = peer.get_meta("id")
	availablePeerIds.push_back(id)
	clientPeers.erase(id)
	
	peerDisconnected.emit(id)

func clientOnConnect():
	clientConnected.emit()

func clientOnDisconnect():
	clientDisconnected.emit()
	connection = null

func handleEvents():
	var packetEvent = connection.service()
	var eventType = packetEvent[0]
	
	while eventType != ENetConnection.EVENT_NONE:
		var peer = packetEvent[1]
		
		match eventType:
			ENetConnection.EVENT_ERROR:
				push_warning("something something packet error")
			ENetConnection.EVENT_CONNECT:
				if isServer:
					onPeerConnect(peer)
				else:
					clientOnConnect()
			ENetConnection.EVENT_DISCONNECT:
				if isServer:
					onPeerDisconnect(peer)
				else:
					clientOnDisconnect()
					return
			ENetConnection.EVENT_RECEIVE:
				if isServer:
					packetRecieved.emit(peer.get_meta("id"), peer.get_packet())

func _process(delta: float) -> void:
	if !connection:
		return
