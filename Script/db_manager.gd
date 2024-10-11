extends Object

class_name db_manager
var mobs_database : TextDatabase
var player_database : TextDatabase

func _init():
	mobs_database = TextDatabase.new()
	mobs_database.load_from_path("res://database/mobs.cfg")
	player_database = TextDatabase.new()
	player_database.load_from_path("res://database/player.cfg")

func _ready():
	print(get_item_from_player_table("player").attack)
	print(get_item_from_mob_table("igris"))

func get_mob_table():
	return mobs_database

func get_player_table():
	return player_database
		
func get_item_from_player_table(item_name : String):
	var player_dictionnary := player_database.get_dictionary()
	return player_dictionnary.get(item_name)
		
func get_item_from_mob_table(item_name : String):
	var mobs_dictionnary := mobs_database.get_dictionary()
	return mobs_dictionnary.get(item_name)
