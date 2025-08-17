extends Node2D
var player: CharacterBody2D
var endPosition = Vector2.ZERO
var state = 1
var stage = [0, 0, 0]
var levelBeat = false

var francis: PackedScene = load("res://scenes/Characters/player.tscn")
var claire: PackedScene = load("res://scenes/Characters/claire.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	
	MenuMusic.pauseMusic()
	GameAudio.levelBeat = false
	Manager.gamePaused = false
	set_State(Manager.levelState)
	
func getPlayer():
	player = get_node("/root/Lvl4/Player")

func _physics_process(_delta: float) -> void:
	if Manager.enemyAmount == 0:
		$arrow.position = player.global_position + Vector2(0, 100)
		$arrow.show()

		match state:
			1:
				SignalBus.emit_signal("floorBeat")
				playOnce()
				$arrow.look_at($warpZone.global_position)

			2:
				SignalBus.emit_signal("floorBeat")
				playOnce()
				$arrow.look_at($warpZone.global_position)
	
			3:
				playOnce()
				GameAudio.pauseMusic()
				levelBeat = true
				GameAudio.levelBeat = true
				Manager.gamePaused = true
				SignalBus.emit_signal("levelBeat")
				$arrow.look_at($warpZone.global_position)
	else:
		$arrow.hide()

func playOnce():
	if stage[0] == 0:
		stage[0] = 1
		Manager.playSound("floorBeat", player.global_position, 10.5)
	elif stage[1] == 0 and state == 2:
		stage[1] = 1
		Manager.playSound("floorBeat", player.global_position, 10.5)
	elif stage[2] == 0 and state == 3:
		stage[2] = 1
		Manager.clareLevels[0] = "1"
		Manager.save()
		Manager.playSound("levelBeat", player.global_position, 10.5)
		
	
func set_State(newState: int):
	state = newState
	match state:
		1:
			Manager.setEnemyAmount(3)
			$warpZone.position = Vector2(-244.0, 1016.0)
		2:
			Manager.setEnemyAmount(4)
			$warpZone.position = Vector2(379.0, 5263.0)
		3:
			Manager.setEnemyAmount(11)
			$warpZone.position = Vector2(4276.0, 1792.0)
		_:
			print("Bruh, Brain setState is received ", state)

	if levelBeat == true:
		Manager.setEnemyAmount(0)


func _on_warp_zone_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if Manager.getEnemyAmount() == 0:
			match state:
				1:
					player.makeHunSave()
					SignalBus.emit_signal("saveScore")
					Manager.playerRespawnPos = Vector2(1373.0, 3280.0)
					SignalBus.emit_signal("teleporting")
					player.set("finish", true)
					await get_tree().create_timer(.15).timeout
					player.set("finish", false)
					player.position = Vector2(1373.0, 3280.0)
					Manager.levelState = 2
					set_State(2)
					Manager.playSound("floorBeat", Vector2(1678.0, 2821.0), 10.5)
				2:
					player.makeHunSave()
					SignalBus.emit_signal("saveScore")
					Manager.playerRespawnPos = Vector2(4494.0, 1767.0)
					SignalBus.emit_signal("teleporting")
					player.set("finish", true)
					await get_tree().create_timer(.15).timeout
					player.set("finish", false)
					player.position = Vector2(4494.0, 1767.0)
					Manager.levelState = 3
					set_State(3)
					Manager.playSound("floorBeat", Vector2(1678.0, 2821.0), 10.5)
				3:
					if levelBeat == true:
						SignalBus.emit_signal("makeCamPoint", 90)
						SignalBus.emit_signal("playCutscene")
						SignalBus.emit_signal("saveScore")
						Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
						await get_tree().create_timer(2).timeout
						Manager.next_scene = "res://scenes/UIscenes/end_screen.tscn"
						Manager.startNextScene()