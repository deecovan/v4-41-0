Storing data in SQLite within a Godot project involves the following steps:

Install the Godot SQLite Add-on:

Open the Godot editor and navigate to the AssetLib tab.

Search for "godot-sqlite" and download/install the version by "too shady for you."

Alternatively, download the build files manually from the GitHub repository and integrate them into your project.

Activate the plugin in your project settings under the "Plugins" tab.

Create a Database File:

Create a new folder within your Godot project (e.g., "data") to store the database file.

Use a tool like DB Browser for SQLite to create a new .db file within this folder (e.g., data.db).

Define your database schema by creating tables and columns as needed (e.g., a "players" table with "id" and "name" columns).

Connect and Interact with SQLite in Godot:

Attach a script to a node in your Godot scene.

In the script, preload the SQLite constant and define the path to your database file:

Code

        const SQLite = preload("res://addons/godot-sqlite/sqlite.gdns")
        var db_path = "res://data/data.db"
        var db

In the \_ready() function or another appropriate location, initialize the SQLite object and set its path:

Code

        func _ready():
            db = SQLite.new()
            db.path = db_path
            if db.open_db() != OK:
                print("Error opening database: ", db.error_message)
            else:
                print("Database opened successfully.")
                // Example: Create a table if it doesn't exist
                var query = "CREATE TABLE IF NOT EXISTS players (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)"
                if db.query(query) != OK:
                    print("Error creating table: ", db.error_message)
                else:
                    print("Table created or already exists.")
                db.close_db()

To insert data.

Code

        func insert_player_data(player_name):
            db.open_db()
            var query = "INSERT INTO players (name) VALUES (?)"
            var params = [player_name]
            if db.query(query, params) != OK:
                print("Error inserting data: ", db.error_message)
            else:
                print("Player inserted: ", player_name)
            db.close_db()

To retrieve data.

Code

        func get_player_data():
            db.open_db()
            var query = "SELECT * FROM players"
            if db.query(query) != OK:
                print("Error querying data: ", db.error_message)
            else:
                var result = db.query_result
                for row in result:
                    print("Player ID: ", row["id"], ", Name: ", row["name"])
            db.close_db()

Remember to open the database connection (db.open_db()) before executing queries and close it (db.close_db()) afterwards.