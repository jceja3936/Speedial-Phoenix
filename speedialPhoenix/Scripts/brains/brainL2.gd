extends Node
@export var player: CharacterBody2D
var endPosition = Vector2.ZERO
var state = 1
var levelBeat = false
var stage = [0, 0]
var jankyBugFix = false

var francis: PackedScene = load("res://scenes/player.tscn")
var claire: PackedScene = load("res://scenes/claire.tscn")


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
		get_parent().add_child.call_deferred(character)
	
			
	MenuMusic.pauseMusic()
	GameAudio.levelBeat = false
	set_State(Manager.levelState)

func getPlayer():
	player = get_node("/root/Lvl2/Player")

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
				SignalBus.emit_signal("levelBeat")
				Manager.gamePaused = true
				GameAudio.pauseMusic()
				GameAudio.levelBeat = true
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
			Manager.setEnemyAmount(10)
			endPosition = Vector2(3398.0, 769.0)
			$start.position = Vector2(2499.0, 775.0)
		2:
			Manager.setEnemyAmount(12)
			endPosition = Vector2(171.0, 5380.0)
			$start.position = Vector2(509.0, 5369.0)
		3:
			endPosition = Vector2(3398.0, 769.0)
			$start.position = Vector2(469.0, 767.0)
		_:
			print("Bruh, Brain setState received ", state)

	if levelBeat == true:
		Manager.setEnemyAmount(0)
		$start.position = Vector2(469.0, 767.0)
		$blocker.position = Vector2(10000, 10000)

	$end.position = endPosition


func _on_start_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		match state:
				1:
					$blocker.position = Vector2(2666.0, 764.0)
				2:
					$blocker.position = Vector2(290.0, 5380.0)
	
	if Manager.getEnemyAmount() == 0:
		$blocker.position = Vector2(10000, 10000)

	if Manager.levelState == 3 and jankyBugFix == true:
		SignalBus.emit_signal("playCutscene")
		SignalBus.emit_signal("saveScore")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		await get_tree().create_timer(2).timeout
		Manager.next_scene = "res://scenes/UIscenes/end_screen.tscn"

		Manager.startNextScene()

					
func bugFix():
	await get_tree().create_timer(1).timeout
	jankyBugFix = true


func _on_end_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if Manager.getEnemyAmount() == 0:
			match state:
				1:
					player.makeHunSave()
					SignalBus.emit_signal("saveScore")
					SignalBus.emit_signal("saveWB")
					Manager.playerRespawnPos = Vector2(473.0, 5372.0)
					SignalBus.emit_signal("teleporting")
					player.set("finish", true)
					await get_tree().create_timer(.15).timeout
					player.set("finish", false)
					player.position = Vector2(198.0, 5372.0)
					player.set("moved", false)
					player.call("loading")
					Manager.levelState = 2
					set_State(2)
					Manager.playSound("floorBeat", Vector2(198.0, 5372.0), 10.5)
				2:
					levelBeat = true
					bugFix()
					SignalBus.emit_signal("saveWB")
					SignalBus.emit_signal("teleporting")
					player.set("finish", true)
					await get_tree().create_timer(.15).timeout
					player.set("finish", false)
					player.position = Vector2(3061.0, 762.0)
					player.call("loading")
					player.set("moved", false)
					Manager.levelState = 3
					set_State(3)
					Manager.playSound("floorBeat", Vector2(3061.0, 762.0), 10.5)
				3:
					SignalBus.emit_signal("teleporting")
					player.set("finish", true)
					await get_tree().create_timer(.15).timeout
					player.set("finish", false)
					player.position = Vector2(466.0, 5370.0)
					player.call("loading")
					set_State(2)
					Manager.playSound("floorBeat", Vector2(466.0, 5370.0), 10.5)
