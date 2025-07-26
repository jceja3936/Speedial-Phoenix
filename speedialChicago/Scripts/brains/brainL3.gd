extends Node
@export var player: CharacterBody2D
var endPosition = Vector2.ZERO
var state = 1
var levelBeat = false
var stage = [0]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_State(Manager.levelState)

func set_State(newState: int):
	state = newState
	match state:
		1:
			Manager.setEnemyAmount(24)
			$Start.position = Vector2(2090.0, 138.0)
		_:
			print("Bruh, Brain setState received ", state)

	if levelBeat == true:
		Manager.setEnemyAmount(0)
		$Start.position = Vector2(2090.0, 138.0)


func _physics_process(_delta: float) -> void:
	if Manager.enemyAmount == 0:
		$arrow.position = player.global_position + Vector2(0, 100)
		$arrow.show()

		match state:
			1:
				SignalBus.emit_signal("levelBeat")
				Manager.gamePaused = true
				levelBeat = true
				playOnce()
				$arrow.look_at($Start.global_position)


	else:
		$arrow.hide()

func playOnce():
	if stage[0] == 0:
		stage[0] = 1
		SignalBus.emit_signal("saveScore")
		SignalBus.emit_signal("saveWB")
		Manager.playSound("levelBeat", player.global_position, 10.5)

func _on_start_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if levelBeat and player.get("moved") == true:
			SignalBus.emit_signal("playCutscene")
			SignalBus.emit_signal("saveScore")
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			await get_tree().create_timer(2).timeout
			Manager.next_scene = "res://scenes/UIscenes/end_screen.tscn"
			Manager.startNextScene()
