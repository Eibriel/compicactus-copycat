extends Control

@onready var answers_container := %AnswersContainer
@onready var chat_text_label = %ChatTextLabel

var dialogue: ChatText

func _ready():
	generate_text()
	for quip_id in dialogue.get_quips_as_array():
		var b := Button.new()
		b.text = tr("%s" % quip_id)
		b.connect("button_up", _on_answer_click.bind(quip_id))
		answers_container.add_child(b)

func _on_answer_click(quip_id:String):
	chat_text_label.add_text("\n\n Human: %s" % tr(quip_id))
	var answer: String = dialogue.select_answer(quip_id, dialogue.ACTOR.COMPI)
	chat_text_label.add_text("\n\n Compi: %s" % tr(answer))

func generate_text():
	dialogue = ChatText.new()

	(dialogue.new("HELLO")
		.topic("greetings")
		.answer("HI!")
		.answer("HI THERE!"))

	(dialogue.new("HI!")
		.topic("greetings")
		.answer("HELLO")
		.answer("HI THERE!"))
	
	(dialogue.new("HI THERE!")
		.topic("greetings")
		.answer("HELLO")
		.answer("HI!"))
	
	(dialogue.new("WHO ARE YOU?")
		.topic("who are you")
		.answer("IM HUMAN")
		.answer("IM COMPI"))

	(dialogue.new("IM HUMAN")
		.weight(filter_human)
		.topic("who are you"))
	
	(dialogue.new("IM COMPI")
		.weight(filter_compi)
		.topic("who are you"))

	(dialogue.new("HOW ARE YOU FEELING TODAY")
		.topic("feelings")
		.topic("today")
		.answer("IM FEELING GREAT")
		.answer("IM NOT SO GREAT")
		.answer("WHO CARES"))

	(dialogue.new("IM FEELING GREAT")
		.topic("feelings")
		.weight(func(quip, actor): return actor.props["feeling good"].sample()*10)
		.update(func(quip, actor): actor.increase("feeling good")))
	
	(dialogue.new("IM NOT SO GREAT")
		.topic("feelings")
		.weight(func(quip, actor): return actor.props["feeling good"].sample()*-10)
		.update(func(quip, actor): actor.props["feeling good"].decrease()))
	
	(dialogue.new("WHO CARES")
		.topic("feelings"))

var filter_human = func(quip, actor) -> int:
	if actor.name == "human":
		return 10
	return -100

var filter_compi = func(quip, actor) -> int:
	if actor.name == "compi":
		return 10
	return -100


