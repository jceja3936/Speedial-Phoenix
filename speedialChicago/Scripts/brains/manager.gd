extends AudioStreamPlayer

var pistol: PackedScene = load("res://scenes/gunScenes/pistol.tscn")
var rifle: PackedScene = load("res://scenes/gunScenes/rifle.tscn")
var shotgun: PackedScene = load("res://scenes/gunScenes/shotgun.tscn")

var next_scene: String = "res://scenes/lvlScenes/Lvl1.tscn"
var current_scene: String = "1_1"
var loadingScreen = preload("res://scenes/UIscenes/loading_screen.tscn")
var playerRespawnPos = Vector2.ZERO
var timer = 0.0
var gamePaused = true
var score = 0
var wallsBroke = 0

var levelState = 1
var gunType = 0
var ammoCount = 0
var mult = 1

var enemyAmount = 0

func _physics_process(delta: float):
	if !gamePaused:
		timer += delta

func reset():
	match current_scene:
		"1_1":
			next_scene = "res://scenes/lvlScenes/Lvl1.tscn"
			current_scene = "1_1"
		"2":
			current_scene = "2"
			next_scene = "res://scenes/lvlScenes/Lvl2.tscn"
			
	gamePaused = false
	timer = 0
	levelState = 1
	gunType = 0
	ammoCount = 0
	score = 0
	mult = 1
	enemyAmount = 0
	playerRespawnPos = Vector2.ZERO

var item_sounds = {
	"pSound": preload("res://assets/aud/revolv.mp3"),
	"sSound": preload("res://assets/aud/shotgun.wav"),
	"dSound": preload("res://assets/aud/wallBreak1.wav"),
	"punched": preload("res://assets/aud/ounched.wav"),
	"swing": preload("res://assets/aud/swing.wav"),
	"bLand": preload("res://assets/aud/bullLand.wav"),
	"floorBeat": preload("res://assets/aud/floorBeat.wav"),
	"doorOpen1": preload("res://assets/aud/doorOpen1.mp3"),
	"doorOpen2": preload("res://assets/aud/doorOpen2.wav"),
	"doorOpen3": preload("res://assets/aud/doorOpen3.wav")
	# Add more as needed or load dynamically
}


func startNextScene():
	var loadScreen = loadingScreen.instantiate()
	get_tree().root.add_child(loadScreen)

func playSound(item_name: String, pos: Vector2, _aud: float = 0.0):
	var sound = item_sounds.get(item_name)
	if sound:
		var player = AudioStreamPlayer2D.new()
		player.volume_db = _aud
		player.stream = sound
		get_tree().current_scene.add_child(player)
		player.position = pos
		player.play()
		await get_tree().create_timer(sound.get_length()).timeout
		if player:
			player.queue_free()
			return true

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
	instance.position = who.global_position
	instance.rotation = who.rotation
	instance.set("dropped", true)
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
