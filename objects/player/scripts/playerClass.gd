@icon("res://objects/player/assets/class/icon.svg")

class_name Player
extends Node

# scenes to copy
var baseCamera : PackedScene = preload("res://objects/camera/camera.tscn")
var baseCharacter : PackedScene = preload("res://objects/character/character.tscn")

# variables
var character : CharacterBody3D
var camera : Camera3D

func setupCamera() -> void:
	camera.set_meta("owner", self)
	camera.subject = character

func setupCharacter() -> void:
	character.set_meta("owner", self)
	character.position = Vector3(0,1,0)

func _ready() -> void:
	var workspace = get_node("/root/main/workspace")
	
	camera = baseCamera.instantiate()
	character = baseCharacter.instantiate()
	
	workspace.add_child(camera, true)
	workspace.add_child(character, true)
	
	setupCamera()
	setupCharacter()
	
	print("lala")
