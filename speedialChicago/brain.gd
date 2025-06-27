extends Node
@export var player: CharacterBody2D
var warpPosition = Vector2.ZERO
var state = 1
var levelBeat = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state = 0
	match Manager.current_scene:
		"1_1":
			state = 1
		"1_2":
			state = 2
	setState(state)

func setState(newState: int):
	state = newState
	match state:
		1:
			Manager.setEnemyAmount(3)
			warpPosition = Vector2(1683.0, 1261.0)
		2:
			Manager.setEnemyAmount(6)
			warpPosition = Vector2(1686.0, 0)

	$Area2D/CollisionShape2D.position = warpPosition

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if Manager.getEnemyAmount() == 0:
			match state:
				1:
					player.makeHunSave()
					Manager.next_scene = "res://scenes/1_2.tscn"
					Manager.current_scene = "1_2"
					Manager.startNextScene()
				2:
					player.makeHunSave()
					Manager.next_scene = "res://ENDscenes/lvl_1end.tscn"
					Manager.current_scene = "1_3"
					Manager.startNextScene()
