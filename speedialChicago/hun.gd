extends Sprite2D

@export var hitBox: ShapeCast2D

var currentSprite: Texture
var bullet: PackedScene = load("res://scenes/bullet.tscn")
var rng = RandomNumberGenerator.new()

var pistol: PackedScene = load("res://scenes/pistol.tscn")
var rifle: PackedScene = load("res://scenes/rifle.tscn")
var shotgun: PackedScene = load("res://scenes/shotgun.tscn")

var punchTexture: Texture = load("res://assets/punch.svg")

var gunPickedUp = false

var canFire = true
var ammo = 0;
var gunType = 0
var dammage = 100
var fireRate = .5
var punching = false

#Updates Player on current ammo amount:
func getAmmo() -> int:
	return ammo

#Functions that Shoot the gun
func _process(_delta: float) -> void:
	if Input.is_action_pressed("shoot") and canFire and ammo > 0:
		fire()
		ammo -= 1
		get_node("/root/Lvl1/Camera2D/AmAm").text = "Ammo:" + str(ammo)

	print(canFire)
	if Input.is_action_pressed("shoot") and !gunPickedUp and canFire:
		punching = true
		wait(1)
		Manager.playSound("pSound", global_position)
		

	if Input.is_action_just_pressed("Drop") and gunPickedUp:
		dropWeapon(gunType)
		get_node("/root/Lvl1/Camera2D/AmAm").hide()
		update_values(0, 0)
	
	if punching:
		melee()

func melee():
	canFire = false
	texture = punchTexture
	offset = Vector2(-20, 0).rotated(get_parent().rotation)
	for i in range(hitBox.get_collision_count()):
		var collider = hitBox.get_collider(i)
		if hitBox.is_colliding():
			if collider.get("enemy") == true:
				collider.call("hit", 220)


func fire() -> void:
	if gunType == 3:
		for i in range(6):
			canFire = false
			var bull = bullet.instantiate()
			if i < 3:
				bull.dir = get_parent().rotation + rng.randf_range(-.15, .15)
			else:
				bull.dir = get_parent().rotation + rng.randf_range(-.25, .25)
			bull.pos = global_position
			bull.rota = global_rotation
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
		bull.rota = global_rotation
		bull.damage = dammage
		get_tree().root.add_child(bull)

func wait(_punched: int = 0) -> bool:
	if _punched == 1:
		await get_tree().create_timer(.25).timeout
		texture = null
		punching = false
	else:
		await get_tree().create_timer(fireRate).timeout
	canFire = true
	return true

#Functions Called on Weapon pick up
func update_values(value: int, currentAmmo: int):
	currentSprite = null
	gunType = value
	ammo = currentAmmo
	get_node("/root/Lvl1/Camera2D/AmAm").text = "Ammo:" + str(ammo)
	canFire = true
	gunPickedUp = true
	hitBox.visible = false
	match value:
		1:
			currentSprite = load("res://assets/basicSquare.svg")
			rotation = 0
			scale.x = .9
			scale.y = .25
			dammage = 100
			fireRate = .2
		2:
			currentSprite = load("res://assets/Guitar-b.svg")
			scale.x = 0.612
			scale.y = 0.622
			rotation_degrees = 72.9
			dammage = 100
			fireRate = .1
		3:
			currentSprite = load("res://assets/Frog 2-c.svg")
			rotation_degrees = 17.0
			scale.x = 0.612
			scale.y = 0.289
			dammage = 100
			fireRate = .8
		_:
			hitBox.visible = true
			fireRate = .5
			scale.x = 1
			scale.y = 1
			rotation = 0
			ammo = 0
			gunPickedUp = false

	texture = currentSprite


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
