extends Node

signal chat_bubble (actor_id, text)
signal env_change

var chat: ChatText
var actors: Array[Actor]

const TALK_DESIRE_THRESHOLD = 0.5

func _init(actors_: Array[Actor]):
	actors = actors_

func _process(delta):
	var compi_desire = chat.actors[ChatText.ACTOR.COMPI].props["desire to talk"]
	var human_desire = chat.actors[ChatText.ACTOR.HUMAN].props["desire to talk"]
	
	if compi_desire.current_value > TALK_DESIRE_THRESHOLD:
		print("COMPI TALKS")
		var uterance_compi := chat.select_answer(ChatText.ACTOR.COMPI)
		prints("ChatText.ACTOR.COMPI", ChatText.ACTOR.COMPI)
		prints("uterance_compi", uterance_compi)
		for q in chat.quips:
			prints(q, chat.quips[q].weight)
		compi_talks(uterance_compi)
	
	if human_desire.current_value > TALK_DESIRE_THRESHOLD:
		print("HUMAN TALKS")
		var uterance_human := chat.select_answer(ChatText.ACTOR.HUMAN)
		for q in chat.quips:
			prints(q, chat.quips[q].weight)
		human_talks(uterance_human)

func compi_talks(uterance_compi):
	var compi_desire = chat.actors[ChatText.ACTOR.COMPI].props["desire to talk"]
	var human_desire = chat.actors[ChatText.ACTOR.HUMAN].props["desire to talk"]
	emit_signal("chat_bubble", ChatText.ACTOR.COMPI, tr(uterance_compi))
	chat.read_message(uterance_compi, ChatText.ACTOR.HUMAN)
	compi_desire.current_value = 0.0
	human_desire.current_value = 0.1

func human_talks(uterance_human):
	var compi_desire = chat.actors[ChatText.ACTOR.COMPI].props["desire to talk"]
	var human_desire = chat.actors[ChatText.ACTOR.HUMAN].props["desire to talk"]
	emit_signal("chat_bubble", ChatText.ACTOR.HUMAN, tr(uterance_human))
	chat.read_message(uterance_human, ChatText.ACTOR.COMPI)
	compi_desire.current_value = 0.1
	human_desire.current_value = 0.0

func _ready():
	chat = ChatText.new(actors)

	(chat.new("HELLO")
		.topic("greetings")
		.answer("HI!")
		.answer("HI THERE!"))

	(chat.new("HI!")
		.topic("greetings")
		.answer("HELLO")
		.answer("HI THERE!"))
	
	(chat.new("HI THERE!")
		.topic("greetings")
		.answer("HELLO")
		.answer("HI!"))
	
	(chat.new("WHO ARE YOU?")
		.topic("who are you")
		.answer("IM HUMAN")
		.answer("IM COMPI"))

	(chat.new("IM HUMAN")
		.weight(filter_human)
		.topic("who are you"))
	
	(chat.new("IM COMPI")
		.weight(filter_compi)
		.topic("who are you"))

	(chat.new("HOW ARE YOU FEELING TODAY")
		.topic("feelings")
		.topic("today")
		.answer("IM FEELING GREAT")
		.answer("IM NOT SO GREAT")
		.answer("WHO CARES"))

	(chat.new("IM FEELING GREAT")
		.topic("feelings")
		.weight(func(_quip, actor): return actor.props["feeling good"].sample()*10)
		.update(func(_quip, actor): actor.props["feeling good"].increase()))
	
	(chat.new("IM NOT SO GREAT")
		.topic("feelings")
		.weight(func(_quip, actor): return actor.props["feeling good"].sample()*-10)
		.update(func(_quip, actor): actor.props["feeling good"].decrease()))
	
	(chat.new("WHO CARES")
		.topic("feelings"))

var filter_human = func(_quip, actor) -> int:
	if actor.name == "human":
		return 10
	return -100

var filter_compi = func(_quip, actor) -> int:
	if actor.name == "compi":
		return 10
	return -100
