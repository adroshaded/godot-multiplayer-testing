extends RigidBody3D

@export var body : MeshInstance3D
@export var face : Sprite3D

var pillData = {
	"sword": {
		"color": Color("FF5959"),
		"image": "res://assets/faces/sword.png",
		"imageSize": 1.0
	},
	"skateboard": {
		"color": Color("FF0000"),
		"image": "res://assets/faces/skateboard.png",
		"imageSize": 1.0
	},
	"biograft": {
		"color": Color("FF6A00"),
		"image": "res://assets/faces/biograft.png",
		"imageSize": 1.2
	},
	"katana": {
		"color": Color("AF2020"),
		"image": "res://assets/faces/katana.png",
		"imageSize": 1.6
	},
	"banhammer": {
		"color": Color("3A3A82"),
		"image": "res://assets/faces/banhammer.png",
		"imageSize": .4
	},
	"rocket": {
		"color": Color("527CAE"),
		"image": "res://assets/faces/rocket.png",
		"imageSize": 1.1
	},
	"slingshot": {
		"color": Color("4DA9C3"),
		"image": "res://assets/faces/slingshot.png",
		"imageSize": 1.0
	},
	"hyperlaser": {
		"color": Color("2B90B4"),
		"image": "res://assets/faces/lala.png",
		#"image": "res://assets/faces/hyperlaser.png",
		"imageSize": 2.2 # 2.2 / 1.3
	},
	"shuriken": {
		"color": Color("7CC740"),
		"image": "res://assets/faces/shuriken.png",
		"imageSize": 1.2
	},
	"scythe": {
		"color": Color("278B79"),
		"image": "res://assets/faces/scythe.png",
		"imageSize": 1.2
	},
	"medkit": {
		"color": Color("2CBFA2"),
		"image": "res://assets/faces/medkit.png",
		"imageSize": 1.25
	},
	"boombox": {
		"color": Color("97BF4B"),
		"image": "res://assets/faces/boombox.png",
		"imageSize": 1.2
	},
	"subspace": {
		"color": Color("FF0368"),
		"image": "res://assets/faces/subspace.png",
		"imageSize": 1.3
	},
	"vinestaff": {
		"color": Color("FF5877"),
		"image": "res://assets/faces/vinestaff.png",
		"imageSize": 1.1
	},
	"coil": {
		"color": Color("FF8B35"),
		"image": "res://assets/faces/coil.png",
		"imageSize": 1.1
	},
}

func changeColor(color: Color) -> void:
	var material : StandardMaterial3D = body.get_surface_override_material(0)
	material.albedo_color = color
	body.set_surface_override_material(0, material)

func changeFace(image: Texture2D, size: float = 1.0) -> void:
	face.texture = image
	face.scale = size * Vector3.ONE

func changePhighter(type : String) -> void:
	changeColor(pillData[type].color)
	#changeFace(load("res://assets/faces/sword.png"))
	changeFace(load(pillData[type].image), pillData[type].imageSize)
	set_meta("type", type)

func isTextMatchingPhighter(text : String) -> String:
	var regex = RegEx.create_from_string("[A-z]+") # dont get numbers
	for i : String in pillData:
		if i.is_subsequence_ofn(regex.search(text).get_string()) or regex.search(text).get_string().is_subsequence_of(i):
			return i
	return ""

func _ready() -> void:
	var matching = isTextMatchingPhighter(name)
	if matching:
		changePhighter(matching)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("1"):
		changePhighter("biograft")
	if Input.is_action_just_pressed("2"):
		freeze = false
