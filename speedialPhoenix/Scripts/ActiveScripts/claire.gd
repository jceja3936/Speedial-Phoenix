extends CharacterBody2D

@export var speed = 1000
@export var health = 200
var cam: Camera2D

var bullet: PackedScene = preload("res://scenes/bullet.tscn")
var deathSprite: Texture = load("res://assets/img/ClareHit.png")

var dead = false
var canFire = false
var gunPickedUp = false

var rng = RandomNumberGenerator.new()
var playa = true
var cameFollow = true

var camExt = false
var finish = false
var gamePaused = false

var ambiencePlaying = false

var moved = false


func _ready() -> void:
	SignalBus.emit_signal("changeScore", 300)
	if GameAudio.isPlaying == false and Manager.current_scene != "tutorial":
		GameAudio.playMusic()
	else:
		playAmbience()
	SignalBus.emit_signal("playerReady")
	SignalBus.paused.connect(paused)
	SignalBus.unPaused.connect(unPaused)
	SignalBus.levelBeat.connect(playAmbience)
	SignalBus.playCutscene.connect(cutScenePlaying)
	SignalBus.updateScore.connect(speedBoost)
	SignalBus.updateResp.emit(false)
	if Manager.playerRespawnPos != Vector2.ZERO:
		position = Manager.playerRespawnPos

	var camNode = ""
	if Manager.current_scene != "tutorial":
		camNode = "/root/" + "Lvl" + Manager.current_scene + "/theCam"
	else:
		camNode = "/root/" + Manager.current_scene + "/theCam"


	cam = get_node(camNode)

func speedBoost(_bruh):
	speed += 200
	speedCooldown()

func speedCooldown():
	await get_tree().create_timer(1).timeout
	speed -= 200


func _notification(_what):
	return
	#This is a fix I don't yet know if I'm gonna implement
	#if what == NOTIFICATION_WM_MOUSE_EXIT:
	#	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#	cameFollow = false
	#	cam.setCam(1)
	#	$hun.stop()
	#	SignalBus.emit_signal("paused")

func cutScenePlaying():
	finish = true

func playAmbience():
	if GameAudio.canPlay and !ambiencePlaying:
		ambiencePlaying = true
		$sound.play()
		$sound.volume_db = GameAudio.musicSound

func pauseAmbience():
	$sound.stream_paused = true


func unPaused():
	$Signora.paused = false
	if Manager.current_scene == "tutorial":
		gamePaused = false
		Manager.gamePaused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
		cameFollow = true
		cam.setCam(0)
		return
		
	gamePaused = false
	GameAudio.resumeMusic()
	Manager.gamePaused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	cameFollow = true
	cam.setCam(0)


var lastGuy = 0
func hit(damage: int, id: int) -> void:
	if id != lastGuy:
		health -= damage
		lastGuy = id
	if health <= 0 and !dead:
		$Signora.paused = true
		die()

func die() -> void:
	$Sprite2D.texture = deathSprite
	$Sprite2D.rotation_degrees = 0
	SignalBus.updateResp.emit(true)
	Manager.deaths += 1
	dead = true

func paused():
	gamePaused = true
	$Signora.paused = true
	GameAudio.pauseMusic()
	Manager.gamePaused = true

func _input(event):
	if finish:
		return
	if event.is_action_pressed("esc") and cameFollow:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		cameFollow = false
		cam.setCam(1)
		$Signora.paused = true
		SignalBus.emit_signal("paused")
		
	elif event.is_action_pressed("esc") and !cameFollow:
		#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
		cameFollow = true
		$Signora.paused = false
		cam.setCam(0)
		SignalBus.emit_signal("unPaused")

	if event.is_action_pressed("extendCam") and cameFollow and !camExt:
		cam.setCam(2)
		camExt = true

	if event.is_action_released("extendCam"):
		cam.setCam(0)
		camExt = false

	if event.is_action_pressed("Respawn") and dead:
		dead = false
		Manager.startNextScene()


func _physics_process(delta: float) -> void:
	if dead or finish or gamePaused:
		return

	look_at(get_global_mouse_position())
	var dir = Input.get_vector("Left", "Right", "Up", "Down")
	if dir:
		moved = true
		position += dir * speed * delta
	else:
		velocity = Vector2(0, 0)

	move_and_slide()

func makeHunSave():
	$Signora.saveWeapon()

func loading():
	gamePaused = true
	await get_tree().create_timer(.2).timeout
	gamePaused = false

func weaponGrabbed(_which: int, currentAmmo: int) -> void:
	if currentAmmo > 3:
		currentAmmo = 3
	$Signora.moreAmmo(currentAmmo)