class_name GameSettings extends Resource

@export_storage var volumes: Dictionary[String, float] = {
	"Master": 0.8,
	"Music": 0.8,
	"Sfx": 0.8
}
@export_storage var fullscreen: bool = true
@export_storage var borderless: bool = true
