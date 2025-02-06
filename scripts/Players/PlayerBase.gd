extends CharacterBody2D

@onready var player_1: CharacterBody2D = $"Player Skeletton/Player1"
@onready var mult_player: CharacterBody2D = $"Player Skeletton/MultPlayer"

# Shared constants
const SPEED = 130.0
const JUMP_VELOCITY = -300.0
var INVERT_VELOCITY = 300
var GRA = Vector2(0, 980)

# Shared variables
var moving: float
var direction: int
var is_shrunk: bool = false

# Shared nodes
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	handle_jumping()
	handle_movement()
	handle_animation()
	move_and_slide()
	
	var current_scene = get_tree().current_scene
	
	if current_scene != "multiplayer_level":
		handle_switching()
		player_1.visible = true
		mult_player.visible = false

func handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += GRA * delta

func handle_jumping() -> void:
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() and not animated_sprite_2d.flip_v:
			velocity.y = JUMP_VELOCITY
		elif is_on_ceiling() and animated_sprite_2d.flip_v:
			velocity.y = JUMP_VELOCITY * -1

func handle_switching() -> void:
	if Input.is_action_just_pressed("invert_gravity") and (is_on_ceiling() or is_on_floor()):
		INVERT_VELOCITY *= -1
		velocity.y = INVERT_VELOCITY
		GRA.y *= -1
		animated_sprite_2d.flip_v = not animated_sprite_2d.flip_v

func handle_movement() -> void:
	direction = 1
	velocity.x = direction * SPEED if direction else move_toward(velocity.x, 0, SPEED)

func handle_animation() -> void:
	if is_on_floor() or is_on_ceiling():
		if direction == 0:
			animated_sprite_2d.play("idle")
		else:
			animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("jump")
	animated_sprite_2d.flip_h = direction < 0

func shrink() -> void:
	if Input.is_action_just_pressed("shrink"):
		if not is_shrunk:
			scale /= 1.5
			collision_shape_2d.scale /= 1.5
			is_shrunk = true
		else:
			scale *= 1.5
			collision_shape_2d.scale *= 1.5
			is_shrunk = false
