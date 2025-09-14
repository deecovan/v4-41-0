In Godot, to find the intersection point of two lines, the Geometry singleton provides methods for both line segments and infinite lines.

1. Intersecting Line Segments:

To find the intersection of two line segments, use the segment_intersects_segment_2d method:

Code

	var line1_start = Vector2(0, 0)
	var line1_end = Vector2(100, 100)
	var line2_start = Vector2(0, 100)
	var line2_end = Vector2(100, 0)

	var intersection_point = Geometry.segment_intersects_segment_2d(line1_start, line1_end, line2_start, line2_end)

	if intersection_point != null:
	    print("Intersection point: ", intersection_point)
	else:
	    print("Segments do not intersect.")

2. Intersecting Infinite Lines:

To find the intersection of two infinite lines, specified by a starting point and a direction vector, use the line_intersects_line_2d method:

Code

	var line1_from = Vector2(0, 0)
	var line1_dir = Vector2(1, 1) # Represents a line extending from (0,0) in direction (1,1)
	var line2_from = Vector2(0, 100)
	var line2_dir = Vector2(1, -1) # Represents a line extending from (0,100) in direction (1,-1)

	var intersection_point = Geometry.line_intersects_line_2d(line1_from, line1_dir, line2_from, line2_dir)
	
	if intersection_point != null:
	    print("Intersection point: ", intersection_point)
	else:
	    print("Lines do not intersect (they are parallel).")

Explanation:

segment_intersects_segment_2d:

This method takes the start and end points of two line segments as Vector2 arguments. It returns the Vector2 intersection point if they intersect, otherwise it returns null.

line_intersects_line_2d:

This method takes a starting point and a direction vector for each line as Vector2 arguments. It returns the Vector2 intersection point if they intersect, otherwise it returns null (indicating parallel lines).

Both methods are part of the Geometry singleton, which provides various geometric utility functions in Godot.