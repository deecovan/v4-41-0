extends Node2D

var path: PathFollow2D
var line: Line2D

var trackDetails: int = 20
var loadedWalls

func _ready() -> void:
	path = find_child("Path")
	loadedWalls = preload("res://scenes/walls.tscn")
	drawTrack()

func drawTrack() -> void:
	## Dummy Line
	line = Line2D.new()   
	line.set_antialiased(true)
	line.default_color = Color(0.5,0.5,1,0.5)  
	line.width = 20
	## Draw walls
	# Remember Last Point to find rotation vector from it
	var lastPoint = Vector2.ZERO
	var lastUnusedPoint = Vector2.ZERO
	var i = 0
	for point in self.curve.get_baked_points():
		var directionTo = lastUnusedPoint.direction_to(point).angle()
		var distanceTo = Vector2(lastPoint - point).length()
		if distanceTo > trackDetails and lastUnusedPoint != Vector2.ZERO:
			var newWalls = loadedWalls.instantiate()
			newWalls.name = "walls" + str(i)
			i += 1
			newWalls.position = point
			newWalls.rotation = directionTo
			add_child(newWalls)
			lastPoint = point
			#printt(lastPoint, point, directionTo)
		lastUnusedPoint = point
		
		line.add_point(point)
		
	get_parent().add_child.call_deferred(line)
