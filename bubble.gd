extends Node2D

@onready var label := $Label
@onready var bubbles: Array[Sprite2D] = [
	$CompiBubble,
	$HumanBubble
]

func _process(delta):
	position.y -= delta * 100
	
	if position.y < -1300:
		queue_free()

	modulate.a = remap(position.y, 0, -1300, 1, 0)

func settings(actor:int, text:String):
	for b in bubbles:
		b.visible = false
	bubbles[actor].visible = true
	label.text = text
