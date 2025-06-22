extends CharacterBody2D

@export var player: CharacterBody2D
@export var gun: Node2D
@export var ray: RayCast2D
@export var type: int
@export var nav_Agent: NavigationAgent2D
@export var gunSkin: Sprite2D
var currentSprite: Texture

var bullet: PackedScene = load("res://scenes/bullet.tscn")
var deathTexture: Texture = load("res://assets/icon.svg")

var canFire = true
var rng = RandomNumberGenerator.new()
var seen = false
var enemy = true
var lastKnown
var health = 200
var dead = false
var dammage = 100
var speed = 800
var fireRate = .2
var ammo = 20

func _ready() -> void:
	speed = 800 + rng.randf_range(-50, 100)

	if type == 0:
		type = rng.randi_range(1, 3)

	match type:
		1:
			currentSprite = load("res://assets/basicSquare.svg")
			dammage = 100
			gunSkin.rotation = 0
			gunSkin.scale.x = .9
			gunSkin.scale.y = .25
			fireRate = .2
			ammo = 17
		2:
			currentSprite = load("res://assets/Guitar-b.svg")
			dammage = 100
			gunSkin.scale.x = 0.612
			gunSkin.scale.y = 0.622
			gunSkin.rotation_degrees = 72.9
			fireRate = .1
			ammo = 30
		3:
			currentSprite = load("res://assets/Frog 2-c.svg")
			dammage = 100
			gunSkin.rotation_degrees = 17.0
			gunSkin.scale.x = 0.612
			gunSkin.scale.y = 0.289
			fireRate = .8
			ammo = 6
		_:
			currentSprite = load("res://assets/basicSquare.svg")
			dammage = 100
			fireRate = .2
			ammo = 17
	gunSkin.texture = currentSprite
		
	
func die() -> void:
	$Sprite2D.texture = deathTexture
	gunSkin.texture = null
	$Sprite2D.scale.x = 1
	$Sprite2D.scale.y = 1
	$CollisionShape2D.queue_free()
	dead = true;
	Manager.dropWeapon(type, self, ammo)
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
	if canFire:
		fire()
		ammo -= 1
		
	return true;
	

func fire() -> void:
	dammage = -1
	if type == 3:
		for i in range(6):
			canFire = false
			var bull = bullet.instantiate()
			bull.set("fromWho", "enemy")
			if i < 3:
				bull.dir = rotation + rng.randf_range(-.15, .15)
			else:
				bull.dir = rotation + rng.randf_range(-.25, .25)
			bull.pos = gunSkin.global_position
			bull.rota = global_rotation
			bull.damage = dammage
			get_tree().root.add_child(bull)
			wait()
		Manager.playSound("sSound", global_position)
	else:
		wait()
		canFire = false
		Manager.playSound("pSound", global_position)
		var bull = bullet.instantiate()
		bull.set("fromWho", "enemy")
		bull.dir = rotation + rng.randf_range(-.1, .1)
		bull.pos = gunSkin.global_position
		bull.rota = global_rotation
		bull.damage = dammage
		get_tree().root.add_child(bull)

func wait() -> bool:
	await get_tree().create_timer(fireRate).timeout
	canFire = true
	return true
