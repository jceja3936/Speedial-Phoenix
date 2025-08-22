extends Node2D

var player: CharacterBody2D
var levelBeat = false
var doneArray = [0, 0, 0]

var playerInPlace = false

var francis: PackedScene = load("res://scenes/Characters/player.tscn")
var claire: PackedScene = load("res://scenes/Characters/claire.tscn")

func getPlayer():
	player = get_node("/root/Lvl-2/Player")

func _ready() -> void:
	$playerSub/playerChaser.modulate.a = 0.0
	$detector.position = Vector2(1284.0, 491.0)
	$endZone.position = Vector2(1851.0, 510.0)
	Manager.gamePaused = false
	MenuMusic.pauseMusic()
	SignalBus.playerReady.connect(getPlayer)
	var character = null
	match Manager.chosenChar:
		0:
			character = francis.instantiate()
		1:
			character = claire.instantiate()

	if character != null:
		character.name = "Player"
		add_child.call_deferred(character)

func _physics_process(_delta):
	if player == null:
		return
	$playerSub.position = player.global_position

	if playerInPlace and $playerSub/playerChaser.modulate.a < 1.0:
		$playerSub/playerChaser.modulate.a += .04
		await wait(.05)
	elif !playerInPlace and $playerSub/playerChaser.modulate.a > 0.0:
		$playerSub/playerChaser.modulate.a -= .04
		await wait(.05)


func wait(value):
	await get_tree().create_timer(value).timeout
	return true


func _on_detector_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		playerInPlace = false

func _on_detector_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		playerInPlace = true


func _on_end_zone_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if doneArray[0] == 0:
			doneArray[0] = 1
			$playerSub/playerChaser.text = "Walk Into Ammo to Pick it Up"
			$detector.position = Vector2(2247.0, 524.0)
			$endZone.position = Vector2(3012.0, 523.0)
		elif doneArray[1] == 0:
			doneArray[1] = 1
			$playerSub/playerChaser.text = "LMB/R2 to Fire"
			$detector.position = Vector2(3205.0, 516.0)
			$endZone.position = Vector2(6866.0, 523.0)
		elif doneArray[2] == 0:
			doneArray[2] = 1
			SignalBus.emit_signal("playCutscene")
			SignalBus.emit_signal("makeCamPoint", 270)
			SignalBus.emit_signal("saveWB")
			SignalBus.emit_signal("saveScore")
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			await get_tree().create_timer(2).timeout
			Manager.next_scene = "res://scenes/UIscenes/end_screen.tscn"
			Manager.startNextScene()
