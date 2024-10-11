extends TextDatabase

func _schema_initialize():
	add_mandatory_property("health", TYPE_INT)
	add_mandatory_property("attack", TYPE_INT)
	add_mandatory_property("cendre_gelee", TYPE_INT)
