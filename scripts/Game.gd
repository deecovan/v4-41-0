extends Node2D

##SQLite DB
var db_path = "res://data/data.db"
var db

func _ready():
	## SQLite implementation
	#db = SQLite.new()
	#db.path = db_path
	#if db.open_db() != true:
		#print("Error opening database: ", db.error_message)
	#else:
		## Example: Create a table if it doesn't exist
		#var query = "CREATE TABLE IF NOT EXISTS 
		#players (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)"
		#if db.query(query) != true:
			#print("Error creating table: ", db.error_message)
		#else:
			#var rand = RandomNumberGenerator.new()
			#var player_name = str(rand.randi() * rand.randi())
			#query = "INSERT INTO players(name) VALUES (" + player_name + ");"
			#if db.query(query) != true:
				#print("Error in query: ", query, db.error_message)
			#else:
				#query = "SELECT * FROM players ORDER BY id DESC LIMIT 2;"
				#print(query, " > ", db.query(query))
				#if not db.query_result.is_empty():
					#print(var_to_str(db.query_result))
		#db.close_db()
	pass

## Main control keys for window and game
func _process(_delta):
	if Input.is_action_just_pressed('reload'):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed('screen'):
		var mode := DisplayServer.window_get_mode()
		var is_window: bool = mode != DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN \
			if is_window else DisplayServer.WINDOW_MODE_WINDOWED)
			
