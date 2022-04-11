tool
extends TileSet

func _is_tile_bound(drawn_id, neighbor_id):
	return neighbor_id in get_tiles_ids()
