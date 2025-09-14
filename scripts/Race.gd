extends Node2D

var track: Path2D
var path: PathFollow2D
var control: Control

var timer: float = 0.0
var tick: int = 0

func _ready() -> void:
	var players = get_tree().get_nodes_in_group("Players")
	for player in players:
		player.track = self.find_child("Track")
		player.path = player.track.find_child("Path")
		printt(player.track, player.path)
	control = self.find_child("Control")
		
func print_label(label: StringName, text: String) -> void:
	var is_label = control.find_child(label)
	if is_label:
		is_label.text = text

	
func color_label(label: StringName, color: Color) -> void:
	var is_label = control.find_child(label)
	if is_label:
		is_label.set("theme_override_colors/font_color", color)

func _process(_delta: float) -> void:
	## Ancient code
	#timer += delta
	#if int(timer) > tick: ## Next Tick
		#do_tick(delta)
	pass

## Process Tick
func do_tick(_delta) -> void:
	## Ancient code
	#tick += 1
	#if(tick % 1 == 0):
		#pass
	pass
