extends Node2D

var path: Path2D
var pathFollow: PathFollow2D
var line: Line2D

func _ready() -> void:
	path = $Path2D
	pathFollow = $Path2D/PathFollow2D
	drawTrack()

func drawTrack() -> void:
	## Dummy Line
	line = Line2D.new()   
	line.set_antialiased(true)
	line.default_color = Color(0.5,0.5,1,0.5)  
	line.width = 10
	for point in path.curve.get_baked_points():  
		line.add_point(point + path.position)
	get_parent().add_child.call_deferred(line)
	## PathFollow processed line
	
