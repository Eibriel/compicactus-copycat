class_name ChatText

var quips := {}
var quips_ids: Array[String]
var current_quip := ""
var actors: Array[Actor]
var current_actor: int

const ACTOR = {
	"HUMAN": 0,
	"COMPI": 1
}

class Quip:
	var topics: Array[String]
	var answers: Array[String]
	var weights: Array[Callable]
	var weight: int = 0

class Actor:
	var name: String

func _init():
	var actor_human: Actor = Actor.new()
	actor_human.name = "human"
	var actor_compi: Actor = Actor.new()
	actor_compi.name = "compi"
	actors = [
		actor_human,
		actor_compi
	]

func new(text) -> ChatText:
	current_quip = text
	if not quips.has(current_quip):
		quips[current_quip] = Quip.new()
	return self

func topic(topic: String) -> ChatText:
	_add_item("topics", topic)
	return self

func answer(answer: String) -> ChatText:
	_add_item("answers", answer)
	return self

func weight(weight_function: Callable) -> ChatText:
	quips[current_quip].weights.append(weight_function)
	return self

func _add_item(key:String, value:String):
	if quips[current_quip][key].has(value): return
	quips[current_quip][key].append(value)

func get_quips_as_array():
	return quips.keys()

func select_answer(id:String, actor_answering:int):
	update_quips_ids()
	current_actor = actor_answering
	update_weigths()
	var answer: String
	for a in quips[id].answers:
		quips[a].weight += 50
	quips_ids.sort_custom(sort_quips)
	answer = quips_ids[0]
	return answer

func update_weigths() -> void:
	for quip in quips:
		check_weights(quips[quip])

func check_weights(quip: Quip) -> void:
	quip.weight = 0
	for f in quip.weights:
		quip.weight += f.call(quip, actors[current_actor])

func sort_quips(a: String, b: String):
	if quips[a].weight > quips[b].weight:
		return true
	return false

func update_quips_ids() -> void:
	# Hack to convert Dict keys to
	# an array of strings
	quips_ids.resize(0)
	for k in quips.keys():
		quips_ids.append(k)
