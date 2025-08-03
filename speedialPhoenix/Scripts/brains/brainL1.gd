extends Node
@export var player: CharacterBody2D
var endPosition = Vector2.ZERO
var state = 1
var stage = [0, 0]
var levelBeat = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameAudio.levelBeat = false
	set_State(Manager.levelState)
	

func _physics_process(_delta: float) -> void:
	if Manager.enemyAmount == 0:
		$arrow.position = player.global_position + Vector2(0, 100)
		$arrow.show()

		match state:
			1:
				SignalBus.emit_signal("floorBeat")
				playOnce()
				$arrow.look_at($end.global_position)

			2:
				playOnce()
				GameAudio.pauseMusic()
				GameAudio.levelBeat = true
				Manager.gamePaused = true
				SignalBus.emit_signal("levelBeat")
				$arrow.look_at($end.global_position)
			3:
				SignalBus.emit_signal("levelBeat")
				$arrow.look_at($start.global_position)
	else:
		$arrow.hide()

func playOnce():
	if stage[0] == 0:
		stage[0] = 1
		Manager.playSound("floorBeat", player.global_position, 10.5)
	elif stage[1] == 0 and state == 2:
		stage[1] = 1
		Manager.playSound("levelBeat", player.global_position, 10.5)
		
	
func set_State(newState: int):
	state = newState
	match state:
		1:
			Manager.setEnemyAmount(1)
			endPosition = Vector2(-57.0, 1023)
			$start.position = Vector2(1097.0, 355.0)
		2:
			set_deferred("$start/CollisionShape2D.disabled", true)
			Manager.setEnemyAmount(4)
			endPosition = Vector2(2214.0, 2677.0)
			$start.position = Vector2(1678.0, 2821.0)
			set_deferred("$start/CollisionShape2D.disabled", true)
		3:
			endPosition = Vector2(-57.0, 1023)
			$start.position = Vector2(1097.0, 328.0)
		_:
			print("Bruh, Brain setState is received ", state)

	if levelBeat == true:
		Manager.setEnemyAmount(0)
		$start.position = Vector2(1097.0, 328.0)

	$end.position = endPosition


func _on_start_body_entered(body: Node2D) -> void:
	if Manager.levelState == 3:
		SignalBus.emit_signal("playCutscene")
		SignalBus.emit_signal("saveScore")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		await get_tree().create_timer(2).timeout
		Manager.next_scene = "res://scenes/UIscenes/end_screen.tscn"

		Manager.startNextScene()

	if body.name == "Player":
		match state:
				1:
					$blocker.position = Vector2(1107.0, 207.0)
				2:
					$blocker.position = Vector2(2079, 2598.0)
	if Manager.getEnemyAmount() == 0:
		$blocker.position = Vector2.ZERO
					

func _on_end_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if Manager.getEnemyAmount() == 0:
			match state:
				1:
					player.makeHunSave()
					SignalBus.emit_signal("saveScore")
					Manager.playerRespawnPos = Vector2(1839.0, 2611.0)
					SignalBus.emit_signal("teleporting")
					player.set("finish", true)
					await get_tree().create_timer(.15).timeout
					player.set("finish", false)
					player.position = Vector2(2121.0, 2606.0)
					Manager.levelState = 2
					set_State(2)
					Manager.playSound("floorBeat", Vector2(1678.0, 2821.0), 10.5)
				2:
					SignalBus.emit_signal("teleporting")
					levelBeat = true
					player.set("finish", true)
					await get_tree().create_timer(.15).timeout
					player.set("finish", false)
					player.position = Vector2(124.0, 1038.0)
					Manager.levelState = 3
					set_State(3)
					Manager.playSound("floorBeat", Vector2(124.0, 1038.0), 10.5)
				3:
					SignalBus.emit_signal("teleporting")
					player.set("finish", true)
					await get_tree().create_timer(.15).timeout
					player.set("finish", false)
					player.position = Vector2(1830.0, 2606.0)
					set_State(2)
					Manager.playSound("floorBeat", Vector2(1678.0, 2821.0), 10.5)
