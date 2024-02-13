class_name Platform
extends KinematicBody2D

onready var ray_left: RayCast2D = $RayCast2D
onready var ray_right: RayCast2D = $RayCast2D2

var move_speed: int = 0
var left: bool = true

var velocity: Vector2 = Vector2.ZERO

func _physics_process(delta):
	if ray_left.is_colliding():
		left = false
	if ray_right.is_colliding():
		left = true
	if left:
		velocity.x = lerp(velocity.x, velocity.x - move_speed, 3 * delta)
	else:
		velocity.x = lerp(velocity.x, velocity.x + move_speed, 3 * delta)
	position = velocity

func randomize_dir(spd: int) -> void:
	move_speed = spd
	if velocity == Vector2.ZERO:
		if randi() % 2:
			left = false
