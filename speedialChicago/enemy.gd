extends CharacterBody2D

@export var player: CharacterBody2D
@export var shootSFX: AudioStreamPlayer2D
@export var gun: Node2D
@export var ray: RayCast2D
@export var type: int
@export var nav_Agent: NavigationAgent2D

var bullet: PackedScene = load("res://scenes/bullet.tscn")
var deathTexture: Texture = load("res://assets/icon.svg")

var canFire = true
var rng = RandomNumberGenerator.new()
var seen = false
var enemy = true
var lastKnown
var health = 200
var dead = false
var speed = 800
var fireRate = .2

func _ready() -> void:
	speed = 800 + rng.randf_range(-50, 100)
	
func die() -> void:
	$Sprite2D.texture = deathTexture
	$Sprite2D.scale.x = 1
	$Sprite2D.scale.y = 1
	$CollisionShape2D.queue_free()
	dead = true;
	set_script(null)
	
func hit(damage: int) -> void:
	health -= damage
	if health <= 0:
		die()

func _process(_delta: float) -> void:
	if dead:
		return
	
	var wherePlayer = player.global_position - global_position
	var player_pos = player.global_position
	
	#This mess handles the main decision making of the enemy
	#If player is within the sight range
	if wherePlayer.length() < 1600:
		#Raycays to their position
		ray.target_position = ray.to_local(player_pos)
		ray.force_raycast_update()
		#If the raycast hit anything,
		if ray.is_colliding():
			#See if the thing it hit is the player
			var collider = ray.get_collider()
			if collider == player:
				look_at(player_pos)
				attackPlayer()
				lastKnown = player_pos
			#If it wasn', set seen to false.
			if collider != player:
				seen = false
				if lastKnown != null:
					search()

func search():
	var goingTo = lastKnown
	nav_Agent.target_position = goingTo

	var current_Pos = global_position
	var next_path_pos = nav_Agent.get_next_path_position()
	var new_velocity = current_Pos.direction_to(next_path_pos)

	if nav_Agent.is_navigation_finished():
		return

	if nav_Agent.avoidance_enabled:
		nav_Agent.set_velocity(new_velocity)
	velocity = new_velocity * speed
	move_and_slide()

	
func attackPlayer() -> bool:
	if !seen:
		await get_tree().create_timer(.5).timeout
	fire()
	return true;
	

func fire() -> void:
	if canFire:
		shootSFX.play()
		canFire = false
		wait()
		var bull = bullet.instantiate()
		bull.set("fromWho", "enemy")
		bull.dir = rotation + rng.randf_range(-.08, .08)
		bull.pos = gun.global_position
		bull.damage = 20
		bull.rota = global_rotation
		add_child(bull)

func wait() -> bool:
	await get_tree().create_timer(fireRate).timeout
	canFire = true
	return true
