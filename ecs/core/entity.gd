extends RefCounted
class_name Entity

var id: int
var mask: int = 0
var components: Dictionary[int, Component] = {}

var world: World

func add_component(component: Component) -> void:
	components[component.type_id] = component
	mask |= component.type_id
	if world:
		world.clear_cache()

func remove_component(type_id: int) -> void:
	if components.has(type_id):
		components.erase(type_id)
		mask &= ~type_id
		if world:
			world.clear_cache()

func get_component(type_id: int) -> Component:
	return components.get(type_id)

func has_component(type_id: int) -> bool:
	return components.has(type_id)
