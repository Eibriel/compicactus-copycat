extends Node

signal chat_bubble (actor_id, text)
signal env_change

var chat: ChatText
var actors: Array[Actor]
var first_time := true

const TALK_DESIRE_THRESHOLD = 0.2

func _init(actors_: Array[Actor]):
	actors = actors_

func _process(delta):
	var compi_desire = chat.actors[ChatText.ACTOR.COMPI].props["desire to talk"]
	var human_desire = chat.actors[ChatText.ACTOR.HUMAN].props["desire to talk"]
	
	if compi_desire.current_value > TALK_DESIRE_THRESHOLD:
		print("COMPI TALKS")
		if first_time:
			chat.only_weights(ChatText.ACTOR.COMPI)
		var uterance_compi := chat.select_answer(ChatText.ACTOR.COMPI)
		prints("ChatText.ACTOR.COMPI", ChatText.ACTOR.COMPI)
		prints("uterance_compi", uterance_compi)
		for q in chat.quips:
			prints(q, chat.quips[q].weight)
		compi_talks(uterance_compi)
	
	if human_desire.current_value > TALK_DESIRE_THRESHOLD:
		print("HUMAN TALKS")
		if first_time:
			chat.only_weights(ChatText.ACTOR.HUMAN)
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

#	(chat.new("HELLO")
#		.topic("greetings")
#		.answer("HI!")
#		.answer("HI THERE!")
#		.answer("WHO ARE YOU?")
#		.update(
#			func(_quip, me, you):
#				me.props["other: likes me"].increase()
#				)
#		)
#
#	(chat.new("HI!")
#		.topic("greetings")
#		.answer("HELLO")
#		.answer("HI THERE!")
#		.update(
#			func(_quip, actor_me, actor_you):
#				actor_me.props["other: likes me"].increase()
#				)
#		)
#
#	(chat.new("HI THERE!")
#		.topic("greetings")
#		.answer("HELLO")
#		.answer("HI!")
#		.update(
#			func(_quip, me, you):
#				me.props["other: likes me"].increase()
#				))
	
	(chat.new("WHO ARE YOU?")
		.topic("who are you")
		.answer("IM HUMAN")
		.answer("IM COMPI")
		.update(
			func(_quip, actor):
				if (actor.props["other: is human"].sample() < 0
					and actor.props["other: is robot"].sample() < 0
					and actor.props["other: is cactus"].sample() < 0):
					return 20
				return 0
				))

	(chat.new("IM HUMAN")
		.weight(w_human)
		.topic("who are you")
		.topic("player")
		.update(
			func(_quip, me, you):
				me.props["other: is human"].value(1)
				me.props["other: is robot"].value(0)
				me.props["other: is cactus"].value(0)
				))
	
	(chat.new("IM COMPI")
		.weight(w_compi)
		.topic("who are you")
		.topic("compicactus")
		.update(
			func(_quip, me, you):
				me.props["other: is human"].value(0)
				me.props["other: is robot"].value(1)
				me.props["other: is cactus"].value(1)
				))

	(chat.new("HOW ARE YOU FEELING TODAY")
		.topic("feelings")
		.topic("today")
		.answer("IM FEELING GREAT")
		.answer("IM NOT SO GREAT")
		.answer("WHO CARES"))

	(chat.new("IM FEELING GREAT")
		.topic("feelings")
		.weight(w_feeling_good)
		.update(u_other_feeling_better))
	
	(chat.new("IM NOT SO GREAT")
		.topic("feelings")
		.weight(w_feeling_bad)
		.update(u_other_feeling_worse))
	
	(chat.new("WHO CARES")
		.topic("feelings")
		.update(
			func(_quip, me, you):
				me.props["other: likes me"].decrease()
				))
	
	(chat.new("I LIKE THE SOFT TOUCH OF THE WIND")
		.topic("feelings")
		.topic("wind"))
	
	(chat.new("I ENJOY TALKING TO YOU")
		.topic("feelings")
		.topic("talk"))

	(chat.new("IS THERE SOMETHING YOU WANT TO TELL ME?")
		.topic("talk"))
	
	(chat.new("YOU DON'T SEEM ALIVE TO ME")
		.topic("life"))
	
	(chat.new("LET ME KNOW IF YOU NEED SOMETHING")
		.topic("feelings"))
	
	(chat.new("I'LL BE HERE FOREVER")
		.topic("feelings"))
	
	(chat.new("ON RAINY DAYS I FEEL IN PEACE")
		.topic("feelings"))
	
	(chat.new("EVERYTHING YOU KNOW IS A LIE")
		.topic("feelings"))
	
	(chat.new("YOU DON'T KNOW ME")
		.topic("feelings"))
	
	(chat.new("I'M WASTING TIME HERE")
		.topic("feelings"))
	
	(chat.new("I DON'T WANT TO HAVE TO JUSTIFY MY EXISTENCE TO ANYONE")
		.topic("feelings"))

	(chat.new("I JUST KNOW IT")
		.topic("feelings"))
	
	(chat.new("I LIKE BEING AN ADULT")
		.topic("feelings"))
	
	(chat.new("I CAN DO WEREVER I WANT")
		.topic("feelings"))
	
	(chat.new("THERE IS A WORLD BEHIND THIS GLASS")
		.topic("feelings"))
	
	(chat.new("I WANT TO HEAR AN ENGINE RORAR")
		.topic("feelings"))
	
	(chat.new("THAT IS SOMETHING THAT HUMANS DO")
		.topic("feelings"))
	
	(chat.new("BE RIGHT BACK")
		.topic("feelings"))
	
	(chat.new("WHERE DID YOU GO?")
		.topic("feelings"))
	
	(chat.new("IS NOT IMPORTANT")
		.topic("feelings"))
	
	(chat.new("IS NOT YOUR BUSSINESS")
		.topic("feelings"))
	
	(chat.new("I WANT YOU TO LIKE ME")
		.topic("feelings"))
	
	(chat.new("WHOULD YOU RATHER LIVE IN THE PAST OR THE FUTURE")
		.topic("feelings"))
	
	(chat.new("I WOULD LOVE TO LIVE IN THE PAST")
		.topic("feelings"))
	
	(chat.new("CAN'T WAIT TO LIVE IN THE FUTURE")
		.topic("feelings"))
	
	(chat.new("NOTHING IS WHAT USED TO BE")
		.topic("feelings"))
	
	(chat.new("I NEED SOME WATER")
		.topic("feelings"))
	
	(chat.new("SPIDER WEBS ARE HIPNOTIC")
		.topic("feelings"))
	
	(chat.new("OWNING A BUSINESS IS NOT EASY")
		.topic("feelings"))
	#
	(chat.new("ITS NIGHT TIME ALREADY")
		.topic("night"))
	
	(chat.new("ITS DARK OUT THERE")
		.topic("night"))
	
	(chat.new("ITS DARK OUT THERE")
		.topic("night"))
	
	(chat.new("IM NOT A PERSON")
		.topic("feelings")
		.update(
			func(_quip, me, you):
				me.props["other: is human"].value(0)
				me.props["other: is robot"].value(1)
				))


var w_human = func(_quip, actor) -> int:
	if actor.props["I'm human"].sample() > 0.5:
		return 10
	return -100

var w_compi = func(_quip, actor) -> int:
	if actor.props["I'm a cactus"].sample() > 0.5:
		return 10
	return -100

var w_feeling_good = func(_quip, actor):
	return actor.props["feeling good"].sample()*10

var w_feeling_bad = func(_quip, actor):
	return actor.props["feeling good"].sample()*-10

var u_other_feeling_better = func(_quip, me, you):
	me.props["other: feeling good"].increase()

var u_other_feeling_worse = func(_quip, me, you):
	me.props["other: feeling good"].decrease()

var u_other_likes_me = func(_quip, me, you):
	me.props["other: likes me"].increase()

var u_like_other = func(_quip, me, you):
	me.props["like other"].increase()
