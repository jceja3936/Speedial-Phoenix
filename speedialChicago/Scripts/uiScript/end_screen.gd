extends Control


func _ready() -> void:
    $scoreNum.text = str(Manager.score)
    $timeNum.text = str(Manager.timer).pad_decimals(2)


func _on_exit_pressed() -> void:
    get_tree().quit()

func _on_next_pressed() -> void:
    if Manager.current_scene == "1_1":
        Manager.next_scene = "res://scenes/lvlScenes/Lvl1.tscn"
        Manager.gamePaused = false
        Manager.current_scene = "2"
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
