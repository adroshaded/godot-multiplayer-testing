extends Control

@onready var fpsLabel = $fps

func _process(delta: float) -> void:
	fpsLabel.text = str(int(Engine.get_frames_per_second()))
