extends CharacterBody2D

@export var player: CharacterBody2D
@export var shootSFX: AudioStreamPlayer2D
@export var gun: Node2D
@export var ray: RayCast2D
@export var type: int
@onready var nav_Agent: NavigationAgent2D = $NavigationAgent2D

var bullet: PackedScene = load("res://scenes/bullet.tscn")
var deathTexture: Texture = load("res://assets/icon.svg")

var canFire = true
var rng = RandomNumberGenerator.new()
var seen = false
var enemy = true
var lastKnown
var health = 200
var dead = false
var speed = 800

var path: Array = []
var current_path_index := 0
var pathing = false


func _ready() -> void:
	_fireRateControll()
	
func die() -> void:
	$Sprite2D.texture = deathTexture
	$Sprite2D.scale.x = 1
	$Sprite2D.scale.y = 1
	$CollisionShape2D.queue_free()
	dead = true;
	set_script(null)
	
func hit(damage: int) -> void:
	health -= damage
	if health <= 0:
		die()

func _process(_delta: float) -> void:
	if dead:
		return
	
	var wherePlayer = player.global_position - global_position
	
	#This mess handles the main decision making of the enemy
	#If player is within the sight range
	if wherePlayer.length() < 1600:
		#Raycays to their position
		ray.target_position = ray.to_local(player.global_position)
		ray.force_raycast_update()
		#If the raycast hit anything,
		if ray.is_colliding():
			#See if the thing it hit is the player
			var collider = ray.get_collider()
			if collider == player:
				look_at(player.global_position)
				#If it did, activate my "latch" function
				await attackPlayer()
				seen = true
				lastKnown = player.global_position
			#If it wasn', set seen to false.
			if collider != player:
				seen = false
				if lastKnown != null:
					search()

func search():
	var goingTo = lastKnown
	nav_Agent.target_position = goingTo

	var current_Pos = self.global_position
	var next_path_pos = nav_Agent.get_next_path_position()
	var new_velocity = current_Pos.direction_to(next_path_pos)

	if nav_Agent.is_navigation_finished():
		return

	if nav_Agent.avoidance_enabled:
		nav_Agent.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)
	move_and_slide()


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity * speed

#await get_tree().create_timer(1).timeout
#This is really cool actually
func attackPlayer() -> bool:
	#Basically, this is called any time the raycast is actively hitting the player
	#however, to emulate the enemy having a "reaction time" on first call seen is not yet true, and therefore
	#wait a beat before firing. After this first call of attackPlayer, the seen is true and therefore fire at first chance.
	#Once the raycast is lost, seen is back to false, releasing the latch.
	if !seen:
		await get_tree().create_timer(.5).timeout
	fire()
	return true;
	

func fire() -> void:
	if canFire:
		shootSFX.play()
		canFire = false
		var bull = bullet.instantiate()
		bull.set("fromWho", "enemy")
		bull.dir = rotation + rng.randf_range(-.08, .08)
		bull.pos = gun.global_position
		bull.damage = 1
		bull.rota = global_rotation
		add_child(bull)
		await get_tree().create_timer(1).timeout
		if bull:
			bull.queue_free()

func _fireRateControll() -> void:
	if dead:
		return
	canFire = true
	await get_tree().create_timer(.2).timeout
	_fireRateControll()
