@tool
extends Node

enum Shape
{
	SQUARE,		# Maps with the Tile Shape Square.
	DIAMOND		# Maps with the TIle Shape Isometric and Tile Layout Diamond Down.
}

## Grid size for all maps.
@export var grid_size: Vector2 = Vector2(16, 16)
@export var shape: Shape = Shape.SQUARE
## The custom data key to represent tiles that can be navigated on. If left empty, it assumes players can navigate on any placed tile.
@export_placeholder("None") var platform_key: String = "platform"
## The custom data key to represent tiles that block visibility. If left empty, it assumes players can see through any tile.
@export_placeholder("None") var blocking_key: String = "blocking"
## The node group key of nodes that determine cleared fog. If left empty fog is not used.
@export_placeholder("None") var viewer_key: String = "viewer"

var cached_map: Map


# PUBLIC
## Returns the first map found in the current scene (or in a given tree if provided).
func get_map() -> Map:
	return cached_map if is_instance_valid(cached_map) else _get_map(get_tree().current_scene)

## Returns an unmapped position that the given Vector2i representation of the grid corresponds to. A returned position does NOT indicate that the position exists on the current scenes map.
func grid_2d_to_global(value: Vector2i) -> Vector2:
	var offset: Vector2 = grid_size / 2
	var ret: Vector2 = offset
	match shape:
		Shape.SQUARE:
			ret += grid_size * Vector2(value.x, value.y)
		Shape.DIAMOND:
			ret += offset * (Vector2(value.x - value.y, value.x + value.y))
	return ret

## Returns an unmapped grid coordinate that the given global position corresponds to. A returned position does NOT indicate that the position exists on the current scenes map.
func global_to_grid_2d(value: Vector2) -> Vector2i:
	var ret: Vector2i = Vector2i.ZERO
	match shape:
		Shape.SQUARE:
			ret = Vector2i(floori(value.x / grid_size.x), floori(value.y / grid_size.y))
		Shape.DIAMOND:
			var with_offset: Vector2 = value - (grid_size / 2)
			ret = Vector2i(roundi(with_offset.x / grid_size.x + with_offset.y / grid_size.y), 
							roundi(-with_offset.x / grid_size.x + with_offset.y / grid_size.y))
	return ret


# PRIVATE
func _get_map(parent: Node) -> Map:
	if !parent:
		return
	if parent is Map:
		return parent
	for child in parent.get_children():
		var ret = _get_map(child)
		if ret != null:
			return ret
	return null
