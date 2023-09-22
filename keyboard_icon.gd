extends Node2D
class_name KeyboardIcon

@export var character: String = "A"

@onready var label := $KeyLabel
var already_set := false

func _ready():
	pass

func _process(delta):
	if already_set: return
	if label:
		already_set = true
		label.text = character
