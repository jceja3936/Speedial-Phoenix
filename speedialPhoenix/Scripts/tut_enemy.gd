extends CharacterBody2D

var player: CharacterBody2D

var curve: Curve = load("res://assets/prac.tres")
var deathTexture: Texture = preload("res://assets/img/enemySleep.png")

var imHit = false
var falling = false
var x = 0.0
var toRotby = 0
var health = 200
var dead = false
var enemy = true

func _ready():
	SignalBus.playerReady.connect(getPlayer)

func getPlayer():
	var playerNode = ""

	if Manager.current_scene != "tutorial":
		playerNode = "/root/" + "Lvl" + Manager.current_scene + "/Player"
	else:
		playerNode = "/root/" + Manager.current_scene + "/Player"

	player = get_node(playerNode)

func _physics_process(_delta: float) -> void:
	if player == null:
		return
	if falling:
		$birds.show()
		$birds.rotation_degrees += 5
		x = lerp(x, 1.0, .08)
		rotation = deg_to_rad(rad_to_deg(toRotby) + 180)
		velocity = Vector2(curve.sample(x) * 1000, 0).rotated(toRotby)
		move_and_slide()


	if imHit:
		return
	$birds.hide()

	look_at(player.global_position)


func punched(gunType: int, rot: float):
	toRotby = rot
	falling = true

	if !imHit:
		Manager.playSound("punched", global_position, -5.0)
		if gunType == 4:
			hit(300)
		imHit = true
		await get_tree().create_timer(2).timeout
		imHit = false

func die() -> void:
	Manager.decrementEnemyAmount()
	dead = true
	var deadBody = Sprite2D.new()
	deadBody.texture = deathTexture
	deadBody.global_position = position
	deadBody.rotation = rotation
	get_parent().add_child.call_deferred(deadBody)
	queue_free()
	
func finish() -> void:
	SignalBus.finishing.emit(global_position, self)

func hit(damage: int) -> void:
	health -= damage
	if health <= 0 and !dead:
		SignalBus.emit_signal("updateScore", 200)
		dead = true
		die()
