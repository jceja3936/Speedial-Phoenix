extends CharacterBody2D

@export var player : CharacterBody2D
@export var shootSFX :  AudioStreamPlayer2D
@export var bullet : PackedScene = load("res://scenes/bullet.tscn")
@export var gun : Node2D
var canFire = true
var rng = RandomNumberGenerator.new()
var seen = false

func _ready() -> void:
	_fireRateControll()

func _process(delta: float) -> void:
	var wherePlayer = player.global_position - global_position
	
	if wherePlayer.length() < 1200:
		$ray.target_position = $ray.to_local(player.global_position)
		$ray.force_raycast_update()
		if $ray.is_colliding():
			var hit = $ray.get_collider()
			if hit == player:
				look_at(player.global_position)
				await attackPlayer()
				seen = true
			if hit != player:
				seen = false
				
#await get_tree().create_timer(1).timeout
func attackPlayer() -> bool:
	if !seen:
		await get_tree().create_timer(.5).timeout
	fire()
	return true;
	
	

func fire() -> void:
	if canFire:
		shootSFX.play()
		canFire = false
		var bullet = bullet.instantiate()
		bullet.dir = rotation + rng.randf_range(-.08, .08)
		bullet.pos = gun.global_position
		bullet.rota = global_rotation
		add_child(bullet)
		await get_tree().create_timer(1).timeout
		if bullet:
			bullet.queue_free()

func _fireRateControll() -> void:
	canFire = true
	await get_tree().create_timer(.2).timeout
	_fireRateControll()
