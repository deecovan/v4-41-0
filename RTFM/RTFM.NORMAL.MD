To find the normal to a path in Godot, particularly when using PathFollow3D with a Path3D and its Curve3D, you need to retrieve the orientation information provided by the PathFollow3D node itself.

The PathFollow3D node automatically handles the orientation of its children along the Curve3D. When PathFollow3D.rotation_mode is set appropriately (e.g., ROTATION_MODE_Y for aligning the Y-axis to the curve's normal), or when PathFollow3D.loop is enabled for cyclic paths and the PathFollow3D.progress_ratio is used, the node's transform will reflect the correct orientation.

Finding the Normal Vector:

Access the PathFollow3D node: Get a reference to your PathFollow3D node in your script.

Code

    @onready var path_follow_node = $Path3D/PathFollow3D

Retrieve the transform: The PathFollow3D node's transform property contains its position and orientation in 3D space.

Code

    var current_transform = path_follow_node.transform

Extract the normal vector: The normal vector to the path at the PathFollow3D's current position will correspond to one of the basis vectors of its transform, depending on how the PathFollow3D is oriented.

If PathFollow3D.rotation_mode is ROTATION_MODE_Y (default) or similar: The Y-axis (up direction) of the PathFollow3D's transform.basis will typically represent the normal to the path's surface or the "up" direction relative to the path.

Code

    var normal_vector = current_transform.basis.y # Or .x or .z depending on your setup

If PathFollow3D.orient_3d is true: The +Z axis of the PathFollow3D will be oriented along the path's forward direction. In this case, the normal might be the y or x axis of the transform.basis, depending on the desired normal direction relative to the path.

Note: The specific basis vector (x, y, or z) that represents the normal depends on your Path3D's curve definition and the PathFollow3D's rotation_mode and orient_3d settings. Experiment with these to find the correct axis for your specific use case.

Example:

Code

	extends Node3D

	@onready var path_follow_node = $Path3D/PathFollow3D

	func _process(delta):
	    # Get the current transform of the PathFollow3D
	    var current_transform = path_follow_node.transform
	
	    # The normal vector (e.g., the 'up' direction relative to the path)
	    var normal_to_path = current_transform.basis.y

	    # You can now use 'normal_to_path' for various purposes,
	    # such as aligning another object or calculating reflections.
	    # For example, to draw a debug line representing the normal:
	    # draw_line_3d(path_follow_node.global_position, path_follow_node.global_position + normal_to_path * 0.5, Color.BLUE)
