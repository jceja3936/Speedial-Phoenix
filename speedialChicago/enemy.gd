extends CharacterBody2D
@export var gun: Node2D
@export var ray: RayCast2D
@export var type: int
@export var nav_Agent: NavigationAgent2D
@export var gunSkin: Sprite2D
@export var pat: bool
@export var distance: int
var currentSprite: Texture

var bullet: PackedScene = preload("res://scenes/bullet.tscn")
var deathTexture: Texture = load("res://assets/icon.svg")

var canFire = true
var rng = RandomNumberGenerator.new()
var enemy = true
var lastKnown
var health = 200
var dead = false
var dammage = 100
var ogSpeed = 750
var speed = 750
var walkSpeed = 375
var fireRate = .2
var ammo = 20
var wallCollision = false

var rotating = false
var from = 0
var to = 0

var player: CharacterBody2D

func _ready() -> void:
	speed = 800 + rng.randf_range(-100, 100)
	ogSpeed = speed

	var playerNode = ""
	match Manager.current_scene:
		"1_1":
			playerNode = "/root/Lvl1/Player"
		"1_2":
			playerNode = "/root/1_2/Player"

	player = get_node(playerNode)

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
	Manager.decrementEnemyAmount()
	dead = true
	$Sprite2D.texture = deathTexture
	$Sprite2D.scale = Vector2(1, 1)
	$gun/gunSkin.texture = null
	$CollisionShape2D.queue_free()
	Manager.dropWeapon(type, self, ammo)
	set_script(null)

func hit(damage: int) -> void:
	health -= damage
	if health <= 0 and !dead:
		dead = true
		die()

func _process(_delta: float) -> void:
	var player_pos = player.global_position

	if pat:
		patrol()

	if wallCollision and pat and lastKnown == null:
		from = global_rotation
		to -= deg_to_rad(90)
		wallCollision = false
		rotating = true
	
	if rotating:
		rotation = lerp_angle(rotation, to, .1)
		if abs(angle_difference(global_rotation, to)) < .08:
			rotating = false
			rotation = to
			to = global_rotation

	#If the raycast hit anything,
	if global_position.distance_to(player_pos) < distance or lastKnown != null:
		takeAlook(player_pos)

func takeAlook(playPos: Vector2):
	ray.target_position = ray.to_local(playPos)
	ray.force_raycast_update()
	ray.target_position = ray.to_local(playPos)
	ray.force_raycast_update()
	if ray.is_colliding():
		#See if the thing it hit is the player
		var collider = ray.get_collider()
		if collider == player:
			rotating = false
			pat = true
			look_at(playPos)
			attackPlayer()
			lastKnown = playPos
		if collider != player and lastKnown != null:
			speed = ogSpeed - walkSpeed
			search(lastKnown)
	
func patrol():
	var player_pos = player.global_position
	velocity = walkSpeed * Vector2(1, 0).rotated(rotation)
	if global_position.distance_to(player_pos) < 400 and lastKnown != null:
		walkSpeed = 0
	else:
		walkSpeed = 375

	move_and_slide()

func search(destination):
	nav_Agent.target_position = destination

	var current_Pos = global_position
	var next_path_pos = nav_Agent.get_next_path_position()
	var new_velocity = current_Pos.direction_to(next_path_pos)
	var lookingAt = rotation + get_angle_to(next_path_pos)
	rotation = lerp_angle(rotation, lookingAt, .1)
	if nav_Agent.is_navigation_finished():
		pat = true
		lastKnown = null
		walkSpeed = 375
		return

	if nav_Agent.avoidance_enabled:
		nav_Agent.set_velocity(new_velocity)
	velocity = new_velocity * speed
	move_and_slide()

	
func attackPlayer() -> bool:
	await get_tree().create_timer(.4).timeout
	var collider = ray.get_collider()
	if collider == player and canFire and ammo > 0:
		fire()
		ammo -= 1
		
	return true;
	
func fire() -> void:
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

func _on_area_2d_body_entered(_body: Node2D) -> void:
	wallCollision = true
