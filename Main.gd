extends Control

var brain
var time: float = 0
var Brain = preload("res://brain.gd")
var Bubble = preload("res://bubble.tscn")
var Answer = preload("res://answer.tscn")

@onready var bubbles = $Center/Bubbles
@onready var human_answers = $Center/HumanAnswers
@onready var compi_answers = $Center/CompiAnswers
@onready var actor_compi = $ActorCompi
@onready var actor_human = $ActorHuman
@onready var compi_properties = $Center/CompiProperties
@onready var human_properties = $Center/HumanProperties

var prop_update_time := 0.0

func _ready():
	brain = Brain.new([actor_human, actor_compi])
	add_child(brain)
	brain.connect("chat_bubble", _on_brain_bubble)
	populate_answers()

func _process(delta):
	prop_update_time += delta
	if prop_update_time > 0.1:
		prop_update_time = 0.0
		update_properties()
		update_weights()

func update_properties():
	update_properties_generic(actor_compi, compi_properties, ChatText.ACTOR.COMPI)
	update_properties_generic(actor_human, human_properties, ChatText.ACTOR.HUMAN)

func update_properties_generic(actor:Actor, text: RichTextLabel, actor_id: int):
	text.text = ""
	if actor_id == ChatText.ACTOR.COMPI:
		text.text += "Compicactus:\n"
	elif actor_id == ChatText.ACTOR.HUMAN:
		text.text += "Player:\n"
	for prop_id in actor.props:
		var prop = actor.props[prop_id]
		text.text += "%s: %f\n" % [prop_id, prop.current_value]
	text.text += "--\n"
	for t in brain.chat.current_topics:
		text.text += "%s: %d\n" % [t, brain.chat.current_topics[t]]
	text.text += "--\n"
	for t in brain.chat.recent_topics:
		text.text += "%s: %d\n" % [t, brain.chat.recent_topics[t]]
	text.text += "--\n"
	for q in brain.chat.recent_quips[actor_id]:
		text.text += "%s: %d\n" % [q, brain.chat.recent_quips[actor_id][q]]
	
#	human_properties.text = "Player:\n"
#	for prop_id in actor_human.props:
#		var prop = actor_human.props[prop_id]
#		human_properties.text += "%s: %f\n" % [prop_id, prop.current_value]

func update_weights():
	match brain.chat.current_actor:
		ChatText.ACTOR.COMPI:
			update_weights_generic(compi_answers, ChatText.ACTOR.COMPI)
		ChatText.ACTOR.HUMAN:
			update_weights_generic(human_answers, ChatText.ACTOR.HUMAN)

func update_weights_generic(answers_node, actor_id: int):
	var min_weight: int = 99999
	var max_weight: int = -99999
	#brain.chat.only_weights(actor_id)
	for c in answers_node.get_children():
		if c.has_meta("quip_id"):
			var w = brain.chat.quips[c.get_meta("quip_id")].weight
			if min_weight > w:
				min_weight = w
			if max_weight < w:
				max_weight = w
	for c in answers_node.get_children():
		if c.has_meta("quip_id"):
			var w = brain.chat.quips[c.get_meta("quip_id")].weight
			var val = int(remap(w, min_weight, max_weight, 0, 100))
			#prints(w, min_weight, max_weight, 0, 100, val)
			c.set_weight(val)

func _on_brain_bubble(actor_id, text):
	var b = Bubble.instantiate()
	if actor_id == ChatText.ACTOR.COMPI:
		b.position.x = -400
	elif actor_id == ChatText.ACTOR.HUMAN:
		b.position.x = 400
	b.call_deferred("settings", actor_id, text)
	bubbles.add_child(b)

func populate_answers():
	populate_answers_generic(compi_answers, ChatText.ACTOR.COMPI)
	populate_answers_generic(human_answers, ChatText.ACTOR.HUMAN)

func populate_answers_generic(answers_node, actor_id: int):
	var pos_y = 0
	for quip_id in brain.chat.get_quips_as_array():
		var a = Answer.instantiate()
		a.call_deferred("settings", actor_id, tr("%s" % quip_id))
		match actor_id:
			ChatText.ACTOR.HUMAN:
				a.connect("button_up", brain.human_talks.bind(quip_id))
			ChatText.ACTOR.COMPI:
				a.connect("button_up", brain.compi_talks.bind(quip_id))
		a.position.y = pos_y
		a.set_meta("quip_id", quip_id)
		answers_node.add_child(a)
		pos_y += 200

#@onready var answers_container := %AnswersContainer
#@onready var brain_text_label = %brainTextLabel
#
#func _ready():
#	for quip_id in dialogue.get_quips_as_array():
#		var b := Button.new()
#		b.text = tr("%s" % quip_id)
#		b.connect("button_up", _on_answer_click.bind(quip_id))
#		answers_container.add_child(b)
#
#func _on_answer_click(quip_id:String):
#	brain_text_label.add_text("\n\n Human: %s" % tr(quip_id))
#	var answer: String = dialogue.select_answer(quip_id, dialogue.ACTOR.COMPI)
#	brain_text_label.add_text("\n\n Compi: %s" % tr(answer))
