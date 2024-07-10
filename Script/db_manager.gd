extends Node

class_name db_manager

var collection : Collection
# Called when the node enters the scene tree for the first time.
func _ready():
	collection = Collection.new("res://database.tableCollection.res")

func getMobTable():
	if !collection.has_table("mob"): # Checking if the table exist
		push_error("la table 'mob' n'existe pas!")
		return
	else:
		return collection.get_table("mob")

func getPlayerTable():
	if !collection.has_table("player"): # Checking if the table exist
		push_error("la table 'player' n'existe pas!")
		return
	else:
		return collection.get_table("player")
		
func getItemFromPlayerTable(item_name : String):
	var datatable : Datatable = getPlayerTable()
	if !datatable.has_item(item_name):
		push_error("la table 'player' n'as pas d'item "+item_name)
		return
	else:
		return datatable.get_item(item_name)
		
func getItemFromMobTable(item_name : String):
	var datatable : Datatable = getMobTable()
	if !datatable.has_item(item_name):
		push_error("la table 'mob' n'as pas d'item "+item_name)
		return
	else:
		return datatable.get_item(item_name)
