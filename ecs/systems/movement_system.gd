extends System
class_name MovementSystem

func update(delta: float, world: World) -> void:
	for entity in world.query([ComponentType.Type.TRANSFORM, ComponentType.Type.VELOCITY]):
		var transform = entity.get_component(ComponentType.Type.TRANSFORM) as TransformComponent
		var velocity = entity.get_component(ComponentType.Type.VELOCITY) as VelocityComponent
		transform.position += velocity.velocity * delta
