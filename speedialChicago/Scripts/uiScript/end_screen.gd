extends Control

var bsTweener = 0.0

func _ready() -> void:
	var theScore = Manager.score + (Manager.wallsBroke * 100)
	if theScore > 50000:
		theScore = 50000
	cutScene()
	$vert/score/scoreNum.text = str(theScore)
	$vert/wbroke/wNum.text = str(Manager.wallsBroke)
	$vert/time/timeNum.text = str(Manager.timer).pad_decimals(2)


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
