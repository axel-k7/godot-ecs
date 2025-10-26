extends Node3D

var world: World
var test_prefab: EntityPrefab = preload("res://ecs/prefabs/test_prefab.tres")

func _ready():
	world = World.new()
	add_child(world)
	world.add_system(MovementSystem.new())
	world.add_system(RenderSyncSystem.new())
	
	world.spawn(test_prefab, self)
