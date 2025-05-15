extends CharacterBody2D

@export var player : CharacterBody2D


func _process(delta: float) -> void:
	var wherePlayer = player.global_position - global_position
	
	if wherePlayer.length() < 1200:
		$ray.target_position = $ray.to_local(player.global_position)
		$ray.force_raycast_update()
		if $ray.is_colliding():
			var hit = $ray.get_collider()
			if hit == player:
				look_at(player.global_position)
