extends Area2D

signal hit
signal mob_defeated(mob: Node2D)

@export var speed = 400 # pixels per second
@export var acceleration = 2000 # pixels per second ^ 2

var velocity = Vector2.ZERO
var screen_size
var invincible = false
var tween: Tween


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_down"):
		input_dir.y += 1
	if Input.is_action_pressed("move_up"):
		input_dir.y -= 1
	input_dir = input_dir.normalized()

	var target_velocity = input_dir * speed
	velocity = velocity.move_toward(target_velocity, acceleration * delta)

	$AnimatedSprite2D.play()

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0
	else:
		$AnimatedSprite2D.animation = "walk"


func _on_body_entered(body: Node2D) -> void:
	if invincible:
		mob_defeated.emit(body)
		return
	
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func start_invincibility(duration: float) -> void:
	invincible = true
	$InvincibilityTimer.start(duration)
	tween = create_tween().set_loops()
	tween.tween_property(self, "modulate:a", 0.3, 0.15)
	tween.tween_property(self, "modulate:a", 1.0, 0.15)

func get_invincibility_time_left() -> float:
	return $InvincibilityTimer.time_left

func _on_invincibility_timer_timeout() -> void:
	invincible = false
	tween.kill()
	modulate.a = 1.0
