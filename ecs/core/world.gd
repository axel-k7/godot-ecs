extends Node
class_name World

var _entities: Array[Entity] = []
var _systems: Array[System] = []
var _query_cache: Dictionary = {} #int -> Array[Entity] (doesnt support nested collections)
var _next_id: int = 1

var _pending_destroy: Array[int] = []

var _event_listeners: Dictionary = {} #event name -> Array[{listener: Callable, scope: Object}]
var _event_queue: Array[Dictionary] = []

var _entity_pool: Array[Entity] = []

func spawn(prefab: EntityPrefab) -> Entity:
	var e := create_entity()
	for c in prefab.components:
		e.add_component(c.duplicate())
	return e

func create_entity() -> Entity:
	var e: Entity
	if _entity_pool.is_empty():
		e = Entity.new()
	else:
		e = _entity_pool.pop_back()
	
	e.id = _next_id
	e.world = self
	_next_id += 1
	_entities.append(e)
	return e

func destroy_entity(entity: Entity) -> void:
	if entity and entity.id > 0:
		_pending_destroy.append(entity.id)
		_entity_pool.append(entity)

func add_system(system: System) -> void:
	_systems.append(system)
	_systems.sort_custom(func(a, b): return a.priority < b.priority)

func remove_system(system: System) -> void:
	if _systems.has(system):
		_systems.erase(system)
		remove_listener_by_scope(system)

func _make_query_mask(types: Array[int]) -> int:
	var mask := 0
	for t in types:
		mask |= t
	return mask

func query(component_types: Array[int]) -> Array[Entity]:
	var query_mask := _make_query_mask(component_types)
	
	if _query_cache.has(query_mask):
		return _query_cache[query_mask]
	
	var result: Array[Entity] = []
	for e in _entities:
		if (e.mask & query_mask) == query_mask:
			result.append(e)
	_query_cache[query_mask] = result
	return result

func query_with_filter(include: Array[int], exclude: Array[int]) -> Array[Entity]:
	var include_mask := _make_query_mask(include)
	var exclude_mask := _make_query_mask(exclude)
	
	var result: Array[Entity] = []
	for e in _entities:
		if (e.mask & include_mask) == include_mask and (e.mask & exclude_mask) == 0:
			result.append(e)
	return result

func _cleanup_entites() -> void:
	if _pending_destroy.is_empty():
		return
	for id in _pending_destroy:
		for i in range(_entities.size() - 1, -1, -1):
			if _entities[i].id == id:
				_entities.remove_at(i)
	_pending_destroy.clear()
	clear_cache()

func clear_cache() -> void:
	_query_cache.clear()

#run immediately
func emit_event(event_name: String, data: Dictionary = {}) -> void:
	if _event_listeners.has(event_name):
		for callable in _event_listeners[event_name]:
			callable.call(data)

#run after all system updates
func queue_event(event_name: String, data: Dictionary = {}) -> void:
	_event_queue.append( {"name": event_name, "data": data } )

func on(event_name: String, listener: Callable, scope: Object) -> void:
	if not _event_listeners.has(event_name):
		_event_listeners[event_name] = []
	_event_listeners[event_name].append({ "listener": listener, "scope": scope })

func off(event_name: String, listener: Callable) -> void:
	if _event_listeners.has(event_name):
		_event_listeners[event_name].erase(listener)
		if _event_listeners[event_name].is_empty():
			_event_listeners.erase(event_name)

func remove_listener_by_scope(scope: Object) -> void:
	for event_name in _event_listeners.keys():
		var updated_list := []
		for entry in _event_listeners[event_name]:
			if entry["scope"] != scope:
				updated_list.append(entry)
		if updated_list.is_empty():
			_event_listeners.erase(event_name)
		else:
			_event_listeners[event_name] = updated_list


func _process_event_queue() -> void:
	if _event_queue.is_empty():
		return
	
	for ev in _event_queue:
		var event_name: String = ev["name"]
		
		if _event_listeners.has(event_name):
			for entry in _event_listeners[event_name]:
				entry["listener"].call(ev["data"])
				
	_event_queue.clear()

func _process(delta: float) -> void:
	for s in _systems:
		s.update(delta, self)
		
	_process_event_queue()
	_cleanup_entites()


##debug tools----------------------------------

func get_component_count(type_id: int) -> int:
	var count := 0
	for e in _entities:
		if e.has_component(type_id):
			count += 1
	return count

func debug_listeners():
	for name in _event_listeners.keys():
		print(name, " has ", _event_listeners[name].size(), " listeners")


func print_summary() -> void:
	print(self.name, " has ", _entities.size(), " entities, and ", _systems.size(), " systems")
