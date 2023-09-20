extends Node2D

@onready var toggle = $Toggle

const LEFT_POS = -49
const RIGHT_POS = 49

func toggle_left():
	#toggle.position.x = LEFT_POS
	var tween := create_tween()
	tween.tween_property(toggle, "position:x", LEFT_POS, 0.2)

func toggle_right():
	#toggle.position.x = RIGHT_POS
	var tween := create_tween()
	tween.tween_property(toggle, "position:x", RIGHT_POS, 0.2)
