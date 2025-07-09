extends Sprite2D

@export var hitBox: ShapeCast2D

var currentSprite: Texture
var bullet: PackedScene = load("res://scenes/bullet.tscn")
var rng = RandomNumberGenerator.new()

var pistol: PackedScene = load("res://scenes/gunScenes/pistol.tscn")
var rifle: PackedScene = load("res://scenes/gunScenes/rifle.tscn")
var shotgun: PackedScene = load("res://scenes/gunScenes/shotgun.tscn")
var hammer: PackedScene = load("res://scenes/gunScenes/hammer.tscn")

var pistolImg: Texture = load("res://assets/img/basicSquare.svg")
var rifleImg: Texture = load("res://assets/img/Guitar-b.svg")
var shotgunImg: Texture = load("res://assets/img/Frog 2-c.svg")
var hammerImg: Texture = load("res://assets/img/Block-t.svg")

var punchTexture: Texture = preload("res://assets/img/punch.svg")

var gunPickedUp = false

const BADTILES = [Vector2i(5, 3), Vector2i(-1, -1), Vector2i(5, 2), Vector2i(5, 0)]

var canFire = true
var ammo = 0;
var gunType = 0
var dammage = 100
var fireRate = .25
var punching = false
var currentMap: TileMapLayer


func _ready() -> void:
	var cmNode = ""
	match Manager.current_scene:
		"1_1":
			cmNode = "/root/Lvl1/floor1"

	currentMap = get_node(cmNode)

#Functions that Shoot the gun
func _process(_delta: float) -> void:
	if Input.is_action_pressed("shoot") and canFire:
		match gunType:
			0:
				punching = true
				wait(1)
				canFire = false
				texture = punchTexture
				offset = Vector2(-20, 0).rotated(get_angle_to(get_global_mouse_position()))
				Manager.playSound("pSound", global_position)
			4:
				breach()
				punching = true
				SignalBus.updateAmmo.emit(ammo)
				
			_:
				fire()
				SignalBus.updateAmmo.emit(ammo)
		
	if Input.is_action_just_pressed("Drop") and gunPickedUp:
		dropWeapon(gunType)
		update_values(0, -1)

	if punching:
		melee()

func breach():
	if ammo > 0:
		canFire = false
		wait(1)
		var wallBroke = false
		var tileCoords = currentMap.local_to_map(get_parent().global_position)
		
		var direction = (get_global_mouse_position() - get_global_position()).normalized()

		if !BADTILES.has(currentMap.get_cell_atlas_coords(tileCoords)):
			currentMap.set_cell(tileCoords, 0, Vector2i(5, 0), 0)
			wallBroke = true
		tileCoords += Vector2i(round(direction.x), round(direction.y))
		if !BADTILES.has(currentMap.get_cell_atlas_coords(tileCoords)):
			currentMap.set_cell(tileCoords, 0, Vector2i(5, 0), 0)
			wallBroke = true
		if wallBroke:
			Manager.playSound("dSound", get_parent().global_position)
			ammo -= 1

func melee():
	for i in range(hitBox.get_collision_count()):
		var collider = hitBox.get_collider(i)
		if hitBox.is_colliding():
			if collider != null:
				if collider.get("enemy") == true:
					collider.call("hit", 220)


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
			Manager.playSound("sSound", global_position)
			wait()
		else:
			wait()
			canFire = false
			Manager.playSound("pSound", global_position)
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
	else:
		await get_tree().create_timer(fireRate).timeout
	canFire = true
	return true

func waitPunch():
	await get_tree().create_timer(.2).timeout
	punching = false
	if gunType == 0:
			texture = null


#Functions Called on Weapon pick up
func update_values(value: int, currentAmmo: int):
	currentSprite = null
	gunType = value
	ammo = currentAmmo
	SignalBus.updateAmmo.emit(ammo)
	canFire = true
	gunPickedUp = true
	hitBox.visible = false
	match value:
		1:
			currentSprite = pistolImg
			rotation = 0
			scale.x = .9
			scale.y = .25
			dammage = 100
			fireRate = .2
		2:
			currentSprite = rifleImg
			scale.x = 0.612
			scale.y = 0.622
			rotation_degrees = 72.9
			dammage = 100
			fireRate = .1
		3:
			currentSprite = shotgunImg
			rotation_degrees = 17.0
			scale.x = 0.612
			scale.y = 0.289
			dammage = 100
			fireRate = .8
		4:
			currentSprite = hammerImg
			rotation_degrees = 0
			scale.x = 1
			scale.y = 1
			dammage = 220
			fireRate = 1
		_:
			hitBox.visible = true
			fireRate = .25
			scale.x = 1
			scale.y = 1
			rotation = 0
			ammo = 0
			gunPickedUp = false

	texture = currentSprite

func saveWeapon():
	Manager.gunType = gunType
	Manager.ammoCount = ammo

#Functions that handle Dropping a weapon
func instantiate(type: PackedScene):
	var instance = type.instantiate()
	instance.setAmmo(ammo)
	instance.set_meta("placed", "Yer")
	instance.set_collision_layer_value(2, false)
	instance.set_collision_mask_value(2, false)
	instance.set_collision_layer_value(1, false)
	instance.set_collision_mask_value(1, false)
	instance.position = global_position
	instance.rotation = get_parent().rotation
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
