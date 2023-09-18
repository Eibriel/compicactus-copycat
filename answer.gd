extends Node2D

signal button_up

@onready var label := $Label
@onready var bubbles: Array[Sprite2D] = [
	$CompiAnswer,
	$HumanAnswer
]
@onready var weight_bar = $TextureProgressBar

func settings(actor:int, text:String):
	for b in bubbles:
		b.visible = false
	bubbles[actor].visible = true
	label.text = text

func set_weight(value: int):
	weight_bar.value = value


func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed == false:
			emit_signal("button_up")
