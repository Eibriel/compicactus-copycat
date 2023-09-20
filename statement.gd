extends Node2D

@onready var label = $Label

func set_text(text:String) -> void:
	label.text = text

func set_disabled(disabled_:bool = true) -> void:
	if disabled_:
		modulate.a = 0.5
	else:
		modulate.a = 1.0
