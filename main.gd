extends Node3D

var world: World
var test_prefab: EntityPrefab = preload("res://ecs/prefabs/test_prefab.tres")

func _ready():
	world = World.new()
	add_child(world)
	
	var test_character = world.spawn(test_prefab)
	for component in test_character.components.values():
		if component is NodeLinkComponent:
			var scene_node: Node = preload("res://scenes/test_character.tscn").instantiate()
			self.add_child(scene_node)
			component.node = scene_node
