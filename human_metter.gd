extends Node2D

@onready var metter_indicator = $MetterIndicator

func update(value: int):
	#metter_indicator.position.x = value*30
	var tween := create_tween()
	tween.tween_property(metter_indicator, "position:x", value*30, 0.3)
