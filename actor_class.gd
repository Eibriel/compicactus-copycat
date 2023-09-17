class_name Actor
	
var name: String
var props: Dictionary = {}

class ActorProperty:
	var id: String
	var type: String
	var max_value: int
	var min_value: int
	var default_value: Dictionary
	var current_value: Dictionary

	func _init(id_: String, type_: String, default_):
		id = id_
		type = type_
		default_value[type] = default_
		current_value[type] = default_
	
	func set_min_value(value_: int) -> ActorProperty:
		min_value = value_
		return self
	
	func set_max_value(value_: int) -> ActorProperty:
		max_value = value_
		return self
	
	func sample():
		return current_value[type]

	func zero():
		current_value[type] = 0
	
	func default():
		current_value[type] = default_value[type]

	func increase(amount:int = 1):
		current_value[type] += amount

	func decrease(amount:int = 1):
		current_value[type] -= amount

func _init():
	(new_prop("feeling good", "int", 3)
		.set_min_value(-10)
		.set_max_value(10))

func new_prop(id_: String, type_: String, default_):
	props[id_] = ActorProperty.new(id_, type_, default_)
	return props[id_]
