extends Node
class_name Actor
	
#var id: String
var props: Dictionary = {}

# Make realtime

class ActorProperty:
	var id: String
	var type: String
	var max_value: float
	var min_value: float
	var default_value: float
	var current_value: float
	var tends_to: String = ""
	var speed: float

	func _init(id_: String, type_: String, default_):
		id = id_
		type = type_
		default_value = default_
		current_value = default_
	
	func set_min_value(value_: float) -> ActorProperty:
		min_value = value_
		return self
	
	func set_max_value(value_: float) -> ActorProperty:
		max_value = value_
		return self
	
	func sample():
		return current_value

	func zero():
		current_value = 0
	
	func default():
		current_value = default_value

	func increase(amount:float = 1):
		current_value += amount

	func decrease(amount:float = 1):
		current_value -= amount
	
	func tends_to_max(speed_: float = 0.1):
		tends_to = "max"
		speed = speed_
	
	func tends_to_default(speed_: float = 0.1):
		tends_to = "default"
		speed = speed_


func _init():
	(new_prop("feeling good", "int", 0.2)
		.set_min_value(-1)
		.set_max_value(1)
		.tends_to_default())
	(new_prop("desire to talk", "int", 0)
		.set_min_value(0)
		.set_max_value(1)
		.tends_to_max())

func new_prop(id_: String, type_: String, default_):
	props[id_] = ActorProperty.new(id_, type_, default_)
	return props[id_]

func _process(delta):
	for prop_id in props:
		var prop = props[prop_id] as ActorProperty
		match prop.tends_to:
			"max":
				prop.current_value += delta * prop.speed
			"default":
				if prop.current_value < prop.default_value:
					prop.current_value += delta * prop.speed
				elif prop.current_value > prop.default_value:
					prop.current_value -= delta * prop.speed
		prop.current_value = min(prop.current_value, prop.max_value)
		prop.current_value = max(prop.current_value, prop.min_value)
