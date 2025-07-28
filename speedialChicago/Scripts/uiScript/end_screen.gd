extends Control

var bsTweener = 0.0

func _ready() -> void:
	cutScene()
	$Main/vert/wbroke/wNum.text = str(Manager.wallsBroke)
	var ogTime = Manager.timer
	var minutes = 0
	var seconds = 0

	while ogTime >= 60:
		ogTime -= 60
		minutes += 1
	seconds = ogTime
	$Main/vert/time/timeNum.text = str(minutes) + ":" + str(int(seconds))
	$Main/vert/Combo/combNum.text = str(Manager.mult)
	$Main/vert/Deaths/deathNum.text = str(Manager.deaths * -100)

	var theScore = Manager.score + (Manager.wallsBroke * 100) + (Manager.deaths * -100)
	if theScore > 50000:
		theScore = 50000
	$Main/vert/score/scoreNum.text = str(theScore)
	
	
func cutScene():
	if bsTweener == 0.0:
		bsTweener = 1.0
		bsFinisher()

func bsFinisher():
	if $blackScreen:
		bsTweener -= .05
		$blackScreen.material.set_shader_parameter("myOpaq", bsTweener)
		await get_tree().create_timer(.05).timeout
		if bsTweener > 0.0:
			bsFinisher()


func _on_exit_pressed() -> void:
	Manager.next_scene = "res://scenes/UIscenes/start_menu.tscn"
	Manager.startNextScene()

func _on_next_pressed() -> void:
	match Manager.current_scene:
		"1_1":
			Manager.gamePaused = false
			Manager.timer = 0
			Manager.levelState = 1
			Manager.gunType = 0
			Manager.ammoCount = 0
			Manager.score = 0
			Manager.mult = 1
			Manager.enemyAmount = 0
			Manager.playerRespawnPos = Vector2.ZERO

			Manager.current_scene = "2"
			Manager.next_scene = "res://scenes/lvlScenes/Lvl2.tscn"
			Manager.startNextScene()
		"2":
			Manager.gamePaused = false
			Manager.timer = 0
			Manager.levelState = 1
			Manager.gunType = 0
			Manager.ammoCount = 0
			Manager.score = 0
			Manager.mult = 1
			Manager.enemyAmount = 0
			Manager.playerRespawnPos = Vector2.ZERO

			Manager.current_scene = "3"
			Manager.next_scene = "res://scenes/lvlScenes/Lvl3.tscn"
			Manager.startNextScene()
