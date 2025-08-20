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
	
func _physics_process(_delta: float) -> void:
	if Manager.enemyAmount == 0:
		$arrow.position = player.global_position + Vector2(0, 100)
		$arrow.show()

		GameAudio.pauseMusic()
		GameAudio.levelBeat = true
		SignalBus.emit_signal("levelBeat")
		Manager.gamePaused = true
		levelBeat = true
		playOnce()
		$arrow.look_at($warpZone.global_position)


	else:
		$arrow.hide()

func getPlayer():
	player = get_node("/root/Lvl6/Player")

func set_State(newState: int):
	state = newState
	match state:
		1:
			Manager.setEnemyAmount(32)

	if levelBeat == true:
		Manager.setEnemyAmount(0)
	
func playOnce():
	if stage[0] == 0:
		Manager.clareLevels[2] = "1"
		Manager.save()
		stage[0] = 1
		SignalBus.emit_signal("saveScore")
		SignalBus.emit_signal("saveWB")
		Manager.playSound("levelBeat", player.global_position, 10.5)

func _on_warp_zone_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if levelBeat and player.get("moved") == true:
			SignalBus.emit_signal("makeCamPoint", 180)
			SignalBus.emit_signal("playCutscene")
			SignalBus.emit_signal("saveScore")
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			await get_tree().create_timer(2).timeout
			Manager.next_scene = "res://scenes/UIscenes/end_screen.tscn"
			Manager.startNextScene()
