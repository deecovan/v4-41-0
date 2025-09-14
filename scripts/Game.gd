extends Node2D

##SQLite DB
var db_path = "res://data/data.db"
var db

func _ready():
	db = SQLite.new()
	db.path = db_path
	if db.open_db() != true:
		print("Error opening database: ", db.error_message)
	else:
		print("Database opened successfully.")
		# Example: Create a table if it doesn't exist
		var query = "CREATE TABLE IF NOT EXISTS players (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)"
		if db.query(query) != true:
			print("Error creating table: ", db.error_message)
		else:
			print("Table created or already exists.")
		db.close_db()

## Main control keys for window and game
func _process(_delta):
	if Input.is_action_just_pressed('reload'):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed('screen'):
		var mode := DisplayServer.window_get_mode()
		var is_window: bool = mode != DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN \
			if is_window else DisplayServer.WINDOW_MODE_WINDOWED)
			
