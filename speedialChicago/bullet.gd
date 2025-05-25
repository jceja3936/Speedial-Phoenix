extends CharacterBody2D

var pos: Vector2
var dir: float
var rota: float
var speed = 1800
var bullet = true
var fromWho = ""
var damage = 100
func _ready() -> void:
	top_level = true
	global_position = pos
	global_rotation = rota

func _physics_process(_delta: float) -> void:
	velocity = Vector2(speed, 0).rotated(dir)
	move_and_slide()
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if not collider.has_method("hit"):
			queue_free()
			
		if collider.get("enemy") == true:
			if fromWho != "enemy":
				collider.call("hit", 100)
			queue_free()
			
		if collider.get("playa") == true:
			collider.call("hit", 100)
			queue_free()
