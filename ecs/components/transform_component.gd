extends Component
class_name TransformComponent

func _init():
	type_id = ComponentType.Type.TRANSFORM

var position: Vector3 = Vector3.ZERO
var rotation: Vector3 = Vector3.ZERO
var scale: Vector3 = Vector3.ONE
