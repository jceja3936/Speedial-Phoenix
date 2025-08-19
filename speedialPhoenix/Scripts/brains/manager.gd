extends Node2D

@warning_ignore("integer_division")
@warning_ignore("integer_division")

var pistol: PackedScene = load("res://scenes/gunScenes/pistol.tscn")
var rifle: PackedScene = load("res://scenes/gunScenes/rifle.tscn")
var shotgun: PackedScene = load("res://scenes/gunScenes/shotgun.tscn")

var next_scene: String = "res://scenes/lvlScenes/Lvl1.tscn"
var current_scene: String = "1"
var loadingScreen = preload("res://scenes/UIscenes/loading_screen.tscn")
var playerRespawnPos = Vector2.ZERO
var timer = 0.0
var gamePaused = true
var score = -1
var wallsBroke = 0

var chosenChapter = "0"

var chosenChar = 0

var sfx = 0.0

var levelState = 1
var gunType = 0
var ammoCount = 0
var mult = 1
var deaths = 0

var francisLevels = ["0", "0", "0"]
var clareLevels = ["0", "0", "0"]

var enemyAmount = 0
const SAVEFILE = "res://Savegame.txt"

func _ready():
	if !FileAccess.file_exists(SAVEFILE):
		print("No save file!")
		return
	var theFile = FileAccess.open(SAVEFILE, FileAccess.READ)
	var lineCounter = 0
	while theFile.get_position() < theFile.get_length():
		var letterCounter = 0
		var line = theFile.get_line()
		for letter in line:
			if lineCounter == 0:
				francisLevels[letterCounter] = letter
			elif lineCounter == 1:
				clareLevels[letterCounter] = letter
			letterCounter += 1
		lineCounter += 1
	

func printAll():
	print(francisLevels)
	print(clareLevels)

func save():
	var saveLine = ""
	var thefile = FileAccess.open(SAVEFILE, FileAccess.WRITE)

	for boolean in francisLevels:
		saveLine += str(boolean)
	thefile.store_line(saveLine)

	saveLine = ""

	for boolean in clareLevels:
		saveLine += str(boolean)
	thefile.store_line(saveLine)

	
func _physics_process(delta: float):
	if !gamePaused:
		timer += delta

func reset():
	match current_scene:
		"tutorial":
			next_scene = "res://scenes/lvlScenes/tutorial.tscn"
			current_scene = "tutorial"

		"1":
			next_scene = "res://scenes/lvlScenes/Lvl1.tscn"
			current_scene = "1"
			playerRespawnPos = Vector2(418.0, 145.0)
		"2":
			current_scene = "2"
			next_scene = "res://scenes/lvlScenes/Lvl2.tscn"
			playerRespawnPos = Vector2(271.0, 756.0)
		"3":
			current_scene = "3"
			next_scene = "res://scenes/lvlScenes/Lvl3.tscn"
			playerRespawnPos = Vector2(714.0, 136.0)
		"4":
			current_scene = "4"
			next_scene = "res://scenes/lvlScenes/Lvl4.tscn"
			playerRespawnPos = Vector2(1391.0, 1901.0)
		"5":
			current_scene = "5"
			next_scene = "res://scenes/lvlScenes/Lvl5.tscn"
			playerRespawnPos = Vector2(287.0, 97.0)

	gamePaused = true
	timer = 0
	levelState = 1
	gunType = 0
	ammoCount = 0
	score = -1
	mult = 1
	deaths = 0
	enemyAmount = 0

var item_sounds = {
	"Deagle": preload("res://assets/aud/Deagle.wav"),
	"pSound": preload("res://assets/aud/revolv.mp3"),
	"sSound": preload("res://assets/aud/shotgun.wav"),
	"dSound": preload("res://assets/aud/wallBreak1.wav"),
	"punched": preload("res://assets/aud/ounched.wav"),
	"swing": preload("res://assets/aud/swing.wav"),
	"bLand": preload("res://assets/aud/bullLand.wav"),
	"floorBeat": preload("res://assets/aud/floorBeat.wav"),
	"levelBeat": preload("res://assets/aud/KAKAWW.wav"),
	"doorOpen1": preload("res://assets/aud/doorOpen1.mp3"),
	"doorOpen2": preload("res://assets/aud/doorOpen2.wav"),
	"doorOpen3": preload("res://assets/aud/doorOpen3.wav")
	# Add more as needed or load dynamically
}


func startNextScene():
	var loadScreen = loadingScreen.instantiate()
	get_tree().root.add_child(loadScreen)

func playSound(item_name: String, pos: Vector2, _aud: float = 0.0):
	if sfx == -20.0:
		return
	var sound = item_sounds.get(item_name)
	if sound:
		var player = AudioStreamPlayer2D.new()
		player.volume_db = _aud + sfx
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
