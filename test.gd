extends Node

var brain
var Brain = preload("res://brain.gd")
var actors: Array[Actor]

func _ready():
	print("Running test")
#	reset_state()
#	test1()
#	reset_state()
#	test2()
#	reset_state()
#	test3()
#	reset_state()
#	test4()
#	reset_state()
#	test5()
#	reset_state()
#	test6()

func reset_state():
	if brain != null:
		brain.queue_free()
	actors.resize(0)
	actors.append(Actor.new())
	actors.append(Actor.new())
	actors[ChatText.ACTOR.HUMAN].name = "human"
	actors[ChatText.ACTOR.COMPI].name = "compi"
	brain = Brain.new(actors)
	add_child(brain)

func test1():
	print("test 1")
	brain.chat.read_message("WHO ARE YOU?", ChatText.ACTOR.COMPI)
	brain.chat.only_weights(ChatText.ACTOR.COMPI)
	for q in brain.chat.quips:
		prints(q, brain.chat.quips[q].weight)

func test2():
	print("test 2")
	brain.chat.read_message("WHO ARE YOU?", ChatText.ACTOR.HUMAN)
	brain.chat.only_weights(ChatText.ACTOR.HUMAN)
	for q in brain.chat.quips:
		prints(q, brain.chat.quips[q].weight)

func test3():
	print("test 3")
	brain.chat.read_message("WHO ARE YOU?", ChatText.ACTOR.HUMAN)
	var a = brain.chat.select_answer(ChatText.ACTOR.HUMAN)
	print(a)

func test4():
	print("test 4")
	brain.chat.read_message("WHO ARE YOU?", ChatText.ACTOR.HUMAN)
	var a = brain.chat.select_answer(ChatText.ACTOR.HUMAN)
	print(a)
	brain.chat.read_message("WHO ARE YOU?", ChatText.ACTOR.COMPI)
	a = brain.chat.select_answer(ChatText.ACTOR.COMPI)
	print(a)
	brain.chat.read_message("WHO ARE YOU?", ChatText.ACTOR.COMPI)
	a = brain.chat.select_answer(ChatText.ACTOR.COMPI)
	print(a)

func test5():
	print("test 5")
	brain.chat.read_message("HELLO", ChatText.ACTOR.HUMAN)
	var a = brain.chat.select_answer(ChatText.ACTOR.HUMAN)
	print(a)
	brain.chat.read_message("HELLO", ChatText.ACTOR.COMPI)
	a = brain.chat.select_answer(ChatText.ACTOR.COMPI)
	print(a)
	brain.chat.read_message("WHO ARE YOU?", ChatText.ACTOR.COMPI)
	a = brain.chat.select_answer(ChatText.ACTOR.COMPI)
	print(a)

func test6():
	print("test 6")
	brain.chat.only_weights(ChatText.ACTOR.COMPI)
	var a = brain.chat.select_answer(ChatText.ACTOR.COMPI)
	for q in brain.chat.quips:
		prints(q, brain.chat.quips[q].weight)
	print(brain.chat.quips["I JUST KNOW IT"].weight)
	print(a)
