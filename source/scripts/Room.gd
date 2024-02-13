extends Node2D

export var platform_safe: PackedScene
export var platform_hazard: PackedScene

export var room_light: Texture
export var room_dark: Texture
export var match_dark: Texture
export var match_lit: Texture

export var timer_tick: AudioStreamOGGVorbis
export var timer_darken: AudioStreamOGGVorbis

export var sound_death: AudioStreamOGGVorbis
export var sound_success: AudioStreamOGGVorbis

export var track_0: AudioStreamOGGVorbis
export var track_1: AudioStreamOGGVorbis
export var track_2: AudioStreamOGGVorbis
export var track_3: AudioStreamOGGVorbis
export var track_4: AudioStreamOGGVorbis
export var track_5: AudioStreamOGGVorbis
export var track_6: AudioStreamOGGVorbis

onready var player: KinematicBody2D = $Player
onready var interface: CanvasLayer = $Interface
onready var music: AudioStreamPlayer = $Music
onready var sound: AudioStreamPlayer2D = $Sfx
onready var timer: AudioStreamPlayer = $Timer

onready var background: TextureRect = $Background/TextureRect
onready var matches: Node2D = $Matches
onready var transition: ColorRect = $ColorRect

onready var position_1_a: Position2D = $Platforms/Position1A
onready var position_1_b: Position2D = $Platforms/Position1B
onready var position_2_a: Position2D = $Platforms/Position2A
onready var position_2_b: Position2D = $Platforms/Position2B
onready var position_3_a: Position2D = $Platforms/Position3A
onready var position_3_b: Position2D = $Platforms/Position3B
onready var platform_positions: Node2D = $Platforms

var positions_1: Array = []
var positions_2: Array = []
var positions_3: Array = []

var rng = RandomNumberGenerator.new()

var darken_timer: Timer = Timer.new()
var darken_counter: int = 0
var memorizing_time: int = 0

var current_floor: int = 0

var platforms_can_move: bool = false

func _ready() -> void:
	rng.randomize()
	positions_1.append(position_1_a)
	positions_1.append(position_1_b)
	positions_2.append(position_2_a)
	positions_2.append(position_2_b)
	positions_3.append(position_3_a)
	positions_3.append(position_3_b)
	player.connect("hurt", self, "_on_hurt")
	player.connect("died", self, "_on_died")
	darken_timer.connect("timeout", self, "_on_darken_timeout")
	darken_timer.set_one_shot(true)
	darken_timer.set_wait_time(1)
	add_child(darken_timer)
	_new_room()

func _process(_delta) -> void:
	if player.unfrozen:
		interface.set_counter_time()

func _randomize_platforms() -> void:
	_free_platforms(positions_1)
	_free_platforms(positions_2)
	_free_platforms(positions_3)
	yield(get_tree().create_timer(0.01), "timeout")
	if current_floor >= 2:
		_place_platforms(positions_3)
	else:
		_place_platforms(positions_3, true)
	if current_floor >= 4:
		_place_platforms(positions_2)
	else:
		_place_platforms(positions_2, true)
	if current_floor >= 6:
		_place_platforms(positions_1)
	else:
		_place_platforms(positions_1, true)
	if current_floor >= 1:
		for p in platform_positions.get_children():
			p.get_child(0).randomize_dir(_get_platform_speed())

func _place_platforms(arr: Array, safe: bool = false) -> void:
	if safe:
			arr[0].add_child(platform_safe.instance())
			arr[1].add_child(platform_safe.instance())
	else:
		if randi() % 2:
			arr[0].add_child(platform_hazard.instance())
			arr[1].add_child(platform_safe.instance())
		else:
			arr[0].add_child(platform_safe.instance())
			arr[1].add_child(platform_hazard.instance())

func _free_platforms(arr: Array) -> void:
	for p in arr:
		if p.get_child_count() != 0:
			for c in p.get_children():
				c.queue_free()

func _new_room() -> void:
	transition.show()
	_randomize_platforms()
	interface.set_counter_health(player.health)
	interface.set_counter_floor(current_floor)
	player.position = Vector2(128, 216)
	_play_music()
	_change_memorization_time()
	_darken_room(false)
	darken_counter = 0
	yield(get_tree().create_timer(0.75), "timeout")
	transition.hide()
	if current_floor >= 5:
		player.unfrozen = false
		_play_timer(timer_tick)
		darken_timer.start()
		interface.set_counter_timer(memorizing_time)
		interface.counter_timer.show()
	else:
		player.unfrozen = true
		interface.counter_timer.hide()

func _darken_room(toggle: bool = true):
	var b = Color.black
	var w = Color.white
	if toggle:
		background.texture = room_dark
		player.modulate = b
		platform_positions.modulate = b
		for m in matches.get_children():
			m.texture = match_dark
	else:
		background.texture = room_light
		player.modulate = w
		platform_positions.modulate = w
		for m in matches.get_children():
			m.texture = match_lit

func _on_darken_timeout():
	if abs(darken_counter) >= memorizing_time:
		_play_timer(timer_darken)
		_darken_room()
		interface.counter_timer.hide()
		player.unfrozen = true
	else:
		darken_counter -= 1
		_play_timer(timer_tick)
		interface.set_counter_timer(memorizing_time - abs(darken_counter))
		darken_timer.start()

func _on_Area2D_body_entered(body) -> void:
	if body is Player:
		current_floor += 1
		_play_sound(sound_success)
		_new_room()

func _on_hurt() -> void:
	player.health -= 1
	_new_room()

func _on_died() -> void:
	current_floor = 0
	player.health = 3
	_play_sound(sound_death)
	_new_room()

func _change_memorization_time() -> void:
	if current_floor >= 90:
		memorizing_time = 1
	elif current_floor >= 75:
		memorizing_time = 2
	elif current_floor >= 60:
		memorizing_time = 3
	elif current_floor >= 45:
		memorizing_time = 4
	elif current_floor >= 30:
		memorizing_time = 5
	elif current_floor >= 15:
		memorizing_time = 6
	elif current_floor >= 5:
		memorizing_time = 7

func _get_platform_speed() -> int:
	var speed: int = 0
	if current_floor >= 50:
		speed = 60  
	elif current_floor >= 40:
		speed = 50
	elif current_floor >= 28:
		speed = 40
	elif current_floor >= 16:
		speed = 30
	elif current_floor >= 8:
		speed = 20
	elif current_floor >= 3:
		speed = 10
	return speed

func _play_music() -> void:
	var track: AudioStreamOGGVorbis = track_0
	var time: float = music.get_playback_position()
	if music.playing:
		pass
	if current_floor >= 5 and current_floor < 11:
		track = track_1
	elif current_floor >= 10 and current_floor < 21:
		track = track_2
	elif current_floor >= 25 and current_floor < 41:
		track = track_3
	elif current_floor >= 40 and current_floor < 46:
		track = track_4
	elif current_floor >= 45 and current_floor < 61:
		track = track_5
	elif current_floor >= 60 and current_floor < 71:
		track = track_6
	music.stream = track
	music.play()
	if current_floor != 0:
		music.seek(time)

func _play_sound(snd: AudioStreamOGGVorbis) -> void:
	sound.stream = snd
	sound.play()

func _play_timer(snd: AudioStreamOGGVorbis) -> void:
	timer.stream = snd
	timer.play()
