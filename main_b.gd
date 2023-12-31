extends Control

# Music:
# https://davidkbd.itch.io/tropical-dreams-spring-and-summer-music-pack
# Sounds:
# https://souptonic.itch.io/souptonic-sfx-pack-1-ui-sounds

@onready var human_answers = %HumanAnswers
@onready var compi_answer_label = %CompiAnswerLabel
@onready var progress_bar = $Center/TextureProgressBar
@onready var tts_toggle = $Center/Options/TTS_toggle
@onready var human_metter = $Center/HumanMetter
@onready var popup = $Center/Popup
@onready var intro = $Center/Intro
@onready var language_selection = $Center/Popup/LanguageSelection
@onready var start_menu = $Center/Popup/StartMenu
@onready var debug_label = $DebugLabel
@onready var help = $Center/Popup/Help
@onready var end_screen = $Center/Popup/EndScreen
@onready var compicactus = $Control/SubViewportContainer/SubViewport/Compicactus
@onready var sub_viewport_container = $Control/SubViewportContainer
@onready var machine_icon = $Center/MachineIcon
@onready var human_icon = $Center/HumanIcon
@onready var result_text = $Center/Popup/EndScreen/ResultText
@onready var audio_stream_player = $AudioStreamPlayer
@onready var ui_player = $UIPlayer
@onready var volume_bar = $Center/Options/VolumeBar


var stat_bubble := preload("res://statement.tscn")
var statement_list := preload("res://statement_list.gd")

var music = [
	preload("res://music/DavidKBD - Tropical Pack - 03 - Heartbeats - Bossanova.ogg"),
	preload("res://music/DavidKBD - Tropical Pack - 04 - Rockin' the Waves - Surf Rock.ogg"),
	preload("res://music/DavidKBD - Tropical Pack - 11 - Ska-n't Stop the Ska - Ska.ogg")
]

var stat: Statements
var selected_statement := 0
var stat_nodes: Array = []
var current_stat_count := 0
var tts_on := true
var tts_available := true
var tts_voice_id:Dictionary = {}
var tts_rate:float = 1.0
var language := "en"
var game_state := "intro"
var volume := 0

const STAT_SPACE = 450
const STAT_TOP_MARGIN = 300
const MAX_STAT_COUNT = 5
const LANGUAGES = ["en", "es"]
const SOUNDS = {
	"Confirm": 0,
	"Next": 1,
	"Previous": 2,
	"Error": 3,
	"Enable": 4,
	"Disable": 5
}

func _ready():
	set_volume()
	intro.visible = true
	popup.visible = true
	compicactus.visible = false
	compicactus.play("LooksDown")
	start_menu.modulate.a = 0.0
	help.visible = false
	end_screen.visible = false
	sub_viewport_container.position = Vector2(-940,-520)
	initialize_tts()
	#tts_speak("_eibriel presents")
	var tween := create_tween()
	tween.tween_interval(1)
	tween.tween_property(intro, "modulate:a", 0, 1)
	tween.tween_callback(func ():
		game_state = "language"
		sub_viewport_container.position = Vector2(-1196,-708)
		compicactus.stop_anim()
		tts_speak("Press W or Up to select English")
		tts_speak("Presiona S o Abajo para seleccionar Español")
		tts_speak("Press V or Right Shoulder to change audio volume")
		tts_speak("Presiona V o Right Shoulder para cambiar el volumen del audio")
		compicactus.play("LooksDown")
		compicactus.call_deferred("set_visible", true)
		)

func start_game():
	progress_bar.value = 100
	var sl = statement_list.new()
	stat = Statements.new()
	stat = sl.add_statements(stat)
	popullate_stats()
	tts_toggle.update_speed(tts_rate)

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

func transition_to_start():
	sub_viewport_container.position = Vector2(-526,-361)
	compicactus.play("LooksUp")
	TranslationServer.set_locale(language)
	var tween := create_tween()
	tween.tween_property(language_selection, "modulate:a", 0, 1)
	tween.tween_property(start_menu, "modulate:a", 1, 1)
	tts_speak(tr("_start text"), true)

func toggle_tts():
	tts_on = !tts_on
	if tts_on:
		play_sound(SOUNDS.Enable)
	else:
		play_sound(SOUNDS.Disable)
	update_tts_toggle()

func fast_tts():
	play_sound(SOUNDS.Confirm)
	tts_rate += 0.1
	tts_rate = min(tts_rate, 10.0)
	tts_speak(tr("_tts speed increased"), true)
	tts_toggle.update_speed(tts_rate)

func slow_tts():
	play_sound(SOUNDS.Confirm)
	tts_rate -= 0.1
	tts_rate = max(tts_rate, 0.1)
	tts_speak(tr("_tts speed decreased"), true)
	tts_toggle.update_speed(tts_rate)

func set_volume():
	play_sound(SOUNDS.Confirm)
	volume += 1
	if volume > 4:
		volume = 0
	AudioServer.set_bus_mute(0, false)
	AudioServer.set_bus_volume_db(0, 0.0)
	match volume:
		0:
			AudioServer.set_bus_mute(0, true)
			volume_bar.value = 0
		1:
			AudioServer.set_bus_volume_db(0, -12.0)
			volume_bar.value = 25+10
		2:
			AudioServer.set_bus_volume_db(0, -6.0)
			volume_bar.value = 50
		3:
			AudioServer.set_bus_volume_db(0, -3.0)
			volume_bar.value = 75-10
		4:
			AudioServer.set_bus_volume_db(0, 0.0)
			volume_bar.value = 100
	
func open_help():
	game_state = "help"
	play_sound(SOUNDS.Confirm)
	tts_speak(tr("_help text"))
	help.visible = true
	popup.visible = true
	var tween := create_tween()
	tween.tween_property(popup, "modulate:a", 1, 1)



# Sounds
func play_sound(id: int):
	var sound_file
	match id:
		SOUNDS.Confirm:
			sound_file = preload("res://sounds/SFX_UI_MenuSelections.ogg")
		SOUNDS.Next:
			sound_file = preload("res://sounds/SFX_UI_Pause.ogg")
		SOUNDS.Previous:
			sound_file = preload("res://sounds/SFX_UI_Resume.ogg")
		SOUNDS.Error:
			sound_file = preload("res://sounds/SFX_UI_Cancel.ogg")
		SOUNDS.Enable:
			sound_file = preload("res://sounds/SFX_UI_Equip.ogg")
		SOUNDS.Disable:
			sound_file = preload("res://sounds/SFX_UI_Unequip.ogg")
	ui_player.stream = sound_file
	if id == SOUNDS.Error:
		ui_player.pitch_scale = 1.0
	else:
		ui_player.pitch_scale = randf_range(0.9, 1.1)
	ui_player.play()



## Input


func _input(event):
	match game_state:
		"game":
			game_input_set(event)
		"help":
			help_input_set(event)
		"language":
			language_input_set(event)
		"start_game":
			start_game_input_set(event)
		"end_game":
			end_game_input_set(event)
		"play_again":
			play_again_input_set(event)
	if event.is_action_pressed("volume"):
		set_volume()
	if event.is_action_pressed("toggle_tts"):
		toggle_tts()
	if event.is_action_pressed("fast_tts"):
		fast_tts()
	if event.is_action_pressed("slow_tts"):
		slow_tts()

func language_input_set(event):
	if event.is_action_pressed("next_statement"):
		language = "es"
		game_state = "start_game"
		play_sound(SOUNDS.Confirm)
		transition_to_start()
	if event.is_action_pressed("previous_statement"):
		language = "en"
		game_state = "start_game"
		play_sound(SOUNDS.Confirm)
		transition_to_start()
	
func start_game_input_set(event):
	if event.is_action_pressed("select_statement"):
		game_state = "game"
		play_sound(SOUNDS.Confirm)
		audio_stream_player.stream = music[1]
		audio_stream_player.play()
		tts_speak(tr("_press h to open help"), true)
		var tween := create_tween()
		tween.tween_property(popup, "modulate:a", 0, 1)
		tween.tween_callback(func():
			popup.visible = false
			start_menu.visible = false
			sub_viewport_container.position = Vector2(20,-508)
			compicactus.play("Shows", true)
			)
		start_game()

func help_input_set(event):
	if event.is_action_pressed("help"):
		game_state = "game"
		play_sound(SOUNDS.Confirm)
		var tween := create_tween()
		tween.tween_property(popup, "modulate:a", 0, 1)
		tween.tween_callback(func():
			popup.visible = false
			help.visible = false)

func end_game_input_set(event):
	if event.is_action_pressed("select_statement"):
		play_sound(SOUNDS.Confirm)
		play_again_popup()

func play_again_input_set(event):
	if event.is_action_pressed("select_statement"):
		game_state = "game"
		play_sound(SOUNDS.Confirm)
		audio_stream_player.stream = music[1]
		audio_stream_player.play()
		reset_game()
		var tween := create_tween()
		tween.tween_property(popup, "modulate:a", 0, 1)
		tween.tween_callback(func():
			popup.visible = false
			end_screen.visible = false
			compicactus.play("Idle"))

func game_input_set(event):
	if event.is_action_pressed("next_statement"):
		selected_statement += 1
		if selected_statement > stat_nodes.size()-1:
			selected_statement = stat_nodes.size()-1
			shake_stat_pos()
			play_sound(SOUNDS.Error)
		else:
			play_sound(SOUNDS.Next)
		#tts_speak(tr("_player")+" "+tr(stat.get_stat_by_pos(selected_statement)), true)
		tts_speak(tr(stat.get_stat_by_pos(selected_statement)), true)
		update_stat_pos()
	if event.is_action_pressed("previous_statement"):
		selected_statement -= 1
		if selected_statement < 0:
			selected_statement = 0
			shake_stat_pos()
			play_sound(SOUNDS.Error)
		else:
			play_sound(SOUNDS.Previous)
		#tts_speak(tr("_player")+" "+tr(stat.get_stat_by_pos(selected_statement)), true)
		tts_speak(tr(stat.get_stat_by_pos(selected_statement)), true)
		update_stat_pos()
	if event.is_action_pressed("select_statement"):
		compute_answer()
	if event.is_action_pressed("help"):
		open_help()





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
	if msg == "":
		play_sound(SOUNDS.Error)
		return
	play_sound(SOUNDS.Confirm)
	compicactus.play(stat.current_animation, true)
	compi_answer_label.text = msg
	compi_answer_label.visible_ratio = 0.0
	var tween = create_tween()
	tween.tween_property(compi_answer_label, "visible_ratio", 1.0, 1.0)
	tts_speak(tr("_compi")+" " + msg)
	current_stat_count += 1
	progress_bar.value = 100-(100 / MAX_STAT_COUNT)*current_stat_count
	var diff_h_or_r = stat.get_h_or_r() - prev_h_or_r
	if diff_h_or_r < 0:
		machine_icon.visible = true
		var tween_2 = create_tween()
		machine_icon.modulate.a = 0.0
		tween_2.tween_property(machine_icon, "modulate:a", 1.0, 1.0)
		tween_2.tween_interval(1)
		tween_2.tween_property(machine_icon, "modulate:a", 0.0, 1.0)
		tween_2.tween_callback(func (): machine_icon.visible = false)
		tts_speak(tr("_sounds machine"))
	elif diff_h_or_r > 0:
		human_icon.visible = true
		var tween_2 = create_tween()
		human_icon.modulate.a = 0.0
		tween_2.tween_property(human_icon, "modulate:a", 1.0, 1.0)
		tween_2.tween_interval(1)
		tween_2.tween_property(human_icon, "modulate:a", 0.0, 1.0)
		tween_2.tween_callback(func (): human_icon.visible = false)
		tts_speak(tr("_sounds human"))
	if false:
		if stat.get_h_or_r() > 0:
			tts_speak(tr("_human %s") % stat.get_h_or_r())
		elif stat.get_h_or_r() < 0:
			tts_speak(tr("_robot %s") % stat.get_h_or_r())
		else:
			tts_speak(tr("_human and robot"))
	var stat_left = MAX_STAT_COUNT - current_stat_count
	if stat_left != 0:
		tts_speak(tr("_%s statements left") % (MAX_STAT_COUNT - current_stat_count))
	update_metter()
	check_end_state()

func check_end_state():
	if current_stat_count < MAX_STAT_COUNT: return
	game_state = "end_game"
	audio_stream_player.stream = music[2]
	audio_stream_player.play()
	compicactus.play("HumanOrMachine")
	tts_speak(tr("_compi thinking human or machine"))

func play_again_popup():
	game_state = "play_again"
	end_screen.visible = true
	popup.visible = true
	var tween := create_tween()
	tween.tween_property(popup, "modulate:a", 1, 1)
	if stat.get_h_or_r() >= 0:
		compicactus.play("Human")
		result_text.text = tr("_end human")
		tts_speak(tr("_end human"))
	else:
		compicactus.play("Machine")
		result_text.text = tr("_end machine")
		tts_speak(tr("_end machine"))
	tts_speak(tr("_end text"))

func reset_game():
	stat.reset()
	progress_bar.value = 100
	current_stat_count = 0
	selected_statement = 0
	compi_answer_label.text = "..."
	update_metter()
	update_stat_pos()
	for n in stat_nodes:
		n.set_disabled(false)

func update_metter():
	human_metter.update(stat.get_h_or_r())


## TTS


func initialize_tts():
	for l in LANGUAGES:
		var voices = DisplayServer.tts_get_voices_for_language(l)
		debug_label.add_text("\nLanguage: %s" % l)
		for v in voices:
			debug_label.add_text("\nVoice: %s" % v)
		debug_label.add_text("\n")
		if voices.size() == 0: continue
		tts_voice_id[l] = voices[0]
	
	# This is not needed
	# Browsers return empty voice list
#	if !tts_voice_id.has("en"):
#		tts_available = true
#		tts_on = false
#		update_tts_toggle()

func tts_speak(text:String, interrupt:=false, force:=false):
	if !tts_on and !force: return
	if !tts_available: return
	var volume := 50
	var pitch := 1.0
	#var rate := 1.0
	var utterance_id:=0
	DisplayServer.tts_speak(text,
		tts_voice_id[language],
		volume,
		pitch,
		tts_rate,
		utterance_id,
		interrupt
	)
