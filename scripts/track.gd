extends Node2D

var path: PathFollow2D
## Draw track using 2 lines
var line1: Line2D
var line2: Line2D

## Car original size 32 x 16 px (4 x 2 meters)
## 1 meter == 8 pixels
@export var meter = 8.0
## Details destribution 20 pixels !PLUS Pathath step
@export var trackDetails: int = 20 
## Walls(Paper Boxes) size 20
var loadedWalls

func _ready() -> void:
	path = find_child("Path")
	loadedWalls = preload("res://scenes/walls.tscn")
	drawTrack()

func drawTrack() -> void:
	## Track Clear Line
	line1 = Line2D.new()   
	line1.set_antialiased(true)
	line1.default_color = Color(0.5,0.5,1,0.5)  
	## Clear Line width 4 meters
	line1.width = meter * 4
	line1.z_index = 499
	## Track Side Line
	line2 = Line2D.new()   
	line2.set_antialiased(true)
	line2.default_color = Color(0.75,0.75,0.5,0.5)  
	## Side Line width 8 meters
	line2.width = meter * 8
	line1.z_index = 488
	## Draw walls
	# Remember Last Point to find rotation vector from it
	var lastPoint = Vector2.ZERO
	var lastUnusedPoint = Vector2.ZERO
	var i = 0
	for point in self.curve.get_baked_points():
		var directionTo = lastUnusedPoint.direction_to(point).angle()
		var distanceTo = Vector2(lastPoint - point).length()
		## Draw Paper Boxes(Walls) distributed by trackDetails pixels
		#if distanceTo > trackDetails and lastUnusedPoint != Vector2.ZERO:
			#var newWalls = loadedWalls.instantiate()
			#newWalls.name = "walls" + str(i)
			#i += 1
			#newWalls.position = point
			#newWalls.rotation = directionTo
			#add_child(newWalls)
			#lastPoint = point
			##printt(lastPoint, point, directionTo)
		lastUnusedPoint = point
		
		line1.add_point(point)
		line2.add_point(point)
		
	get_parent().add_child.call_deferred(line1)
	get_parent().add_child.call_deferred(line2)
