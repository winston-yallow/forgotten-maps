class_name MeshBuilder
extends RefCounted


static func from_markers(markers: Array[MapMarker], img_size: Vector2) -> ArrayMesh:
	# Generate list of raw points and offsets
	var points := PackedVector2Array()
	var offsets := PackedVector2Array()
	for marker in markers:
		points.append(marker.canvas_pos)
		offsets.append(marker.map_pos - marker.canvas_pos)
	
	# Expand the outline to cover more area
	# (copies closest vertices offset to the new vertices)
	var hull := Geometry2D.convex_hull(points).slice(0, -1)
	# TODO: Handle invalid hulls (all points at same location)
	var extended_hull := Geometry2D.offset_polygon(hull, 100.0)[0]
	for vertex in extended_hull:
		var closest_offset := Vector2.INF
		var closest_dist := INF
		for idx in points.size():
			var dist := vertex.distance_squared_to(points[idx])
			if dist < closest_dist:
				closest_offset = offsets[idx]
				closest_dist = dist
		offsets.append(closest_offset)
	points.append_array(extended_hull)
	
	# Triangulate the pointcloud
	var triangle_indices := Geometry2D.triangulate_delaunay(points)
	var triangle_points: Array[PackedVector2Array] = []
	var triangle_offsets: Array[PackedVector2Array] = []
	for indices_idx in range(0, triangle_indices.size(), 3):
		var idx_a := triangle_indices[indices_idx]
		var idx_b := triangle_indices[indices_idx + 1]
		var idx_c := triangle_indices[indices_idx + 2]
		triangle_points.append(PackedVector2Array([
			points[idx_a], points[idx_b], points[idx_c]
		]))
		triangle_offsets.append(PackedVector2Array([
			offsets[idx_a], offsets[idx_b], offsets[idx_c]
		]))
	
	# Create mesh
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for triangle_idx in triangle_points.size():
		for local_idx in 3:
			var point := triangle_points[triangle_idx][local_idx]
			var offset := triangle_offsets[triangle_idx][local_idx]
			var texture_pos := point + offset
			var uv := texture_pos / img_size
			st.set_uv(uv)
			st.add_vertex(Vector3(point.x, point.y, 0.0))
	return st.commit()
