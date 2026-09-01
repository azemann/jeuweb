class_name TerrainCollisionBuilder
extends RefCounted


static func convex_parts(polygon: PackedVector2Array) -> Array[PackedVector2Array]:
	var parts: Array[PackedVector2Array] = []
	var triangle_indices := Geometry2D.triangulate_polygon(polygon)
	for triangle_offset in range(0, triangle_indices.size(), 3):
		if triangle_offset + 2 >= triangle_indices.size():
			break
		var triangle := PackedVector2Array([
			polygon[triangle_indices[triangle_offset]],
			polygon[triangle_indices[triangle_offset + 1]],
			polygon[triangle_indices[triangle_offset + 2]],
		])
		if polygon_area(triangle) > 0.001:
			parts.append(triangle)
	var merged_any := true
	while merged_any:
		merged_any = false
		for first_index in parts.size():
			for second_index in range(first_index + 1, parts.size()):
				var unions := Geometry2D.merge_polygons(parts[first_index], parts[second_index])
				if unions.size() != 1 or not _is_convex_polygon(unions[0]):
					continue
				parts[first_index] = unions[0]
				parts.remove_at(second_index)
				merged_any = true
				break
			if merged_any:
				break
	return parts


static func polygon_area(polygon: PackedVector2Array) -> float:
	var area := 0.0
	for index in polygon.size():
		var next := (index + 1) % polygon.size()
		area += polygon[index].x * polygon[next].y - polygon[next].x * polygon[index].y
	return absf(area) * 0.5


static func _is_convex_polygon(polygon: PackedVector2Array) -> bool:
	if polygon.size() < 3:
		return false
	var winding := 0.0
	for index in polygon.size():
		var edge_a := polygon[(index + 1) % polygon.size()] - polygon[index]
		var edge_b := polygon[(index + 2) % polygon.size()] - polygon[(index + 1) % polygon.size()]
		var cross := edge_a.cross(edge_b)
		if absf(cross) <= 0.001:
			continue
		if winding == 0.0:
			winding = signf(cross)
		elif signf(cross) != winding:
			return false
	return winding != 0.0
