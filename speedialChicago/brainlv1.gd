extends Node

@export var player: CharacterBody2D
var warpPosition = Vector2.ZERO
var state = 1
var levelBeat = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setState(state)

func setState(newState: int):
	state = newState
	match state:
		1:
			Manager.setEnemyAmount(3)
			warpPosition = Vector2(1683.0, 1261.0)
		2:
			Manager.setEnemyAmount(6)
			warpPosition = Vector2(4758.0, -468.0)
	$Area2D/CollisionShape2D.position = warpPosition
	if levelBeat:
		Manager.setEnemyAmount(0)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if Manager.getEnemyAmount() == 0:
			match state:
				1:
					player.position = Vector2(4202.0, -373.0)
					setState(2)
				2:
					player.position = Vector2(1711.0, 1119.0)
					levelBeat = true
					setState(1)
