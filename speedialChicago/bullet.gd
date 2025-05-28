extends CharacterBody2D

var pos: Vector2
var dir: float
var rota: float
var damage: int
var speed = 2500
var bullet = true
var fromWho = ""

func _ready() -> void:
	top_level = true
	global_position = pos
	global_rotation = rota


func _process(_delta: float) -> void:
	velocity = Vector2(speed, 0).rotated(dir)
	move_and_slide()
	
	#Basically, for every collision

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
	#If the collided object doesn't have method "hit", the bullet can safely delete.
		if not collider.has_method("hit") and not collider.get("bullet"):
			queue_free()
			
	#If that if was passed, it either hit an enemy or a player
		if collider.get("enemy") == true:
			#If it hit a enemy, but was fired by an enemy, don't do damage.
			if fromWho != "enemy":
				collider.call("hit", damage)
			queue_free()
	
		if collider.get("playa") == true:
			collider.call("hit", damage)
			queue_free()
