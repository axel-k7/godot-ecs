extends System
class_name RenderSyncSystem

func _init():
	priority = 100

func update(_delta: float, world: World) -> void:
	for e in world.query([ComponentType.Type.TRANSFORM, ComponentType.Type.NODE_LINK]):
		var transform = e.get_component(ComponentType.Type.TRANSFORM) as TransformComponent
		var link = e.get_component(ComponentType.Type.TRANSFORM) as NodeLinkComponent
		if link.node and link.node.is_inside_tree():
			link.node.global_position = transform.position
			link.node.rotation = transform.rotation
