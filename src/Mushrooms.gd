extends TileMap

func get_bounce_dir(pos, nearby = false):
	var tile_pos = world_to_map(pos)
	match get_cellv(tile_pos):
		0:
			return Vector2(0, -1)
		1:
			return Vector2(-1, -0.6)
		2:
			return Vector2(1, -0.6)
		3:
			return Vector2(0, 1)
		-1:
			if nearby:
				return Vector2.ZERO
			var left = get_bounce_dir(pos - Vector2(32, 0), true)
			var right = get_bounce_dir(pos + Vector2(32, 0), true)
			var up = get_bounce_dir(pos - Vector2(0, 32), true)
			var down= get_bounce_dir(pos + Vector2(0, 32), true)
			if left != Vector2.ZERO:
				return left
			elif right != Vector2.ZERO:
				return right
			elif up != Vector2.ZERO:
				return up
			elif down != Vector2.ZERO:
				return down
	return Vector2(0, 0)
