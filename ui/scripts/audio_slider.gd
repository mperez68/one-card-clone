@tool
class_name AudioSlider extends Control

@export_enum("Master", "Music", "Sfx") var bus: String = "Master":
	set(value):
		bus = value
		if title_label:
			title_label.text = bus

@onready var audio_bus: int = AudioServer.get_bus_index(bus)
@onready var slider: HSlider = %Slider
@onready var title_label: Label = %TitleLabel


# ENGINE
func _ready():
	bus = bus
	if Engine.is_editor_hint():
		return
	slider.value = AudioServer.get_bus_volume_linear(audio_bus)
	slider.value_changed.connect(_on_value_changed)


# PUBLIC


# PRIVATE


# SIGNALS
func _on_value_changed(new_value: float) -> void:
	if Engine.is_editor_hint():
		return
	SfxManager.play(SfxManager.Sfx.CLICK)
	SettingsManager.game_settings.volumes[bus] = new_value
	AudioServer.set_bus_volume_linear(audio_bus, new_value)
