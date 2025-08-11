extends CharacterBody2D

@export var speed = 1000
@export var health = 200
var cam: Camera2D

var bullet: PackedScene = preload("res://scenes/bullet.tscn")

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
	if GameAudio.isPlaying == false and Manager.current_scene != "0":
		GameAudio.playMusic()
	else:
		playAmbience()
	SignalBus.emit_signal("playerReady")
	SignalBus.finishing.connect(finishing)
	SignalBus.paused.connect(paused)
	SignalBus.unPaused.connect(unPaused)
	SignalBus.levelBeat.connect(playAmbience)
	SignalBus.playCutscene.connect(cutScenePlaying)
	SignalBus.updateScore.connect(speedBoost)
	SignalBus.updateResp.emit(false)
	$shader.material.set_shader_parameter("myOpaq", 0.0)
	if Manager.playerRespawnPos != Vector2.ZERO:
		position = Manager.playerRespawnPos

	var camNode = ""
	match Manager.current_scene:
		"0":
			camNode = "/root/tutorial/theCam"
		"1_1":
			camNode = "/root/Lvl1/theCam"
		"2":
			camNode = "/root/Lvl2/theCam"
		"3":
			camNode = "/root/Lvl3/theCam"

	cam = get_node(camNode)

func speedBoost(_bruh):
	speed += 200
	print(speed)
	speedCooldown()

func speedCooldown():
	await get_tree().create_timer(.7).timeout
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
	if Manager.current_scene == "0":
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


func finishing(value: Vector2, enemy: CharacterBody2D):
	if enemy and enemy.get("imHit") == true and !finish:
		finish = true
		position = value
		await get_tree().create_timer(.15).timeout
		Manager.playSound("punched", global_position, -5.0)
		await get_tree().create_timer(.15).timeout
		Manager.playSound("punched", global_position, -5.0)
		if enemy:
			enemy.call("hit", 290)
		finish = false


var lastGuy = 0
func hit(damage: int, id: int) -> void:
	if id != lastGuy:
		health -= damage
		lastGuy = id
	if health <= 0 and !dead:
		$Signora.paused = true
		die()

func die() -> void:
	SignalBus.updateResp.emit(true)
	Manager.deaths += 1
	dead = true
	$shader.material.set_shader_parameter("myOpaq", 8.0)

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