extends AudioStreamPlayer

var pistol: PackedScene = load("res://scenes/pistol.tscn")
var rifle: PackedScene = load("res://scenes/rifle.tscn")
var shotgun: PackedScene = load("res://scenes/shotgun.tscn")

var next_scene: String = "res://scenes/Lvl1.tscn"
var loadingScreen = preload("res://scenes/loading_screen.tscn")

var enemyAmount = 0

var item_sounds = {
	"pSound": preload("res://assets/9mm.wav"),
	"sSound": preload("res://assets/Big Boing.wav")
	# Add more as needed or load dynamically
}

func playSound(item_name: String, pos: Vector2):
	var sound = item_sounds.get(item_name)
	if sound:
		var player = AudioStreamPlayer2D.new()
		player.stream = sound
		get_tree().current_scene.add_child(player)
		player.position = pos
		player.play()
		await get_tree().create_timer(sound.get_length()).timeout
		if player:
			player.queue_free()

func setEnemyAmount(amount: int):
	enemyAmount = amount

func getEnemyAmount():
	return enemyAmount

func decrementEnemyAmount():
	enemyAmount -= 1

#Functions that handle Dropping a weapon
func instantiate(type: PackedScene, who: CharacterBody2D, ammo: int):
	var instance = type.instantiate()
	instance.setAmmo(ammo)
	instance.set_meta("placed", "Yer")
	instance.set_collision_layer_value(2, false)
	instance.set_collision_mask_value(2, false)
	instance.set_collision_layer_value(1, false)
	instance.set_collision_mask_value(1, false)
	instance.position = who.global_position
	instance.rotation = who.rotation
	get_tree().root.add_child(instance)

func dropWeapon(gun: int, who: CharacterBody2D, ammo: int):
	get_parent().set("gunPickedUp", false)
	match gun:
		1:
			instantiate(pistol, who, ammo)
		2:
			instantiate(rifle, who, ammo)
		3:
			instantiate(shotgun, who, ammo)
