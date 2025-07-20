extends Node
@export var player: CharacterBody2D
var endPosition = Vector2.ZERO
var state = 1
var levelBeat = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_State(Manager.levelState)

func set_State(newState: int):
	state = newState
	match state:
		1:
			Manager.setEnemyAmount(10)
			endPosition = Vector2(3398.0, 769.0)
			$start.position = Vector2(2499.0, 775.0)
		2:
			Manager.setEnemyAmount(1)
			endPosition = Vector2(171.0, 5380.0)
			$start.position = Vector2(509.0, 5369.0)
		_:
			print("Bruh, Brain setState received ", state)

	if levelBeat == true:
		Manager.setEnemyAmount(0)
		$start.position = Vector2(1097.0, 328.0)

	$end.position = endPosition


func _on_start_body_entered(body: Node2D) -> void:
	if Manager.levelState == 3:
		SignalBus.emit_signal("saveScore")
		Manager.next_scene = "res://scenes/UIscenes/end_screen.tscn"
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Manager.startNextScene()

	if body.name == "Player":
		match state:
				1:
					$blocker.position = Vector2(2666.0, 764.0)
				2:
					$blocker.position = Vector2(290.0, 5380.0)
	if Manager.getEnemyAmount() == 0:
		$blocker.position = Vector2(10000, 10000)
					

func _on_end_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if Manager.getEnemyAmount() == 0:
			match state:
				1:
					player.makeHunSave()
					SignalBus.emit_signal("saveScore")
					Manager.playerRespawnPos = Vector2(473.0, 5372.0)
					player.position = Vector2(198.0, 5372.0)
					Manager.levelState = 2
					set_State(2)
				2:
					levelBeat = true
					player.position = Vector2(3061.0, 762.0)
