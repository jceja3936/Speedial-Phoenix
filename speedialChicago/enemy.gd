extends CharacterBody2D

@export var player: CharacterBody2D
@export var shootSFX: AudioStreamPlayer2D
@export var gun: Node2D
@export var ray: RayCast2D

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

var path: Array = []
var current_path_index := 0
var pathing = false

func start_pathfinding():
	var start_node = WalkWay.findClosestToMe(global_position)
	var end_node = WalkWay.findClosestToMe(lastKnown)

	path = find_path_to(start_node, end_node, 0, [], [])
	current_path_index = 0

func find_path_to(start_node, end_node, i, haveBeen, currentPath):
	if i == 5:
		return
	var myPath = currentPath
	var current = start_node
	var visited = haveBeen

	if current != end_node and current != null:
		myPath.append(current)
		visited.append(current)
		current = current.findNext(end_node.global_position, visited)
		find_path_to(current, end_node, i + 1, visited, myPath)

	if current == end_node:
		myPath.append(current)

	return myPath

func _ready() -> void:
	_fireRateControll()
	
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
	if Input.is_action_just_pressed("Debug") and pathing:
		print(path)


	if dead:
		return
	
	var wherePlayer = player.global_position - global_position
	
	if wherePlayer.length() < 1600:
		#Raycays to their position
		ray.target_position = ray.to_local(player.global_position)
		ray.force_raycast_update()
		#If the raycast hit anything,
		if ray.is_colliding():
			var collider = ray.get_collider()
			if collider == player:
				look_at(player.global_position)
				await attackPlayer()
				seen = true
				lastKnown = player.global_position
				pathing = false
				path.clear()
			else:
				seen = false
		else:
			seen = false

	if not seen and lastKnown != null and !pathing:
			start_pathfinding()
			pathing = true
	
	if pathing and path.size() > 0:
		move_along_path()
	
func move_along_path():
	if current_path_index >= path.size():
		pathing = false
		velocity = Vector2.ZERO
		return

	var target_node = path[current_path_index]
	var dir = (target_node.global_position - global_position).normalized()
	velocity = dir * 800
	move_and_slide()

	if global_position.distance_to(target_node.global_position) < 20:
		current_path_index += 1

#await get_tree().create_timer(1).timeout
#This is really cool actually
func attackPlayer() -> bool:
	#Basically, this is called any time the raycast is actively hitting the player
	#however, to emulate the enemy having a "reaction time" on first call seen is not yet true, and therefore
	#wait a beat before firing. After this first call of attackPlayer, the seen is true and therefore fire at first chance.
	#Once the raycast is lost, seen is back to false, releasing the latch.
	if !seen:
		await get_tree().create_timer(.5).timeout
	fire()
	return true;
	

func fire() -> void:
	if canFire:
		shootSFX.play()
		canFire = false
		var bull = bullet.instantiate()
		bull.set("fromWho", "enemy")
		bull.dir = rotation + rng.randf_range(-.08, .08)
		bull.pos = gun.global_position
		bull.damage = 1
		bull.rota = global_rotation
		add_child(bull)
		await get_tree().create_timer(1).timeout
		if bull:
			bull.queue_free()

func _fireRateControll() -> void:
	if dead:
		return
	canFire = true
	await get_tree().create_timer(.2).timeout
	_fireRateControll()
