extends CharacterBody2D

var pos: Vector2
var dir: float
var rota: float
var damage: int
var speed = 3000
var bullet = true
var fromWho = ""
var id = 999
func _ready() -> void:
	id = randi_range(0, 10000)
	top_level = true
	global_position = pos
	global_rotation = rota
	if fromWho == "enemy":
		set_collision_mask_value(3, false)
	else:
		set_collision_mask_value(4, false)


func _process(_delta: float) -> void:
	velocity = Vector2(speed, 0).rotated(dir)
	move_and_slide()
	
	#Basically, for every collision

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
	#If the collided object doesn't have method "hit", the bullet can safely delete.
		if not collider.has_method("hit") and not collider.get("bullet") and not collider.has_meta("glass"):
			queue_free()
			
	#If that if was passed, it either hit an enemy or a player
		if collider.get("enemy") == true:
			#If it hit a enemy, but was fired by an enemy, don't do damage.
			if fromWho != "enemy":
				collider.call("hit", damage)
				queue_free()
	
		if collider.get("playa") == true:
			if fromWho == "enemy":
				collider.call("hit", damage, id)
				queue_free()
