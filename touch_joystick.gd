extends Control

@export var radius := 40.0

var output := Vector2.ZERO
var _touch_index := -1
var _knob_start_pos: Vector2

@onready var knob: Control = $Knob

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_knob_start_pos = knob.position
	visible = DisplayServer.is_touchscreen_available()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1 and _within_base(event.position):
			_touch_index = event.index
			_update_knob(event.position)
		elif not event.pressed and event.index == _touch_index:
			_touch_index = -1
			_reset_knob()
	elif event is InputEventScreenDrag and event.index == _touch_index:
		_update_knob(event.position)

func _within_base(screen_pos: Vector2) -> bool:
	var center = global_position + size / 2
	return screen_pos.distance_to(center) <= radius * 1.5

func _update_knob(screen_pos: Vector2) -> void:
	var center = global_position + size / 2
	var delta = (screen_pos - center).limit_length(radius)
	knob.position = _knob_start_pos + delta
	output = delta / radius

func _reset_knob() -> void:
	knob.position = _knob_start_pos
	output = Vector2.ZERO


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
