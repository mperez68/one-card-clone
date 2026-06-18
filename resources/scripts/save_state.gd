class_name SaveState extends Resource

@export_storage var timestamp: Dictionary

func update_timestamp():
	timestamp = Time.get_datetime_dict_from_system()

# Put saved data here with @export_storage.
