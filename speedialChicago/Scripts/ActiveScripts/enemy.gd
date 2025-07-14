extends CharacterBody2D
@export var type: int
@export var nav_Agent: NavigationAgent2D
@export var gunSkin: Sprite2D
@export var pat: bool
@export var myFloor: int
var currentSprite: Texture

var bullet: PackedScene = preload("res://scenes/bullet.tscn")
var deathTexture: Texture = preload("res://assets/img/icon.svg")
var curve: Curve = load("res://assets/prac.tres")

var canFire = true
var rng = RandomNumberGenerator.new()
var enemy = true
var lastKnown
var health = 200
var dead = false
var dammage = 100
var ogSpeed = 500
var speed = 500
var walkSpeed = 250
var fireRate = .2
var ammo = 20
var wallCollision = false
var secDeg = 90
var degToRotby = -90.0

var rotating = false
var to = 0
var setOfRays: Array
var x = 0.0

var imHit = false
var falling = false
var toRotby = 0

var player: CharacterBody2D

var gamePaused = false

func _ready() -> void:
	SignalBus.paused.connect(paused)
	SignalBus.unPaused.connect(unPaused)

	setOfRays.append($ray1)
	setOfRays.append($ray2)
	setOfRays.append($ray4)

	speed = ogSpeed + rng.randf_range(-100, 100)
	ogSpeed = speed

	var playerNode = ""
	match Manager.current_scene:
		"1_1":
			playerNode = "/root/Lvl1/Player"


	player = get_node(playerNode)

	if type == 0:
		type = rng.randi_range(1, 3)

	match type:
		1:
			currentSprite = load("res://assets/img/basicSquare.svg")
			dammage = 100
			gunSkin.rotation = 0
			gunSkin.scale.x = .9
			gunSkin.scale.y = .25
			fireRate = .2
			ammo = 17
		2:
			currentSprite = load("res://assets/img/Guitar-b.svg")
			dammage = 100
			gunSkin.scale.x = 0.612
			gunSkin.scale.y = 0.622
			gunSkin.rotation_degrees = 72.9
			fireRate = .1
			ammo = 30
		3:
			currentSprite = load("res://assets/img/Frog 2-c.svg")
			dammage = 100
			gunSkin.rotation_degrees = 17.0
			gunSkin.scale.x = 0.612
			gunSkin.scale.y = 0.289
			fireRate = .8
			ammo = 6
		_:
			currentSprite = load("res://assets/img/basicSquare.svg")
			dammage = 100
			fireRate = .2
			ammo = 17
	gunSkin.texture = currentSprite

	if Manager.levelState > myFloor:
		die()
		
func paused():
	gamePaused = true
func unPaused():
	gamePaused = false

func punched(gunType: int, rot: float):
	toRotby = rot
	var ogFirerate = fireRate
	fireRate = 2
	falling = true

	if !imHit:
		Manager.playSound("punched", global_position)
		if gunType == 4:
			hit(300)
		imHit = true
		await wait()
		fireRate = ogFirerate
		imHit = false
		
		
func die() -> void:
	Manager.decrementEnemyAmount()
	dead = true
	var deadBody = Sprite2D.new()
	deadBody.texture = deathTexture
	deadBody.global_position = position
	deadBody.rotation = rotation
	get_parent().add_child.call_deferred(deadBody)
	Manager.dropWeapon(type, self, ammo)
	queue_free()
	
func finish() -> void:
	SignalBus.finishing.emit(global_position, self)

func hit(damage: int) -> void:
	health -= damage
	if health <= 0 and !dead:
		SignalBus.emit_signal("updateScore", 200)
		dead = true
		die()


func _physics_process(_delta: float) -> void:
	if gamePaused:
		return

	if falling:
		x = lerp(x, 1.0, .08)
		rotation = deg_to_rad(rad_to_deg(toRotby) + 180)
		velocity = Vector2(curve.sample(x) * 1000, 0).rotated(toRotby)
		move_and_slide()

	if imHit:
		return

	var player_pos = player.global_position

	if pat:
		patrol()

	if wallCollision and pat and lastKnown == null:
		to -= deg_to_rad(90)
		wallCollision = false
		rotating = true
	
	if rotating:
		rotation = lerp_angle(rotation, to, 1.0 - exp(-20 * _delta))
		if abs(angle_difference(rotation, to)) < .08:
			rotating = false
			rotation = to
			to = rotation
	
	degToRotby = degToRotby + 4
	secDeg = secDeg + 4
	if degToRotby == 90:
		degToRotby = -90.0
		secDeg = 90
	takeAlook(player_pos)

func takeAlook(playPos: Vector2):
	setOfRays[0].target_position = Vector2(800, 0)
	setOfRays[1].target_position = Vector2(800, 0).rotated(deg_to_rad(- degToRotby))
	setOfRays[2].target_position = Vector2(500, 0).rotated(deg_to_rad(secDeg))
	
	for i in range(3):
		if setOfRays[i]:
			#See if the thing hit player
			var collider = setOfRays[i].get_collider()
			if collider == player:
				rotating = false
				pat = true
				look_at(playPos)
				attackPlayer()
				lastKnown = playPos
				break
			if collider != player and lastKnown != null:
				speed = ogSpeed - walkSpeed
				search(lastKnown)
				break

	
func patrol():
	var player_pos = player.global_position
	velocity = walkSpeed * Vector2(1, 0).rotated(rotation)
	if global_position.distance_to(player_pos) < 400 and lastKnown != null:
		walkSpeed = 0
	else:
		walkSpeed = 250

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
		walkSpeed = 250
		return

	if nav_Agent.avoidance_enabled:
		nav_Agent.set_velocity(new_velocity)
	velocity = new_velocity * speed
	move_and_slide()

	
func attackPlayer() -> bool:
	await get_tree().create_timer(.4).timeout
	var collider = setOfRays[0].get_collider()
	if collider == player and canFire and ammo > 0 and !imHit:
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
			bull.damage = dammage
			bull.rota = rotation
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
		bull.rota = rotation
		bull.damage = dammage
		get_tree().root.add_child(bull)

func wait() -> bool:
	await get_tree().create_timer(fireRate).timeout
	canFire = true
	falling = false
	x = 0.0
	return true

func _on_area_2d_body_entered(_body: Node2D) -> void:
	wallCollision = true
