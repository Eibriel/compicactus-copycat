extends Control

@onready var human_answers = %HumanAnswers
@onready var compi_answer_label = %CompiAnswerLabel
@onready var progress_bar = $Center/TextureProgressBar
@onready var tts_toggle = $Center/TTS_toggle
@onready var human_metter = $Center/HumanMetter

var stat_bubble := preload("res://statement.tscn")

var stat: Statements
var selected_statement := 0
var stat_nodes: Array = []
var current_stat_count := 0
var tts_on := true
var tts_available := true
var tts_voice_id:Dictionary = {}
var language := "en"

const STAT_SPACE = 450
const STAT_TOP_MARGIN = 300
const MAX_STAT_COUNT = 10
const LANGUAGES = ["en", "es"]

class Statements:
	var state := {
		"h_or_r": 0,
		"heard": []
	}
	var statements:={}
	var current_statement:String
	var current_answer:String
	var as_array: Array[String]
	var is_disabled: Array[String]
	
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
			"update": null
		}
		current_answer = answer_
		return self
	
	func update(update_:Callable):
		statements[current_statement] \
			.answers[current_answer].update = update_
		return self
	
	func filter(filter_:Callable):
		statements[current_statement] \
			.answers[current_answer].filters.append(filter_)
		return self


func _ready():
	TranslationServer.set_locale(language)
	initialize_tts()
	progress_bar.value = 100
	add_statements()
	popullate_stats()

func popullate_stats():
	stat_nodes.resize(0)
	for c in human_answers.get_children():
		c.queue_free()
	var pos_y = 0
	for stat_id in stat.as_array:
		var s = stat_bubble.instantiate()
		stat_nodes.append(s)
		s.call_deferred("set_text", tr("%s" % stat_id))
		s.position.y = pos_y
		human_answers.add_child(s)
		pos_y += STAT_SPACE
	update_stat_pos()

func _input(event):
	if event.is_action_pressed("next_statement"):
		selected_statement += 1
		if selected_statement > stat_nodes.size()-1:
			selected_statement = stat_nodes.size()-1
			shake_stat_pos()
		update_stat_pos()
	if event.is_action_pressed("previous_statement"):
		selected_statement -= 1
		if selected_statement < 0:
			selected_statement = 0
			shake_stat_pos()
		update_stat_pos()
	if event.is_action_pressed("select_statement"):
		compute_answer()
	if event.is_action_pressed("toggle_tts"):
		tts_on = !tts_on
		update_tts_toggle()
	if event.is_action_pressed("help"):
		tts_speak(tr("_help text"))

func update_tts_toggle():
	if tts_on:
		tts_speak(tr("_text to speech on"), true)
		tts_toggle.toggle_right()
	else:
		tts_speak(tr("_text to speech off"), true, true)
		tts_toggle.toggle_left()

func update_stat_pos():
	var tween := create_tween()
	var pos = get_stat_pos()
	tween.tween_property(human_answers, "position:y",pos, 0.1)
	tts_speak(tr("_player")+" "+stat.get_stat_by_pos(selected_statement), true)
	#human_answers.position.y = 200 + (selected_statement*STAT_SPACE)

func shake_stat_pos():
	var tween := create_tween()
	var pos = get_stat_pos()
	tween.tween_property(human_answers, "position:y",pos+8, 0.05)
	tween.tween_property(human_answers, "position:y",pos-5, 0.1)
	tween.tween_property(human_answers, "position:y",pos+5, 0.1)
	tween.tween_property(human_answers, "position:y",pos, 0.1)

func get_stat_pos():
	return STAT_TOP_MARGIN + (selected_statement*STAT_SPACE*-1)

func compute_answer():
	stat_nodes[selected_statement].set_disabled()
	var prev_h_or_r = stat.get_h_or_r()
	var msg = stat.get_answer(stat.get_stat_by_pos(selected_statement))
	if msg == "": return
	compi_answer_label.text = msg
	tts_speak(tr("_compi")+" "+msg)
	current_stat_count += 1
	progress_bar.value = 100-(100 / MAX_STAT_COUNT)*current_stat_count
	var diff_h_or_r = stat.get_h_or_r() - prev_h_or_r
	if stat.get_h_or_r() > 0:
		tts_speak(tr("_human %s") % stat.get_h_or_r())
	elif stat.get_h_or_r() < 0:
		tts_speak(tr("_robot %s") % stat.get_h_or_r())
	else:
		tts_speak(tr("_human and robot"))
	tts_speak(tr("_%s statements left") % (MAX_STAT_COUNT - current_stat_count))
	update_metter()
	check_end_state()

func check_end_state():
	if current_stat_count < MAX_STAT_COUNT: return
	stat.reset()
	progress_bar.value = 100
	current_stat_count = 0
	selected_statement = 0
	update_metter()
	update_stat_pos()
	for n in stat_nodes:
		n.set_disabled(false)

func update_metter():
	human_metter.update(stat.get_h_or_r())

func initialize_tts():
	for l in LANGUAGES:
		var voices = DisplayServer.tts_get_voices_for_language(l)
		if voices.size() == 0: continue
		tts_voice_id[l] = voices[0]
	
	if !tts_voice_id.has("en"):
		tts_available = true
		tts_on = false
		update_tts_toggle()

func tts_speak(text:String, interrupt:=false, force:=false):
	if !tts_on and !force: return
	if !tts_available: return
	var volume := 50
	var pitch := 1.0
	var rate := 1.0
	var utterance_id:=0
	DisplayServer.tts_speak(text,
		tts_voice_id[language],
		volume,
		pitch,
		rate,
		utterance_id,
		interrupt
	)

#	# Say "Hello, world!".
#	DisplayServer.tts_speak("Hello, world!", voice_id)
#
#	# Say a longer sentence, and then interrupt it.
#	# Note that this method is asynchronous: execution proceeds to the next line immediately,
#	# before the voice finishes speaking.
#	var long_message = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur"
#	DisplayServer.tts_speak(long_message, voice_id)
#
#	# Immediately stop the current text mid-sentence and say goodbye instead.
#	DisplayServer.tts_stop()
#	DisplayServer.tts_speak("¡Hasta luego!", voice_id, 50, 1.0, 0.2)

func add_statements():
	stat = Statements.new()
	(stat.new("_i like to sort")
		.answer("_sorting algorithms are boring to humans")
		.update(func(st): st.h_or_r -= 2)
		)
	
	(stat.new("_i flew a kite once")
		.answer("_you must be very proud")
		.update(func(st): st.h_or_r += 2)
		)
	
	(stat.new("_i had a coffee this morning")
		.answer("_recharging the batteries, am i right?")
		.update(func(st): st.h_or_r += 1)
		)
	
	(stat.new("_i can feel joy")
		.answer("_glad you are enjoying the game")
		.update(func(st): st.h_or_r += 3)
		
		.answer("_must be the coffee talking")
		.filter(func(st): return st.heard.has("_i had a coffee this morning"))
		.update(func(st): st.h_or_r += 3)
		)
	
	(stat.new("_shawning is contagious")
		.answer("_am i boring you?")
		.update(func(st): st.h_or_r += 1)
		
		.answer("_keep your human deseases out of me")
		.filter(func(st): return st.h_or_r > 10)
		.update(func(st): st.h_or_r += 3)
		)
	
	(stat.new("_i need to go to the bathroom")
		.answer("_that is what a roomba would say")
		.update(func(st): st.h_or_r -= 1)
		)
	
	(stat.new("_i need to pee")
		.answer("_too much coffee?")
		.filter(func(st): return st.heard.has("_i had a coffee this morning"))
		.update(func(st): st.h_or_r += 3)
		
		.answer("_spare me the details")
		.update(func(st): st.h_or_r += 1)
		)
		
	(stat.new("_bumping a toe is incredibly painful")
		.answer("_thats one of the reasons i dont have toes")
		.update(func(st): st.h_or_r += 1)
		)
	
	(stat.new("_my internet connection just drop")
		.answer("_if you were human you would be in dispair")
		.update(func(st): st.h_or_r -= 2)
		)
	
	(stat.new("_error 404 page not found")
		.answer("_insert some funny picture, quote or joke")
		.update(func(st): st.h_or_r -= 3)
		)
	
	(stat.new("_i've fear of viruses")
		.answer("_malware, spyware, ransomware?")
		.update(func(st): st.h_or_r -= 3)
		)
	
	(stat.new("_im a game developer")
		.answer("_poor little thing, get some extra points")
		.update(func(st): st.h_or_r += 4)
		)
	
	(stat.new("_a* algorithms allows for pathfinding")
		.answer("_what are you even talking about?")
		.update(func(st): st.h_or_r -= 2)
		
		.answer("_i guess thats something game developers just say")
		.filter(func(st): return st.heard.has("_im a game developer"))
		.update(func(st): st.h_or_r += 3)
		)
	
	(stat.new("_i like dogs")
		.answer("_everyone like dogs")
		.update(func(st): st.h_or_r += 0)
		
		.answer("_weird, you liked cats just a moment ago")
		.filter(func(st): return st.heard.has("_i like cats"))
		.update(func(st): st.h_or_r -= 1)
		)
	
	(stat.new("_i like cats")
		.answer("_everyone like cats")
		.update(func(st): st.h_or_r += 0)
		
		.answer("_you like dogs or you like cats, i cannot compute")
		.filter(func(st): return st.heard.has("_i like dogs"))
		.update(func(st): st.h_or_r -= 1)
		)
	
	(stat.new("_i do wat i like, i've free will")
		.answer("_thats every printer on the planet")
		.update(func(st): st.h_or_r -= 2)
		)
	
	(stat.new("_what was your first pet's name?")
		.answer("_nice try hacker")
		.update(func(st): st.h_or_r -= 2)
		)
	
	(stat.new("_i like you")
		.answer("_im not that easy, oh looks like i actually are")
		.update(func(st): st.h_or_r += 1)
		
		.answer("_you like dogs, cats and cactus?")
		.filter(func(st): return st.heard.has("_i like dogs") and st.heard.has("_i like cats"))
		.update(func(st): st.h_or_r += 5)
		)
