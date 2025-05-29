extends Sprite2D

var currentSprite: Texture
var bullet: PackedScene = load("res://scenes/bullet.tscn")
var rng = RandomNumberGenerator.new()

var pistol: PackedScene = load("res://scenes/pistol.tscn")
var rifle: PackedScene = load("res://scenes/rifle.tscn")
var shotgun: PackedScene = load("res://scenes/shotgun.tscn")

var pSound = load("res://assets/9mm.wav")

var gunPickedUp = false

var canFire = false
var ammo = 10;
var gunType = 1
var dammage = 100
var fireRate = .2

#Updates Player on current ammo amount:
func getAmmo() -> int:
	return ammo


#Functions that Shoot the gun
func _process(_delta: float) -> void:
	if Input.is_action_pressed("shoot") and canFire and ammo > 0:
		fire()
		ammo -= 1
		get_node("/root/Level/Camera2D/AmAm").text = "Ammo:" + str(ammo)

	if Input.is_action_just_pressed("Drop") and gunPickedUp:
		dropWeapon(gunType)
		get_node("/root/Level/Camera2D/AmAm").hide()
		update_values(0, 0)
		

func fire() -> void:
	if gunType == 3:
		for i in range(6):
			canFire = false
			var bull = bullet.instantiate()
			bull.dir = get_parent().rotation + rng.randf_range(-.24, .24)
			bull.pos = global_position
			bull.rota = global_rotation
			bull.damage = dammage
			get_tree().root.add_child(bull)
		Manager.playSound("sSound")
		wait()
	else:
		wait()
		canFire = false
		Manager.playSound("pSound")
		var bull = bullet.instantiate()
		bull.dir = get_parent().rotation + rng.randf_range(-.1, .1)
		bull.pos = global_position
		bull.rota = global_rotation
		bull.damage = dammage
		get_tree().root.add_child(bull)
		await get_tree().create_timer(1).timeout
		if bull:
			bull.queue_free()

func wait() -> bool:
	await get_tree().create_timer(fireRate).timeout
	canFire = true
	return true

#Functions Called on Weapon pick up
func update_values(value: int, currentAmmo: int):
	currentSprite = null
	gunType = value
	ammo = currentAmmo
	get_node("/root/Level/Camera2D/AmAm").text = "Ammo:" + str(ammo)
	canFire = true
	gunPickedUp = true
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
			dammage = 80
			fireRate = .1
		3:
			currentSprite = load("res://assets/Frog 2-c.svg")
			rotation_degrees = 17.0
			scale.x = 0.612
			scale.y = 0.289
			dammage = 50
			fireRate = .8
	texture = currentSprite


#Functions that handle Dropping a weapon
func instantiate(type: PackedScene):
	var instance = type.instantiate()
	instance.setAmmo(ammo)
	instance.set_meta("placed", "Yer")
	instance.set_collision_layer_value(2, true)
	instance.set_collision_mask_value(2, true)
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
