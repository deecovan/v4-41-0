extends Node2D

var track: Path2D
var path: PathFollow2D
## Car original size 32 x 16 px (3.2 x 1.6 meters)
## 1 meter == 10 pixels
var meter: float ## get from Track.meter

var mem = {
	tick  = 0,   ## counted
	delta = 0.0  ## average 
}

var extrem_rot = {
	progress = 0.0,
	rotspeed = 0.0,
	distance = 0.0
}

var params = {
	param_await = 0.2,
	error_await = 0.2
}

var speed := 0.0
var gConst := 9.8
var gMod := 1.0 ## to calculate gConst * gMod
## Each car must be configured
## acceleration limit in g. 
## 2g equals 2 * 9.8 = 19.6  ~20px/s*s * gMod = 100px/s*s
@export var longitude_acc_limit := 3.0 
@export var longitude_decl_limit := 3.0 ## decceleration/braking limit in g.
@export var longitude_coast := -0.01 ## coasting speed delta.
@export var centrifugal_acc_limit = 3 ## Limit Centrifugal Acceleration
@export var centrifugal_acc_gate = 1 ## (Limit-Gate) = Good Acceleration
@export var max_rotspeed_value = 100 ## Key to calculate rotation speed
@export var ang_speed    := 0.3   ## max angular speed in radians/s
@export var look_step    := 0.2   ## look step to look ahead (s)
@export var look_ahead   := 3.0    ## look ahead in seconds
## Max speed in meter/second
## 216 km/h = 60 m/s = 216 px/s
@export var max_speed    := 216
#@export var start_offset := 0.0   ## Start position offset in pixels

enum {BRAKE, ACCELERATE, COAST, AWAIT}
var state = ACCELERATE
var new_state = ACCELERATE

var last_progress_ratio = 0.0 ## 100% on start
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
	if extrem_rot.brake_distance > 0:
		$CyanPoint.show()
	
	## If it see Apex (Extremum point 
	## with angular speed more than allowed for current speed) 
	if extrem_rot.rotspeed > ang_speed:
		# Check brake_distance and start brake
		if (extrem_rot.progress - current_path_progress) < extrem_rot.brake_distance:
			if change_state(BRAKE):
				#print("change_state(BRAKE)")
				$CyanPoint.play("BRAKE")
				$AnimatedSprite2D.play("BRAKE")
				get_parent().print_label("State", "Brake")
				get_parent().color_label("State", Color.RED)
				speed = slow_down(delta)
		# If not in brake_distance than start coast
		else:
			change_state(COAST)
	
	## It dont see Apex 
	elif change_state(ACCELERATE):
			#print("change_state(ACCELERATE)")
			$CyanPoint.play("ACCELERATE")
			$AnimatedSprite2D.play("ACCELERATE")
			get_parent().print_label("State", "Accelerate")
			get_parent().color_label("State", Color.GREEN)
			speed = accelerate(delta)
	
	## State changed and start_coasting timer started with 
	## next _on_coast_accelerate or _on_coast_brake call
	if state == COAST:
		#print("state == COAST")
		$CyanPoint.play("COAST")
		$AnimatedSprite2D.play("COAST")
		get_parent().print_label("State", "Coast")
		get_parent().color_label("State", Color.BLUE)
		speed = coast(delta)
	## Show if awaiting
	if state == AWAIT:
		get_parent().print_label("State", "Await")
		get_parent().color_label("State", Color.YELLOW)
		$CyanPoint.play("AWAIT")
		
	## Restore progress
	path.progress = current_path_progress
	## Store current path rotation
	var prev_path_global_rotation = path.global_rotation
	## Update progress
	path.progress  += speed * delta
	## Get delta rotation
	var delta_rotspeed_value = \
		abs( abs(prev_path_global_rotation)
		   - abs(path.global_rotation) ) / delta
	var delta_rotspeed = delta_rotspeed_value / max_rotspeed_value
	# Prints debug info if current rotspeed reach the limits.
	var print_rotspeed = \
		abs( abs(global_rotation) 
		   - abs(path.global_rotation) )
	## a=Vw, <- Fц =m(V^2)/r = m(w^2)r = m(V/r)wr = mVw = Pw,
	## calc Centrifugal Acceleration, must be in range [min..max]
	var print_cacc = speed * delta_rotspeed
	## Print into Control Overlay
	get_parent().print_label("Speed", "%.2f" % speed)
	get_parent().print_label("Vw", "%.2f" % (print_cacc))
	if print_cacc > centrifugal_acc_limit:
		## Warning acceleration
		get_parent().color_label("Vw", Color.RED)
	elif print_rotspeed > (centrifugal_acc_limit - centrifugal_acc_gate):
		## Notice acceleration
		get_parent().color_label("Vw", Color.YELLOW)
	else:
		## Normal acceleration
		get_parent().color_label("Vw", Color.WHITE)
	
	## Lap tracking and debug message
	if path.progress_ratio < last_progress_ratio:
		print ("===============================================================",
		" Lap: ", lap_tick, " time: %.2f" % timer)
		get_parent().print_label("Last", str(lap_tick) + " time: %.2f" % timer)
		lap_tick += 1
		timer = 0.0
		
	## Detect side of rotation and play animation under braking
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

	## Look ahead
	$CyanPoint.hide()
	for i in range(int(ahead/step), 0, -1):
		var check_position = i * step * cur_speed
		path.progress = cur_path_progress + check_position
		var check_rotation = path.global_rotation
		var cur_rotaton = abs (abs(check_rotation) - abs(check_rotation_from))
		
		if cur_rotaton > last_rotation:
			var brake_distance = (
					(cur_rotaton / ang_speed)
					* cur_speed * cur_speed * delta
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
	var slow_speed = speed - longitude_decl_limit * gConst * gMod * delta
	#printt("slow_down", speed, slow_speed)
	return clamp(slow_speed, 0, max_speed)
	
func accelerate(delta: float) -> float:
	var fast_speed = speed + longitude_acc_limit * gConst * gMod * delta
	return clamp(fast_speed, 0, max_speed)
	
func coast(_delta: float) -> float:
	return clamp(speed * (1 + longitude_coast), 0, max_speed)
	
func change_state(set_new_state) -> bool:
	if set_new_state == state:
		#print("set_new_state == state")
		return true
	match set_new_state:
		BRAKE:
			#print("match BRAKE")
			if state == ACCELERATE:
				#print("state == ACCELERATE")
				start_coasting(_on_coast_brake)
				return false
			elif state == AWAIT:
				## timer running
				return false
			elif state == COAST:
				#print("state == COAST(1)")
				state = BRAKE
				return true
		ACCELERATE:
			#print("match ACCELERATE")
			if state == BRAKE:
				#print("state == BRAKE")
				start_coasting(_on_coast_accelerate)
				return false
			elif state == AWAIT:
				## timer running
				return false
			elif state == COAST:
				#print("state == COAST(2)")
				state = ACCELERATE
				return true
		COAST:
			state = COAST
			return true
	## !!Can't match set_new_state
	printerr("!!Can't match set_new_state " + var_to_str(set_new_state))
	return false
	
func start_coasting(function) -> void:
	#print("start_coasting(function)",var_to_str(function))
	## Calculate player's await time
	var ctime = params.param_await + randf() * params.error_await
	var ctimer = get_tree().create_timer(ctime)
	state = AWAIT
	ctimer.timeout.connect(function)
	#print(str(function))

func _on_coast_accelerate() -> void:
	#print("_on_coast_accelerate")
	state = COAST
	change_state(ACCELERATE)
			
func _on_coast_brake() -> void:
	#print("_on_coast_brake")
	state = COAST
	change_state(BRAKE)
