extends Node2D

var path: Path2D
var pathFollow: PathFollow2D
var line: Line2D
@export var trackDetails: int = 100
@export var wallsPackedScene: PackedScene
var loadedWalls

func _ready() -> void:
	path = $Path2D
	pathFollow = $Path2D/PathFollow2D
	loadedWalls = preload("res://scenes/walls.tscn")
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
	## PathFollow processed track
	var pathPoint: float
	var pathPointPosition
	var pathPointRotation
	for i in trackDetails:
		pathPoint = float(i)/trackDetails
		pathFollow.progress_ratio = pathPoint
		pathPointPosition = pathFollow.position
		pathPointRotation = pathFollow.rotation
		printt(i, trackDetails, pathPoint, pathPointPosition, pathPointRotation)
		## Instantiate Walls at this point
		var newWalls = loadedWalls.instantiate()
		newWalls.name = "walls" + str(i)
		newWalls.position = pathPointPosition
		newWalls.rotation = pathPointRotation
		add_child(newWalls)
		
