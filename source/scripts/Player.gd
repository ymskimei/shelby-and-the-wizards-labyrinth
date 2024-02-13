class_name Player
extends KinematicBody2D

onready var sprite: Sprite = $Sprite
onready var raycasts: Node2D = $Node2D
onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

export var snail_idle: Texture
export var snail_move: Texture
export var snail_jump: Texture
export var snail_death: Texture

export var sound_jump: AudioStreamOGGVorbis
export var sound_hurt: AudioStreamOGGVorbis

var speed: float = 180
var jump: float = 380
var gravity: float = 1280
var velocity: Vector2 = Vector2.ZERO

var health: int = 3

var jump_timer = Timer.new()
var can_jump: bool = false

var unfrozen: bool = false

signal hurt
signal died

func _ready() -> void:
	jump_timer.connect("timeout", self, "_on_jump_timeout")
	jump_timer.set_one_shot(true)
	jump_timer.set_wait_time(0.02)
	add_child(jump_timer)

func _physics_process(delta: float) -> void:
	if health != 0:
		if unfrozen:
			var input: float = (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
			var lerp_speed: int = 1
			for r in raycasts.get_children():
				if r.is_colliding():
					if r.get_collider() is PlatformHazard and is_on_floor() and input != 0:
						if health > 1:
							_play_sound(sound_hurt)
							emit_signal("hurt")
						else:
							emit_signal("died")
			if can_jump:
				if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("move_up"):
					_play_sound(sound_jump)
					velocity.y = -jump
				lerp_speed = 16
			else:
				lerp_speed = 6
			velocity.x = lerp(velocity.x, input * speed, lerp_speed * delta)
			velocity.y += gravity * delta
			velocity = move_and_slide(velocity, Vector2.UP)

			if !is_on_floor():
				sprite.texture = snail_jump
				jump_timer.start()
			else:
				can_jump = true
				if input != 0:
					sprite.texture = snail_move
					sprite.texture.fps = abs(velocity.x * 3 * delta)
				else:
					sprite.texture = snail_idle

			if input != 0:
				if velocity.x > 0:
					sprite.flip_h = true
				else:
					sprite.flip_h = false
		else:
			sprite.texture = snail_idle 
	else:
		sprite.texture = snail_death

func _on_jump_timeout() -> void:
	can_jump = false

func _play_sound(snd: AudioStreamOGGVorbis) -> void:
	sound.stream = snd
	sound.play()
