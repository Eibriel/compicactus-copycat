#extends Node
class_name Statements

var state := {
	"h_or_r": 0,
	"heard": []
}
var statements:={}
var current_statement:String
var current_answer:String
var as_array: Array[String]
var is_disabled: Array[String]
var current_animation:String = ""

func reset():
	state = {
		"h_or_r": 0,
		"heard": []
	}
	is_disabled.resize(0)

func get_h_or_r() -> int:
	return state.h_or_r

func get_answer(statement_: String):
	if is_disabled.has(statement_):
		return ""
	current_animation = ""
	is_disabled.append(statement_)
	var possible_answers := {}
	for aid in statements[statement_].answers:
		var conditions_met := 0
		for f in statements[statement_].answers[aid].filters:
			if f.call(state):
				conditions_met += 1
		if conditions_met == statements[statement_].answers[aid].filters.size():
			possible_answers[aid] = conditions_met
	var selected_answer: String
	var max_conditions_met := -10
	for pa in possible_answers:
		if possible_answers[pa] > max_conditions_met:
			max_conditions_met = possible_answers[pa]
			selected_answer = pa
	#var selected_answer: String = statements[statement_].answers.keys()[0]
	statements[statement_].answers[selected_answer].update.call(state)
	current_animation = statements[statement_].answers[selected_answer].animation
	state.heard.append(statement_)
	return tr(selected_answer)

func get_stat_by_pos(position: int):
	return as_array[position]

func new(statement_: String):
	statements[statement_] = {
		"id": statement_,
		"answers": {}
	}
	current_statement = statement_
	current_answer = ""
	as_array.append(statement_)
	return self

func answer(answer_:String):
	statements[current_statement].answers[answer_] = {
		"text": answer_,
		"filters": [],
		"update": null,
		"animation": ""
	}
	current_answer = answer_
	return self

func animation(animation_:String):
	statements[current_statement] \
		.answers[current_answer].animation = animation_
	return self

func update(update_:Callable):
	statements[current_statement] \
		.answers[current_answer].update = update_
	return self

func filter(filter_:Callable):
	statements[current_statement] \
		.answers[current_answer].filters.append(filter_)
	return self
