extends Node

@export var mob_scene: PackedScene
@export var death_animation: PackedScene
@export var power_up_scene: PackedScene

var score
var power_up: Area2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $Player.invincible:
		$HUD.update_invincibility_timer($Player.get_invincibility_time_left())
	else:
		$HUD.hide_invincibility_timer()


func game_over() -> void:
	$ScoreTimer.stop()
	$MobTimer.stop()
	$PowerUpTimer.stop()
	$PowerUpDespawnTimer.stop()
	if is_instance_valid(power_up):
		power_up.queue_free()
	power_up = null
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()
	_spawn_death_animation($Player.global_position)

func _spawn_death_animation(pos: Vector2) -> void:
	var explosion = death_animation.instantiate()
	explosion.global_position = $Player.global_position
	add_child(explosion)
	explosion.emitting = true


func new_game() -> void:
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	get_tree().call_group("mobs", "queue_free")
	if is_instance_valid(power_up):
		power_up.queue_free()
	$Music.play()


func _on_mob_timer_timeout() -> void:
	var mob = mob_scene.instantiate()
	
	var scale_factor = randf_range(0.75, 1.5)
	mob.get_node("AnimatedSprite2D").scale *= scale_factor
	mob.get_node("CollisionShape2D").scale = Vector2.ONE * scale_factor
	
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()
	
	mob.position = mob_spawn_location.position
	
	var direction = mob_spawn_location.rotation + PI / 2
	
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction
	
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0) / scale_factor
	mob.linear_velocity = velocity.rotated(direction)
	
	add_child(mob)


func _on_score_timer_timeout() -> void:
	score += 1
	$HUD.update_score(score)


func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()
	$PowerUpTimer.start()


func _on_power_up_timer_timeout() -> void:
	power_up = power_up_scene.instantiate()
	power_up.collected.connect(_on_power_up_collected)

	var spawn_pos = $PowerUpPath/PowerUpLocation
	spawn_pos.progress_ratio = randf()
	power_up.position = spawn_pos.position
	
	add_child(power_up)
	$PowerUpDespawnTimer.start()


func _on_power_up_collected() -> void:
	$Player.start_invincibility(3.0)
	power_up = null
	$PowerUpDespawnTimer.stop()
	$PowerUpTimer.start()
	


func _on_power_up_despawn_timer_timeout() -> void:
	if is_instance_valid(power_up):
		power_up.queue_free()
	power_up = null
	$PowerUpTimer.start()


func _on_player_mob_defeated(mob: Node2D) -> void:
	_spawn_death_animation(mob.global_position)
	mob.queue_free()
