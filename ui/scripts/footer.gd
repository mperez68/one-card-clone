@tool
class_name Footer extends Label


# ENGINE
const PREFIX: String = "GEIST_COMM_GAMES"


# ENGINE
func _ready():
	_update_text()


# PUBLIC


# PRIVATE
func _update_text():
	text = str("%s, %s" % [PREFIX, Time.get_date_dict_from_unix_time(roundi(Time.get_unix_time_from_system())).year])
