extends Sprite2D

@export var hitBox: ShapeCast2D
@export var animation: AnimatedSprite2D

var currentSprite: Texture
var bullet: PackedScene = load("res://scenes/bullet.tscn")
var rng = RandomNumberGenerator.new()

var pistol: PackedScene = load("res://scenes/gunScenes/pistol.tscn")
var rifle: PackedScene = load("res://scenes/gunScenes/rifle.tscn")
var shotgun: PackedScene = load("res://scenes/gunScenes/shotgun.tscn")
var hammer: PackedScene = load("res://scenes/gunScenes/hammer.tscn")

var pistolImg: Texture = load("res://assets/img/weapons/pistolTop.png")
var rifleImg: Texture = load("res://assets/img/weapons/rifleTop.png")
var shotgunImg: Texture = load("res://assets/img/weapons/shotgunTop.png")
var hammerImg: Texture = load("res://assets/img/weapons/hammerTop.png")

var punchTexture: Texture = preload("res://assets/img/punch.svg")

var gunPickedUp = false

const BADTILES = [Vector2i(5, 3), Vector2i(-1, -1), Vector2i(5, 2), Vector2i(5, 0), Vector2i(6, 0),
Vector2i(7, 0), Vector2i(6, 1), Vector2i(7, 1), Vector2i(6, 2), Vector2i(7, 2),
Vector2i(6, 3), Vector2i(7, 3)]

var canFire = true
var ammo = 0;
var gunType = 0
var dammage = 100
var fireRate = .4
var punching = false
var currentMap: TileMapLayer
var gameStopped = false
var droppable = true
var wallsBroke = 0

var invRot = -36.0
var swung = false
var hammPos = Vector2(0.0, -20.0)

func _ready() -> void:
	var cmNode = ""
	SignalBus.saveWB.connect(saveWB)
	

	match Manager.current_scene:
		"0":
			cmNode = "/root/tutorial/floor"
		"1_1":
			cmNode = "/root/Lvl1/floor1"
		"2":
			cmNode = "/root/Lvl2/Floor"
		"3":
			cmNode = "/root/Lvl3/Floor"

	currentMap = get_node(cmNode)

func saveWB():
	Manager.wallsBroke = wallsBroke

#Functions that Shoot the gun
func _process(_delta: float) -> void:
	if gameStopped or get_parent().get("dead") == true:
		return

	if Input.is_action_pressed("shoot") and canFire:
		match gunType:
			0:
				punching = true
				if swung:
					invRot = 36.0
					swung = false
				else:
					invRot = -36.0
					swung = true
				punching = true
				Manager.playSound("swing", global_position)
				wait(1)
				canFire = false
				texture = punchTexture
			4:
				breach()
				Manager.playSound("swing", global_position)
				if swung:
					invRot = 80.0
					hammPos = Vector2(13.0, 69.0)
					swung = false
				else:
					invRot = -36.0
					swung = true
					hammPos = Vector2(19.0, -63.0)

				punching = true
				
			_:
				fire()
				SignalBus.updateAmmo.emit(ammo)
		
	if gunPickedUp and Input.is_action_pressed("Pick up") and droppable:
		gunPickedUp = false
		dropWeapon(gunType)
		update_values(0, -1)

	if Input.is_action_just_pressed("Respawn"):
		for i in range(hitBox.get_collision_count()):
			var collider = hitBox.get_collider(i)
			if hitBox.is_colliding():
				if collider != null:
					if collider.get("enemy") == true:
						collider.call("finish")

	if punching:
		if gunType == 4:
			rotation_degrees = lerp(rad_to_deg(rotation), invRot, .2)
			position.y = lerp(position.y, hammPos.y, .1)
		melee()

func _on_hammer_blow_animation_finished() -> void:
	animation.hide()

func breach():
	wait(1)
	canFire = false
	animation.show()
	if !animation.is_playing():
		animation.play()

	var wallBroke = false
	var tileCoords = currentMap.local_to_map(get_parent().global_position)
	var ogTileCoords = tileCoords
	
	var direction = (get_global_mouse_position() - get_global_position()).normalized()
	for i in range(hitBox.get_collision_count()):
		var collider = hitBox.get_collider(i)
		if hitBox.is_colliding():
			if collider is RigidBody2D:
				collider.queue_free()
				wallBroke = true
	var atlasCords = currentMap.get_cell_atlas_coords(tileCoords)

	if !BADTILES.has(atlasCords):
		findProperTile(tileCoords, atlasCords)
		wallBroke = true
		wallsBroke += 1

	var dir = Vector2i(round(direction.x), round(direction.y))
	tileCoords += dir
	atlasCords = currentMap.get_cell_atlas_coords(tileCoords)


	if !BADTILES.has(atlasCords):
		wallsBroke += 1
		findProperTile(tileCoords, atlasCords)
		wallBroke = true

	if dir == Vector2i(-1, 0) or dir == Vector2i(1, 0):
		#GETTING EXTRAS: UP
		tileCoords = ogTileCoords
		tileCoords += Vector2i(0, -1)
		atlasCords = currentMap.get_cell_atlas_coords(tileCoords)

		if !BADTILES.has(atlasCords):
			wallsBroke += 1
			findProperTile(tileCoords, atlasCords)
			wallBroke = true
			
		#GETTING EXTRAS: DOWN
		tileCoords = ogTileCoords
		tileCoords += Vector2i(0, 1)
		atlasCords = currentMap.get_cell_atlas_coords(tileCoords)

		if !BADTILES.has(atlasCords):
			wallsBroke += 1
			findProperTile(tileCoords, atlasCords)
			wallBroke = true

		#GETTING EXTRAS: UP
		tileCoords = ogTileCoords + dir
		tileCoords += Vector2i(0, -1)
		atlasCords = currentMap.get_cell_atlas_coords(tileCoords)

		if !BADTILES.has(atlasCords):
			wallsBroke += 1
			findProperTile(tileCoords, atlasCords)
			wallBroke = true
			
		#GETTING EXTRAS: DOWN
		tileCoords = ogTileCoords + dir
		tileCoords += Vector2i(0, 1)
		atlasCords = currentMap.get_cell_atlas_coords(tileCoords)

		if !BADTILES.has(atlasCords):
			wallsBroke += 1
			findProperTile(tileCoords, atlasCords)
			wallBroke = true

		
	if dir == Vector2i(0, -1) or dir == Vector2i(0, 1):
		#GETTING EXTRAS: LEFT
		tileCoords = ogTileCoords
		tileCoords += Vector2i(-1, 0)
		atlasCords = currentMap.get_cell_atlas_coords(tileCoords)
		if !BADTILES.has(atlasCords):
			wallsBroke += 1
			findProperTile(tileCoords, atlasCords)
			wallBroke = true

		#GETTING EXTRAS: RIGHT
		tileCoords = ogTileCoords
		tileCoords += Vector2i(1, 0)
		atlasCords = currentMap.get_cell_atlas_coords(tileCoords)

		if !BADTILES.has(atlasCords):
			wallsBroke += 1
			findProperTile(tileCoords, atlasCords)
			wallBroke = true

		#GETTING EXTRAS: LEFT
		tileCoords = ogTileCoords + dir
		tileCoords += Vector2i(-1, 0)
		atlasCords = currentMap.get_cell_atlas_coords(tileCoords)
		if !BADTILES.has(atlasCords):
			wallsBroke += 1
			findProperTile(tileCoords, atlasCords)
			wallBroke = true

		#GETTING EXTRAS: RIGHT
		tileCoords = ogTileCoords + dir
		tileCoords += Vector2i(1, 0)
		atlasCords = currentMap.get_cell_atlas_coords(tileCoords)

		if !BADTILES.has(atlasCords):
			wallsBroke += 1
			findProperTile(tileCoords, atlasCords)
			wallBroke = true


	if wallBroke:
		Manager.playSound("dSound", get_parent().global_position, 4.5)

func findProperTile(tCord: Vector2i, atCord: Vector2i):
	match atCord:
		#CORNERS
		Vector2i(0, 0):
			currentMap.set_cell(tCord, 0, Vector2i(6, 0), 0)
		Vector2i(2, 0):
			currentMap.set_cell(tCord, 0, Vector2i(7, 0), 0)
		Vector2i(0, 2):
			currentMap.set_cell(tCord, 0, Vector2i(6, 2), 0)
		Vector2i(2, 2):
			currentMap.set_cell(tCord, 0, Vector2i(7, 2), 0)

		#TOPS
		Vector2i(1, 0):
			currentMap.set_cell(tCord, 0, Vector2i(7, 3), 0)
		Vector2i(3, 0):
			currentMap.set_cell(tCord, 0, Vector2i(7, 3), 0)
		Vector2i(4, 0):
			currentMap.set_cell(tCord, 0, Vector2i(7, 3), 0)
		Vector2i(1, 3):
			currentMap.set_cell(tCord, 0, Vector2i(7, 3), 0)

		#LEFTS
		Vector2i(0, 1):
			currentMap.set_cell(tCord, 0, Vector2i(6, 1), 0)
		Vector2i(1, 1):
			currentMap.set_cell(tCord, 0, Vector2i(6, 1), 0)
		Vector2i(3, 2):
			currentMap.set_cell(tCord, 0, Vector2i(6, 1), 0)
		Vector2i(3, 3):
			currentMap.set_cell(tCord, 0, Vector2i(6, 1), 0)
		
		#RIGHTS
		Vector2i(2, 1):
			currentMap.set_cell(tCord, 0, Vector2i(7, 1), 0)
		Vector2i(4, 2):
			currentMap.set_cell(tCord, 0, Vector2i(7, 1), 0)
		Vector2i(2, 3):
			currentMap.set_cell(tCord, 0, Vector2i(7, 1), 0)
		Vector2i(0, 3):
			currentMap.set_cell(tCord, 0, Vector2i(7, 1), 0)


		#BOTTOMS
		Vector2i(3, 1):
			currentMap.set_cell(tCord, 0, Vector2i(6, 3), 0)
		Vector2i(4, 1):
			currentMap.set_cell(tCord, 0, Vector2i(6, 3), 0)
		Vector2i(1, 2):
			currentMap.set_cell(tCord, 0, Vector2i(6, 3), 0)
		Vector2i(4, 3):
			currentMap.set_cell(tCord, 0, Vector2i(6, 3), 0)
		
		
	if atCord == Vector2i(0, 0):
		currentMap.set_cell(tCord, 0, Vector2i(6, 0), 0)

	
func melee():
	for i in range(hitBox.get_collision_count()):
		var collider = hitBox.get_collider(i)
		if hitBox.is_colliding():
			if collider != null:
				if collider.get("enemy") == true:
					collider.call("punched", gunType, get_parent().rotation)

func fire() -> void:
	if ammo > 0:
		ammo -= 1
		if gunType == 3:
			for i in range(6):
				canFire = false
				var bull = bullet.instantiate()
				if i < 3:
					bull.dir = get_parent().rotation + rng.randf_range(-.15, .15)
				else:
					bull.dir = get_parent().rotation + rng.randf_range(-.25, .25)
				bull.pos = global_position
				bull.rota = get_parent().rotation
				bull.damage = dammage
				get_tree().root.add_child(bull)
			Manager.playSound("sSound", global_position, 4.0)
			wait()
		else:
			wait()
			canFire = false
			Manager.playSound("pSound", global_position, -5.0)
			var bull = bullet.instantiate()
			bull.dir = get_parent().rotation + rng.randf_range(-.1, .1)
			bull.pos = global_position
			bull.rota = get_parent().rotation
			bull.damage = dammage
			get_tree().root.add_child(bull)

func wait(_punched: int = 0) -> bool:
	if _punched == 1:
		waitPunch()
	await get_tree().create_timer(fireRate).timeout
	canFire = true
	return true

func waitPunch():
	if gunType == 4:
		await get_tree().create_timer(.3).timeout
	else:
		await get_tree().create_timer(.2).timeout
	punching = false
	if gunType == 0:
			texture = null

func waitDrop():
	await get_tree().create_timer(.2).timeout
	droppable = true


#Functions Called on Weapon pick up
func update_values(value: int, currentAmmo: int):
	get_parent().set("speed", 750)
	droppable = false
	currentSprite = null
	gunType = value
	ammo = currentAmmo
	SignalBus.updateAmmo.emit(ammo)
	offset = Vector2.ZERO
	rotation = 0.0
	scale = Vector2(1, 1)
	position = Vector2(54, 24)
	canFire = true
	gunPickedUp = true
	hitBox.visible = false
	match value:
		1:
			currentSprite = pistolImg
			dammage = 220
			global_scale = Vector2(1.5, 1.5)
			fireRate = .5
			waitDrop()
		2:
			currentSprite = rifleImg
			dammage = 100
			fireRate = .1
			waitDrop()
		3:
			currentSprite = shotgunImg
			dammage = 100
			fireRate = .8
			waitDrop()
		4:
			get_parent().set("speed", 1000)
			global_scale = Vector2(1.5, 1.5)
			swung = false
			currentSprite = hammerImg
			position = Vector2(13.0, 69.0)
			rotation_degrees = 80.0
			dammage = 220
			fireRate = .7
			waitDrop()
		_:
			hitBox.visible = true
			fireRate = .4
			ammo = 0
			gunPickedUp = false

	texture = currentSprite

func saveWeapon():
	Manager.gunType = gunType
	Manager.ammoCount = ammo


func stop():
	gameStopped = true
func unStop():
	gameStopped = false
	
#Functions that handle Dropping a weapon
func instantiate(type: PackedScene):
	var instance = type.instantiate()
	instance.setAmmo(ammo)
	instance.set_meta("placed", "Yer")
	instance.position = global_position
	instance.rotation = get_parent().rotation
	instance.set("dropped", true)
	get_tree().root.add_child(instance)


func dropWeapon(gun: int):
	get_parent().set("gunPickedUp", false)
	match gun:
		1:
			instantiate(pistol)
		2:
			instantiate(rifle)
		3:
			instantiate(shotgun)
		4:
			instantiate(hammer)
