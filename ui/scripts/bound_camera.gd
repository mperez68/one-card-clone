class_name BoundCamera extends Camera2D

const DIRECTIONS: Array[Vector2] = [ Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT ]

@export var locked: bool = true
@export var focus_target: Node2D
@export var scroll_speed: float = 400.0
@export var edge_scroll_hovered: Color = Color.WHITE
@export var edge_scroll_hidden: Color = Color.TRANSPARENT

@onready var direction_boxes: Array[TextureRect] = [
	%TopScrollRect, %RightScrollRect, %BotScrollRect, %LeftScrollRect
]

var scroll_vector: Vector2 = Vector2.ZERO
var key_vector: Vector2 = Vector2.ZERO


# ENGINE
func _ready() -> void:
	for dir in direction_boxes:
		dir.modulate = edge_scroll_hidden

func _physics_process(delta: float) -> void:
	if focus_target:
		position = focus_target.position
		return
	position += (scroll_vector if scroll_vector else key_vector) * scroll_speed * delta
	var view_size := get_viewport_rect().size
	position.x = clamp(position.x, limit_left + view_size.x / 2, limit_right - view_size.x / 2)
	position.y = clamp(position.y, limit_top + view_size.y / 2, limit_bottom - view_size.y / 2)

func _input(event: InputEvent) -> void:
	if event.is_action("scroll_up") or event.is_action("scroll_right") or event.is_action("scroll_down") or event.is_action("scroll_left"):
		key_vector = Vector2.ZERO if locked else Input.get_vector("scroll_left", "scroll_right", "scroll_up", "scroll_down")

# PUBLIC
func set_limits(boundaries: Rect2):
	var view_size := get_viewport_rect().size
	limit_left = int(boundaries.position.x - (view_size.x / 2))
	limit_top = int(boundaries.position.y - (view_size.y / 2))
	limit_right = int(boundaries.size.x + (view_size.x / 2))
	limit_bottom = int(boundaries.size.y + (view_size.y / 2))


# PRIVATE


# SIGNALS


func _on_start_timer_timeout() -> void:
	locked = focus_target != null

func _on_scroll_rect_mouse_event(entered: bool, direction_index: int) -> void:
	if locked or focus_target:
		return
	scroll_vector += DIRECTIONS[direction_index] * (1 if entered else -1)
	direction_boxes[direction_index].modulate = edge_scroll_hovered if entered else edge_scroll_hidden
