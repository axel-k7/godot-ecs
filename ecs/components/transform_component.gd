extends Component
class_name TransformComponent

func _init():
	type_id = ComponentType.Type.TRANSFORM

var position: Vector3
var rotation: float
var scale: Vector3 = Vector3.ONE
