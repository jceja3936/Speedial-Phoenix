extends AudioStreamPlayer

var pistol: PackedScene = load("res://scenes/gunScenes/pistol.tscn")
var rifle: PackedScene = load("res://scenes/gunScenes/rifle.tscn")
var shotgun: PackedScene = load("res://scenes/gunScenes/shotgun.tscn")

var next_scene: String = "res://scenes/lvlScenes/Lvl1.tscn"
var current_scene: String = "1_1"
var loadingScreen = preload("res://scenes/UIscenes/loading_screen.tscn")

var playerRespawnPos = Vector2.ZERO
var levelState = 1
var gunType = 0
var ammoCount = 0
var points = 0
var mult = 1

var enemyAmount = 0

var item_sounds = {
	"pSound": preload("res://assets/aud/9mm.wav"),
	"sSound": preload("res://assets/aud/Big Boing.wav"),
	"dSound": preload("res://assets/aud/wallBreak1.wav")
	# Add more as needed or load dynamically
}


func startNextScene():
	var loadScreen = loadingScreen.instantiate()
	get_tree().root.add_child(loadScreen)

func playSound(item_name: String, pos: Vector2):
	var sound = item_sounds.get(item_name)
	if sound:
		var player = AudioStreamPlayer2D.new()
		if item_name == "dSound":
			player.volume_db = 5.0
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
	points += 100 * mult
	mult += 1

func startMult():
	var currentEnemyAmount = enemyAmount
	await get_tree().create_timer(.7).timeout
	if currentEnemyAmount == enemyAmount:
		mult = 1

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
