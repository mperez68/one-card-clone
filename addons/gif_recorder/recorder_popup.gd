@tool
extends Control

var is_dragging := false
var is_pressing := false
var initial_pos := Vector2.ZERO
var last_drag_pos := Vector2.ZERO

@export var record_area : Control
@export var input_area : Control
@export var width_edit : LineEdit
@export var height_edit : LineEdit

var request_record := false
var is_recording := false
@export var idle_color := Color.WHITE
@export var recording_color := Color.ORANGE
@export var borders : Array[ColorRect]

@export var idle_button_texture : Texture2D
@export var recording_button_texture : Texture2D
@export var record_button: TextureButton

@export var move_button: TextureButton
@export var idle_move_texture : Texture2D
@export var pressed_move_texture : Texture2D

var is_60fps = false
@export var frame_counter : Label

@export var parameter_toggle : CheckBox
@export var parameters_node : Control

@export var scale_options : OptionButton

var laste_frame_date = 0
var frames : Array[Image]

@export var export_option_button : OptionButton
enum ExportMode {FFMPEG, GIFSKI, NULL}
var export_mode := ExportMode.FFMPEG

func _ready() -> void:
	hide()
	_size_changed("")
	frame_counter.text = ""
	parameter_toggle.toggled.connect(_toggle_parameters)
	_toggle_parameters(parameter_toggle.button_pressed)
	
	export_mode = ExportMode.NULL
	#var exit_code = OS.execute("gifski", ["-V"])
	#if exit_code == 0:
		#export_mode = ExportMode.GIFSKI
		#export_option_button.select(1)
	#else:
		#exit_code = OS.execute("ffmpeg", ["-version"])
		#if exit_code == 0:
			#export_mode = ExportMode.FFMPEG
			#export_option_button.select(0)
			#
	#if export_mode == ExportMode.NULL:
		#pass
		#printerr("Missing ffmpeg or GifSki to generate gif")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_gif_recorder") and OS.is_debug_build():
		visible = !visible

func _toggle_parameters(toggled: bool):
	parameters_node.visible = toggled

func _drag_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			initial_pos = event.position
			is_pressing = true
			move_button.texture_normal = idle_move_texture
		elif event.is_released():
			is_pressing = false
			is_dragging = false
			move_button.texture_normal = pressed_move_texture
	elif event is InputEventMouseMotion and is_pressing:
		if not is_dragging:
			var distance = event.position.distance_to(initial_pos)
			if distance > 10:
				is_dragging = true
				last_drag_pos = event.global_position
		
		if is_dragging:	
			var mouse_pos = event.global_position
			var drag = mouse_pos - last_drag_pos
			last_drag_pos = mouse_pos
			set_global_position(global_position + drag)
			
	if event is InputEventMouseButton and event.double_click:
		_toggle_input_position()
		
func _size_changed(text: String) -> void:
	var width = int(width_edit.text)
	var height = int(height_edit.text)
	record_area.set_custom_minimum_size(Vector2(width, height))

func set_border_colors(color) -> void:
	for border in borders:
		border.set_color(color)

func _toggle_input_position()->void:
	if input_area.position.x == 0:
		input_area.position.x = - input_area.size.x
		input_area.position.y = input_area.size.y * 2
	else :
		input_area.position.x = 0
		input_area.position.y = 0
		
func _record_pressed() -> void:
	if not is_recording:
		request_record = true
		
		print("record")
		set_border_colors(recording_color)
		record_button.texture_normal = recording_button_texture
	else: 
		is_recording = false
		print("stop record")
		set_border_colors(idle_color)
		record_button.texture_normal = idle_button_texture
		save_frames()

func toggle_fps_mode(is_toggle: bool) -> void:
	is_60fps = is_toggle
	
func set_recorder_mode(mode_index: int) -> void:
	var mode_name = export_option_button.get_item_text(mode_index)
	if mode_name == "FFMPEG":
		export_mode = ExportMode.FFMPEG
	elif mode_name == "GIFSKI":
		export_mode = ExportMode.GIFSKI
	else:
		printerr("unkown option ", mode_name)
	
func _process(_delta: float) -> void:
	if request_record:
		request_record = false
		is_recording = true
		return
		
	if is_recording:
		var current_time = Time.get_ticks_msec()
		var time_to_frame = 32
		if is_60fps:
			time_to_frame = 16
		if (current_time - laste_frame_date < time_to_frame):
			return
			
		var screen_image = get_tree().root.get_texture().get_image()
		var area_rect = record_area.get_global_rect()
		var area_img = screen_image.get_region(area_rect)
		
		laste_frame_date = current_time
		frames.append(area_img)
		frame_counter.text = "%03d" % frames.size()
		
func save_frames():
	if frames.size() == 0:
		return
		
	print("saving to gif %d frames" % frames.size())
	var temp_dir = "user://.temp"
	var frames_dir_path = "%s/frames" % temp_dir
	
	if DirAccess.dir_exists_absolute(frames_dir_path):
		remove_recursive_directory(frames_dir_path)
		
	DirAccess.make_dir_recursive_absolute(frames_dir_path)
	for index in range(0,frames.size()):
		var frame_name = "%s/frame%04d.png" % [frames_dir_path, index]
		var image = frames[index]
		image.convert(Image.FORMAT_RGBA8)
		image.save_png(frame_name)
		if index % 10 == 9:
			print("progression %d" % (float(index) / float(frames.size()) * 100 ))
	
	var user_dir = ProjectSettings.globalize_path(frames_dir_path)
	print("saved %d frames to %s" % [frames.size(), user_dir])
	
	var date_time_dict = Time.get_datetime_dict_from_system()
	var file_name = "recording_%s-%s-%s_%s-%s.gif" % [date_time_dict["year"], date_time_dict["month"], date_time_dict["day"], date_time_dict["hour"], date_time_dict["minute"]]
	
	var output_path = "%s/%s" % [ProjectSettings.globalize_path(temp_dir), file_name]
	
	var request_scale = scale_options.get_item_text(scale_options.selected)
	request_scale = float(request_scale)
	
	var exit_code = 500
	var exec_output = []
	if export_mode == ExportMode.FFMPEG:
		print("exporting with FFMPEG")
		var frames_name = "%s/frame%%04d.png" % user_dir
		var palette_name = "%s/palette.png" % user_dir
	
		print("generating palette %s" % palette_name)
		exec_output = []
		exit_code = OS.execute("ffmpeg", [
			"-f","image2",
			"-i", frames_name, 
			"-vf", "palettegen",
			palette_name], 
			exec_output, true)
		print("palette exited with code %d" % exit_code)
		
		if exit_code != 0:
			print("ffmpeg output:")
			for line in exec_output:
				print(line)
			return
		
		print("converting to gif")
		var fps_value = "fps=30"
		if is_60fps : fps_value = "fps=60"
		
		var output_size = "%dx%d" % [record_area.size.x * request_scale, record_area.size.y * request_scale]
		
		var exec_parameters = [
			"-f",  "image2", 
			"-i", frames_name, 
			"-i", palette_name,
			"-lavfi", "\"paletteuse,%s\"" % [fps_value],
			"-s", output_size,
			output_path
		]	
		
		print("executing")
		print("ffmpeg %s" % " ".join(exec_parameters))
		
		if FileAccess.file_exists(output_path):
			DirAccess.remove_absolute(output_path)
			
		exec_output = []
		exit_code = OS.execute("ffmpeg", exec_parameters, 
			exec_output, true)
		print("exited with code %d" % exit_code)
	elif export_mode == ExportMode.GIFSKI:
		print("exporting with gifski")
		
		var fps_value = "30"
		if is_60fps : fps_value = "60"
		var width = "%d" % round(record_area.size.x * request_scale)
		var height = "%d" %  round(record_area.size.y * request_scale)
		var input_name = "\"%s/*\"" % ProjectSettings.globalize_path(frames_dir_path)
		
		var exec_parameters = [
			"--fps", fps_value,
			"--width", width,
			"--height", height,
			"--motion-quality=100",
			"-o", output_path,
			input_name
		]
		
		exec_output = []
		
		print("executing")
		print("gifski %s" % " ".join(exec_parameters))
		
		exit_code = OS.execute("gifski", exec_parameters, 
			exec_output, true)
		print("exited with code %d" % exit_code)
		
	if exit_code != 0:
		print("output:")
		for line in exec_output:
			print(line)
	else:
		print("gif export finished : %s" % output_path)
	
	frames.clear()

func remove_recursive_directory(directory: String) -> void:
	for dir_name in DirAccess.get_directories_at(directory):
		remove_recursive_directory(directory.path_join(dir_name))
	for file_name in DirAccess.get_files_at(directory):
		DirAccess.remove_absolute(directory.path_join(file_name))
	
	DirAccess.remove_absolute(directory)

@export_tool_button("Open export folder", "Callable") var open_folder_button = open_gif_folder
func open_gif_folder() -> void:
	var temp_dir = "res://.temp"
	var path = ProjectSettings.globalize_path(temp_dir)
	print(path)
	OS.shell_open(path)
