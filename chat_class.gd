class_name ChatText

var quips := {}
var quips_ids: Array[String]
var current_quip := ""
var last_quip := ["", ""]
var actors: Array[Actor]

var current_actor: int
var current_topics: Dictionary
var recent_topics: Dictionary
var recent_quips: Dictionary = {0:{}, 1:{}}

const ACTOR = {
	"HUMAN": 0,
	"COMPI": 1
}

const QUIP_REPETITION_PENALTY_TURNS = 10
const TOPIC_REPETITION_PENALTY_TURNS = 10
const WEIGHT_ANSWER = 50
const WEIGHT_QUIP_REPETITION = -3
const WEIGHT_TOPIC_REPETITION = -5
const WEIGHT_ON_TOPIC = 2

class Quip:
	var id: String
	var topics: Array[String]
	var answers: Array[String]
	var weights: Array[Callable]
	var updates: Array[Callable]
	var weight: int = 0


func _init(actors_: Array[Actor]):
	actors = actors_
	actors[ACTOR.HUMAN].name = "human"
	actors[ACTOR.COMPI].name = "compi"
	current_topics = {
		"greetings": 3
	}

func new(text) -> ChatText:
	current_quip = text
	if not quips.has(current_quip):
		quips[current_quip] = Quip.new()
		quips[current_quip].id = current_quip
	update_quips_ids()
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

func read_message(id:String, actor_reading:int) -> void:
	current_actor = int(actor_reading)
	last_quip[actor_reading] = id
	#run_updates(id)
	update_topic_repetition(id)
	only_weights(actor_reading)
	update_recent(id, invert_actor(actor_reading))

func only_weights(actor_reading:int) -> void:
	current_actor = int(actor_reading)
	if last_quip[actor_reading] != "":
		update_weigths()
		set_answers_weight(last_quip[actor_reading])

func invert_actor(actor_id: int):
	match actor_id:
		ACTOR.COMPI:
			return ACTOR.HUMAN
		ACTOR.HUMAN:
			return ACTOR.COMPI

func select_answer(actor_answering:int) -> String:
	current_actor = int(actor_answering)
	var answer_: String
	quips_ids.sort_custom(sort_quips)
	answer_ = quips_ids[0]
	return answer_

func run_updates(quip_id: String) -> void:
	for u in quips[quip_id].updates:
		u.call(quips[quip_id], actors[current_actor])

func update_recent(quip_id: String, actor: int) -> void:
	for q in recent_quips[actor]:
		if recent_quips[actor][q] > 0:
			recent_quips[actor][q] -= 1
	for q in recent_topics:
		if recent_topics[q] > 0:
			recent_topics[q] -= 1
	recent_quips[actor][quip_id] = QUIP_REPETITION_PENALTY_TURNS

func set_answers_weight(id:String) -> void:
	for a in quips[id].answers:
		#print(a)
		quips[a].weight += WEIGHT_ANSWER

func update_topic_repetition(id:String) -> void:
	for topic_ in quips[id].topics:
		if current_topics.has(topic_):
			if current_topics[topic_] > 1:
				current_topics[topic_] -= 1
			elif current_topics[topic_] == 1:
				recent_topics[topic_] = TOPIC_REPETITION_PENALTY_TURNS
				current_topics[topic_] = 0
			elif current_topics[topic_] == 0:
				current_topics[topic_] = TOPIC_REPETITION_PENALTY_TURNS

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
	var weight_ := 0
	if recent_quips[current_actor].has(quip.id):
		weight_ += WEIGHT_QUIP_REPETITION * recent_quips[current_actor][quip.id]
	for topic_ in quip.topics:
		if recent_topics.has(topic_):
			weight_ += WEIGHT_TOPIC_REPETITION * recent_topics[topic_]
	return weight_

func topic_weight(quip: Quip) -> int:
	var weight_ := 0
	for topic_ in quip.topics:
		if current_topics.has(topic_) and current_topics[topic_] > 0:
			weight_ += WEIGHT_ON_TOPIC
	return weight_

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
