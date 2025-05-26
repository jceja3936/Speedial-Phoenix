extends Camera2D

@export var player: CharacterBody2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	position = player.get_global_position()

func _ready() -> void:
	$AmAm.hide()
	$Respawn.hide()
