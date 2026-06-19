@tool
class_name GridNode2D extends Node2D

const ENTITY_KEY: String = "entity"

## Emitted after this nodes grid position has changed. It includes the position it moved from.
signal moved(start: Vector3i)

## Emitted after this node changes the direciton it's facing. It includes the facing it started on.
signal turned(start: Facing)

## The four directions this node can face.
enum Facing{ RIGHT, DOWN, LEFT, UP }
## The position on the grid of this node. Represented in increments determined by the TacGrid autoload.
@export var grid_position: Vector3i = Vector3i.ZERO:
	set(value):
		var new_pos: Vector2 = TacGrid.grid_2d_to_global(Vector2i(value.x, value.y))
		if position != new_pos:
			position = new_pos
		var start = grid_position
		grid_position = value
		z_index = value.z
		if !Engine.is_editor_hint() and is_node_ready():
			if blocking:
				var map: Map = TacGrid.get_map()
				map.set_point_disabled(start, false)
				map.set_point_disabled(grid_position)
			moved.emit(start)
## The direciton this node is facing. Calls _update_face() when changed. By default, this changes the rotation of the node to correspond.
@export var facing: Facing = Facing.RIGHT:
	set(value):
		if value == facing:
			return
		var start: Facing = facing
		facing = value
		_update_face()
		if !Engine.is_editor_hint():
			turned.emit(start, self)
@export var snap_to_grid: bool = true:
	set(value):
		snap_to_grid = value
		if snap_to_grid:
			_center()
@export_range(0.0, 10.0, 0.1, "or_greater") var view_range: float:
	set(value):
		view_range = value
		if view_range > 0.0:
			add_to_group(TacGrid.viewer_key)
		else:
			remove_from_group(TacGrid.viewer_key)
## If enabled, blocks pathing on the map.
@export var blocking: bool = false:
	set(value):
		blocking = value
		if !Engine.is_editor_hint() and is_node_ready():
			TacGrid.get_map().set_point_disabled(grid_position, blocking)


# ENGINE
func _ready():
		if Engine.is_editor_hint():
			set_notify_transform(true)
		else:
			blocking = blocking

func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED and snap_to_grid:
		_center()


# PUBLIC
## Moves this node to the target grid position and faces it towards the position from it's starting position.
func face_and_move(target_position: Vector3i):
	facing = to_facing(grid_position, target_position)
	grid_position = target_position

## Find the Facing enum that the first point would have if it was directed at the end point.
## Inputs can be any combination of Vector2, Vector2i, or Vector3i. Returns Facing.RIGHT as default if unput is invalid or the same.
static func to_facing(start, end) -> Facing:
	var valid_start: Vector2 = start if start is Vector2 else Vector2.ZERO
	var valid_end: Vector2 = end if end is Vector2 else Vector2.ZERO
	# Convert start if needed.
	if start is Vector2i:
		valid_start = Vector2(start)
	elif start is Vector3i:
		valid_start = Vector2(start.x, start.y)
	elif valid_start == Vector2.ZERO:
		return Facing.RIGHT
	# Convert end if needed.
	if end is Vector2i:
		valid_end = Vector2(end)
	elif end is Vector3i:
		valid_end = Vector2(end.x, end.y)
	elif valid_end == Vector2.ZERO:
		return Facing.RIGHT
	# Makes it this far if both inputs are valid.
	return _to_facing(valid_start, valid_end)

## Returns the Vector2i representation of the given Facing enum.
static func facing_to_grid_2d(facing: Facing) -> Vector2i:
	match facing:
		Facing.UP:
			return Vector2i.UP
		Facing.DOWN:
			return Vector2i.DOWN
		Facing.LEFT:
			return Vector2i.LEFT
		_:	# Default/Right
			return Vector2i.RIGHT

func set_map_visible(new_visible: bool):
	visible = new_visible

func can_see_target(target: GridNode2D, range: int = 9999, map: Map = null) -> bool:
	if !map:
		map = TacGrid.get_map()
	return map.is_in_range(grid_position, target.grid_position, range, true)

func can_see(target: Vector3i, range: float = 9999.9, map: Map = null) -> bool:
	if !map:
		map = TacGrid.get_map()
	return map.is_in_range(grid_position, target, range, true)


# PRIVATE
func _center():
	var grid_2d: Vector2 = TacGrid.global_to_grid_2d(position)
	grid_position = Vector3i(grid_2d.x, grid_2d.y, grid_position.z)

func _update_face():
	rotation = (PI / 2) * int(facing)

static func _to_facing(start: Vector2, end: Vector2) -> Facing:
	if start == end:
		return Facing.RIGHT
	var difference: float = (end - start).angle()
	if difference < 0:
		difference += 2 * PI
	if difference < PI / 4 or difference >= 7 * PI / 4:
		return Facing.RIGHT
	elif difference < 3 * PI / 4:
		return Facing.DOWN
	elif difference < 5 * PI / 4:
		return Facing.LEFT
	return Facing.UP


# SIGNALS
