extends CharacterBody2D

@export var player: CharacterBody2D
@export var shootSFX: AudioStreamPlayer2D
var bullet: PackedScene = load("res://scenes/bullet.tscn")
var deathTexture: Texture = load("res://assets/icon.svg")
@export var gun: Node2D
@export var ray: RayCast2D

var canFire = true
var rng = RandomNumberGenerator.new()
var seen = false
var enemy = true
var lastKnown
var health = 200
var dead = false
var speed = 800

func _ready() -> void:
	_fireRateControll()
	
func die() -> void:
	$Sprite2D.texture = deathTexture
	$Sprite2D.scale.x = 1
	$Sprite2D.scale.y = 1
	$CollisionShape2D.queue_free()
	dead = true;
	
func hit() -> void:
	health -= 100
	if health <= 0:
		die()

func _process(_delta: float) -> void:
	if dead:
		return
	
	var wherePlayer = player.global_position - global_position
	
	if wherePlayer.length() < 1200:
		ray.target_position = ray.to_local(player.global_position)
		ray.force_raycast_update()
		if ray.is_colliding():
			var collider = ray.get_collider()
			if collider == player:
				look_at(player.global_position)
				await attackPlayer()
				seen = true
				lastKnown = player.global_position
			if collider != player:
				seen = false
				if lastKnown != null:
					search()
	
			
#await get_tree().create_timer(1).timeout
func attackPlayer() -> bool:
	if !seen:
		await get_tree().create_timer(.5).timeout
	fire()
	return true;
	
func search() -> bool:
	var direction = (lastKnown - global_position).normalized()
	if global_position.distance_to(lastKnown) > 20:
		velocity = direction * 800
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	return true

func fire() -> void:
	if canFire:
		shootSFX.play()
		canFire = false
		var bullet = bullet.instantiate()
		bullet.set("fromWho", "enemy")
		bullet.dir = rotation + rng.randf_range(-.08, .08)
		bullet.pos = gun.global_position
		bullet.rota = global_rotation
		add_child(bullet)
		await get_tree().create_timer(1).timeout
		if bullet:
			bullet.queue_free()

func _fireRateControll() -> void:
	if dead:
		return
	canFire = true
	await get_tree().create_timer(.2).timeout
	_fireRateControll()
