extends Node

export var health_0: Texture
export var health_1: Texture
export var health_2: Texture
export var health_3: Texture

onready var counter_health: TextureRect = $MarginContainer/VBoxContainer/TextureRect
onready var counter_floor: Label = $MarginContainer/VBoxContainer/Label2
onready var counter_time: Label = $MarginContainer/VBoxContainer/Label4
onready var counter_timer: Label = $MarginContainer/VBoxContainer/Label8

var played_time: int = 0
var time_start
var previous_time: int = 0

func _ready() -> void:
	_reset_start()

func set_counter_health(health: int) -> void:
	var new_health: Texture = health_0
	if health >= 3:
		new_health = health_3
	elif health == 2:
		new_health = health_1
	elif health == 1:
		new_health = health_2
	counter_health.texture = new_health
	print(health)

func set_counter_floor(flr: int) -> void:
	counter_floor.text = str(flr)

func set_counter_time() -> void:
	_calculate_play_time()
	counter_time.text = _get_time()

func set_counter_timer(cnt: int) -> void:
	counter_timer.text = str(cnt)

func _reset_start() -> void:
	time_start = Time.get_ticks_msec()
 
func _calculate_play_time() -> void:
	played_time = (Time.get_ticks_msec() - time_start) + previous_time;

func _time_converted() -> Array:
	var ms = played_time % 1000
	var s = played_time / 1000 % 60
	var m = (played_time / 1000 / 60) % 60
	return [m, s, ms]

func _get_time() -> String:
	var time = _time_converted()
	return "%02d:%02d:%02d" % [time[0], time[1], time[2]]
