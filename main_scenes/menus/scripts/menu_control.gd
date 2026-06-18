class_name MenuControl extends Control


@export var hide_for_mobile: Array[Control]
@export var song: String = "Menu"

# ENGINE
func _ready():
	if !song.is_empty():
		MusicManager.play(song)
	else:
		MusicManager.stop(false)
	if OS.get_name() == "Web":
		for node in hide_for_mobile:
			node.hide()
	var first_button = _search_for_button(self)
	if first_button:
		first_button.grab_focus()

#func _enter_tree() -> void:
func _init() -> void:
	if SceneManager.transitioning:
		var new_transition: Transition = SceneManager.TRANSITION.instantiate()
		new_transition.fade = "in"
		add_child(new_transition)


# PUBLIC


# PRIVATE
func _search_for_button(root: Node) -> Button:
	if root is Button:
		return root
	for child in root.get_children():
		var temp: Button = _search_for_button(child)
		if temp:
			return temp
	return null


# SIGNALS
func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(meta)
