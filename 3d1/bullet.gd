extends CharacterBody2D

var pos:Vector2
var dir:float
var rota: float
var speed = 1800


func _ready() -> void:
	top_level = true
	global_position = pos
	global_rotation = rota
	
func _physics_process(delta: float) -> void:
	velocity = Vector2(speed, 0).rotated(dir) 
	move_and_slide()
	
	for i in get_slide_collision_count():
		if get_slide_collision(i).get_collider().get("speed") != 200:
			queue_free()
	
