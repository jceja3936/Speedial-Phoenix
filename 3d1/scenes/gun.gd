extends Node2D

@export var player : CharacterBody2D

func _physics_process(delta: float) -> void:
	
	look_at(get_global_mouse_position())
	var mouse_pos = get_global_mouse_position()
	var direction = mouse_pos-player.global_position
	var distance = direction.length()
	if distance > 100:
		global_position = player.position + direction.normalized() * 100
	else :
		global_position = mouse_pos
		look_at(direction)
	
