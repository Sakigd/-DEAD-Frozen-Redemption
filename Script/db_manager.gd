extends Object

class_name db_manager

var collection : Collection

func _init():
	collection = Collection.new("res://database.tableCollection.res")

func get_mob_table():
	if !collection.has_table("mob"): # Checking if the table exist
		push_error("la table 'mob' n'existe pas!")
		return
	else:
		return collection.get_table("mob")

func get_player_table():
	if !collection.has_table("player"): # Checking if the table exist
		push_error("la table 'player' n'existe pas!")
		return
	else:
		return collection.get_table("player")
		
func get_item_from_player_table(item_name : String):
	var datatable : Datatable = get_player_table()
	if !datatable.has_item(item_name):
		push_error("la table 'player' n'as pas d'item "+item_name)
		return
	else:
		var item : Dictionary = datatable.get_item(item_name)
		return item
		
func get_item_from_mob_table(item_name : String):
	var datatable : Datatable = get_mob_table()
	if !datatable.has_item(item_name):
		push_error("la table 'mob' n'as pas d'item "+item_name)
		return
	else:
		var item : Dictionary = datatable.get_item(item_name)
		return item
