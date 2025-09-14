extends Node2D

var track: Path2D
var path: PathFollow2D

var mem = {
	tick  = 0,   ## counted
	delta = 0.0  ## average 
}

var extrem_rot = {
	progress = 0.0,
	rotspeed = 0.0,
	distance = 0.0
}

var speed := 0.0
var gConst: float = 9.8
var gMod: float = 5.0 ## to calculate gConst * gMod
## Each car must be configured
## acceleration limit in g. 
## 2g equals 2 * 9.8 = 19.6  ~20px/s*s * gMod = 100px/s*s
@export var longitude_acc_limit := 2.0 
@export var longitude_decl_limit := 3.0 ## decceleration/braking limit in g.
@export var longitude_coast := -0.01 ## coasting speed delta.
@export var ang_speed    := 0.3   ## max angular speed in radians/s
@export var look_step    := 0.2   ## look step to look ahead (s)
@export var look_ahead   := 2.0    ## look ahead in seconds
@export var max_speed    := 300.0  ## Max speed in pixels/second
#@export var start_offset := 0.0   ## Start position offset in pixels

enum {BRAKE, ACCELERATE, COAST}
var state = ACCELERATE
var new_state = ACCELERATE
var old_state = COAST
var coasting = false

var last_progress_ratio = 1.0 ## 100% on start
var timer: float = 0.0
var tick: int = 0
var leaf: int = 0
var lap_tick: int = 0

func _process(delta: float) -> void:
	timer += delta
	tick += 1
	var _delta = timer / float(tick)
	
	## Save progress
	var current_path_progress = path.progress
	
	if timer * 10 > leaf: ## Do Leaf each 1/10 sec
		do_leaf(delta)
	
	$CyanPoint.hide()
	extrem_rot = find_extrem_rotation(
		current_path_progress, speed, look_ahead, look_step, _delta)
	$CyanPoint.show()
	
	if extrem_rot.rotspeed > ang_speed:
		# Check brake_distance
		if (extrem_rot.progress - current_path_progress) < extrem_rot.brake_distance:
			if change_state(BRAKE):
				$CyanPoint.play("BRAKE")
				get_parent().print_label("State", "Brake")
				get_parent().color_label("State", Color.RED)
				speed = slow_down(delta)
			else: ## coasting
				$CyanPoint.play("COAST")
				get_parent().print_label("State", "Coast")
				get_parent().color_label("State", Color.BLUE)
				speed = coast(delta)
	else:
		if change_state(ACCELERATE) == ACCELERATE:
			$CyanPoint.play("ACCELERATE")
			$AnimatedSprite2D.play("ACCELERATE")
			get_parent().print_label("State", "Accelerate")
			get_parent().color_label("State", Color.GREEN)
			speed = accelerate(delta)
		else: ## coasting
			$CyanPoint.play("COAST")
			get_parent().print_label("State", "Coast")
			get_parent().color_label("State", Color.BLUE)
			speed = coast(delta)
		
	## Restore progress
	path.progress = current_path_progress
	## Update progress
	path.progress  += speed * delta
	
	# Prints debug info if current rotspeed reach the limits.
	var print_rotspeed = abs (
			abs(global_rotation)
			- abs(path.global_rotation))
	get_parent().print_label("Speed", "%.2f" % speed)
	get_parent().print_label("Side", "%.2f" % (print_rotspeed * PI))
	if print_rotspeed > ang_speed:
		## Warning speed
		get_parent().color_label("Side", Color.RED)
	elif print_rotspeed > (ang_speed/10):
		## Notice speed
		get_parent().color_label("Side", Color.YELLOW)
	else:
		## Normal speed
		get_parent().color_label("Side", Color.WHITE)
	
	if path.progress_ratio < last_progress_ratio:
		print ("===============================================================",
		" Lap: ", lap_tick, " time: %.2f" % timer)
		get_parent().print_label("Last", str(lap_tick) + " time: %.2f" % timer)
		lap_tick += 1
		timer = 0.0
		
	# Detect side of rotation and play animation under braking
	if state == BRAKE :
		if abs(global_rotation)-abs(path.global_rotation) > 0:
			$AnimatedSprite2D.flip_v = true
		else:
			$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.play("TURN")
	
	## Move player
	global_rotation = path.global_rotation
	global_position = path.global_position
	last_progress_ratio = path.progress_ratio

func do_leaf(_delta: float) -> void:
	## Ancient code
	#leaf += 1
	pass

func find_extrem_rotation(cur_path_progress, cur_speed, ahead, step, delta):
	var remember_path_progress = path.progress
	path.progress = cur_path_progress
	var ret = {
		progress = cur_path_progress,
		rotspeed = 0.0,
		brake_distance = 0.0
	}
	var check_rotation_from = path.global_rotation
	var last_rotation := 0.0
	for i in range(int(ahead/step), 0, -1):
		var check_position = i * step * cur_speed
		path.progress = cur_path_progress + check_position
		var check_rotation = path.global_rotation
		var cur_rotaton = abs (abs(check_rotation) - abs(check_rotation_from))
		$CyanPoint.hide()
		if cur_rotaton > last_rotation:
			var brake_distance = (
					(cur_rotaton / ang_speed)
					* cur_speed * delta
				) / longitude_decl_limit
			ret = {
				progress = path.progress,
				rotspeed = cur_rotaton,
				brake_distance = brake_distance
			}
			$CyanPoint.global_position = path.global_position
			$CyanPoint.global_rotation = path.global_rotation
			
			
		last_rotation = cur_rotaton
		check_rotation_from = check_rotation
		
	path.progress = remember_path_progress
	return ret
	
func slow_down(delta: float) -> float:
	return clamp(speed - longitude_decl_limit 
	* gConst * gMod * delta, 0, max_speed)
	
func accelerate(delta: float) -> float:
	return clamp(speed + longitude_acc_limit 
	* gConst * gMod * delta, 0, max_speed)
	
func coast(_delta: float) -> float:
	return clamp(speed * (1 + longitude_coast), 0, max_speed)
	
func change_state(set_new_state):
	
	if set_new_state == state or coasting == true:
		return state
	
	old_state = state
	match set_new_state:
		BRAKE:
			if state == ACCELERATE:
				start_coasting(_on_coast_brake)
				return false
		ACCELERATE:
			if state == BRAKE:
				start_coasting(_on_coast_accelerate)
		COAST:
			start_coasting(_on_coast_timeout)
				
	if !coasting:
			state = set_new_state
			
	return state
	
func start_coasting(function) -> void:
	var ctimer = get_tree().create_timer(2.0 * randf())
	ctimer.timeout.connect(function)
	coasting = true
	state = COAST
			
func _on_coast_accelerate() -> void:
	print("_on_coast_accelerate")
	coasting = false
	change_state(ACCELERATE)
			
func _on_coast_brake() -> void:
	print("_on_coast_brake")
	coasting = false
	change_state(BRAKE)
			
func _on_coast_timeout() -> void:
	print("_on_coast_timeout")
	coasting = false
	change_state(COAST)
	
	
