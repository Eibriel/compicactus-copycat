class_name ChatText

var quips := {}
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
	current_actor = actor_answering
	var answer: String
	var answers: Array = remove_unavailable_quips(quips[id].answers)
	if answers.size() > 0:
		answer = answers.pick_random()
		return answer
	answers = remove_unavailable_quips(quips_ids())
	answer = quips.keys().pick_random()
	return answer

func remove_unavailable_quips(quips_to_filter: Array[String]) -> Array[String]:
	var selected_quips: Array[String] = []
	for quip in quips_to_filter:
		if check_filters(quips[quip]):
			selected_quips.append(quip)
	return selected_quips

func check_filters(quip: Quip):
	var total_weight: int = 0
	for f in quip.filters:
		total_weight += f.call(quip, actors[current_actor])
	return total_weight

func quips_ids() -> Array[String]:
	# Hack to convert Dict keys to
	# an array of strings
	var r: Array[String] = []
	for k in quips.keys():
		r.append(k)
	return r
