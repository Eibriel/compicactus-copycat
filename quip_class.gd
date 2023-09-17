class_name ChatText

var quips := {}
var quips_ids: Array[String]
var current_quip := ""
var actors: Array[Actor]

var current_actor: int
var current_topics: Dictionary
var recent_quips: Dictionary = {}

const ACTOR = {
	"HUMAN": 0,
	"COMPI": 1,
	"ENV": 2
}

class Quip:
	var id: String
	var topics: Array[String]
	var answers: Array[String]
	var weights: Array[Callable]
	var updates: Array[Callable]
	var weight: int = 0

func _init():
	var actor_human: Actor = Actor.new()
	actor_human.name = "human"
	var actor_compi: Actor = Actor.new()
	actor_compi.name = "compi"
	var actor_environment: Actor = Actor.new()
	actor_environment.name = "env"
	actors = [
		actor_human,
		actor_compi,
		actor_environment
	]
	current_topics = {
		"greetings": 3
	}

func new(text) -> ChatText:
	current_quip = text
	if not quips.has(current_quip):
		quips[current_quip] = Quip.new()
		quips[current_quip].id = current_quip
	return self

func topic(topic_: String) -> ChatText:
	_add_item("topics", topic_)
	return self

func answer(answer_: String) -> ChatText:
	_add_item("answers", answer_)
	return self

func weight(weight_function: Callable) -> ChatText:
	quips[current_quip].weights.append(weight_function)
	return self

func update(update_function: Callable) -> ChatText:
	quips[current_quip].updates.append(update_function)
	return self

func _add_item(key:String, value:String):
	if quips[current_quip][key].has(value): return
	quips[current_quip][key].append(value)

func get_quips_as_array():
	return quips.keys()

func select_answer(id:String, actor_answering:int):
	update_quips_ids()
	current_actor = actor_answering
	run_updates(id)
	set_topic_weight(id)
	update_weigths()
	set_answers_weight(id)
	var answer_: String
	quips_ids.sort_custom(sort_quips)
	answer_ = quips_ids[0]
	update_recent(answer_)
	return answer_

func run_updates(quip_id: String) -> void:
	for u in quips[quip_id].updates:
		u.call(quips[quip_id], actors[current_actor])

func update_recent(quip_id: String) -> void:
	for q in recent_quips:
		if recent_quips[q] > 0:
			recent_quips[q] -= 1
	recent_quips[quip_id] = 3

func set_answers_weight(id:String) -> void:
	for a in quips[id].answers:
		quips[a].weight += 50

func set_topic_weight(id:String) -> void:
	for topic in quips[id].topics:
		if current_topics.has(topic) and current_topics[topic] > 0:
			current_topics[topic] -= 1
		else:
			current_topics[topic] = 3

func update_weigths() -> void:
	for quip in quips:
		check_weights(quips[quip])

func check_weights(quip: Quip) -> void:
	quip.weight = 0
	quip.weight += recent_weight(quip)
	quip.weight += topic_weight(quip)
	for f in quip.weights:
		quip.weight += f.call(quip, actors[current_actor])

func recent_weight(quip: Quip) -> int:
	var weight := 0
	if recent_quips.has(quip.id):
		weight += -1*recent_quips[quip.id]
	return weight

func topic_weight(quip: Quip) -> int:
	var weight := 0
	for topic in quip.topics:
		if current_topics.has(topic) and current_topics[topic] > 0:
			weight += 2
	return weight

func sort_quips(a: String, b: String) -> bool:
	if quips[a].weight > quips[b].weight:
		return true
	return false

func update_quips_ids() -> void:
	# Hack to convert Dict keys to
	# an array of strings
	quips_ids.resize(0)
	for k in quips.keys():
		quips_ids.append(k)
