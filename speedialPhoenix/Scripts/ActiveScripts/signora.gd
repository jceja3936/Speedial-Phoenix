extends Sprite2D

var ammo = 6
var fireRate = .5
var canFire = true
var canVault = true
var bullet: PackedScene = load("res://scenes/bullet.tscn")
var rng = RandomNumberGenerator.new()
var paused = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_scale = Vector2(1.5, 1.5)
	if Manager.ammoCount != 0:
		ammo = Manager.ammoCount
	SignalBus.updateAmmo.emit(ammo)
	pass # Replace with function body.

func moreAmmo(value):
	ammo += value
	SignalBus.updateAmmo.emit(ammo)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if paused:
		return

	if Input.is_action_just_pressed("Respawn") and canVault:
		canVault = false
		get_parent().set_collision_mask_value(2, false)
		wait(1)
		await get_tree().create_timer(.25).timeout
		get_parent().set_collision_mask_value(2, true)


	if Input.is_action_pressed("shoot") and canFire:
		fire()
		SignalBus.updateAmmo.emit(ammo)


func saveWeapon():
	Manager.ammoCount = ammo

func fire():
	if ammo > 0:
		ammo -= 1
		wait()
		canFire = false
		Manager.playSound("pSound", global_position, -5.0)
		var bull = bullet.instantiate()
		bull.dir = get_parent().rotation + rng.randf_range(-.1, .1)
		bull.pos = global_position
		bull.rota = get_parent().rotation
		bull.damage = 400
		get_tree().root.add_child(bull)


func wait(_jumped: int = 0) -> bool:
	if _jumped == 1:
		await get_tree().create_timer(.35).timeout
		canVault = true
		return true

	await get_tree().create_timer(fireRate).timeout
	canFire = true
	return true