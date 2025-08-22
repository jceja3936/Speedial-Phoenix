extends Control

var bsTweener = 0.0
var ogMenuMusic = 0.0

var tiers = [0, 0, 0, 0, 0]

func tweenAudio():
	if MenuMusic.musicSound < ogMenuMusic:
		MenuMusic.musicSound += 1
		MenuMusic.setMusicSound()
		await get_tree().create_timer(.05).timeout
		tweenAudio()


func _ready() -> void:
	ogMenuMusic = MenuMusic.musicSound
	MenuMusic.musicSound = -20.0
	MenuMusic.setMusicSound()
	MenuMusic.play()
	$Next.grab_focus()
	cutScene()
	tweenAudio()

	match Manager.current_scene:
		"1":
			tiers = [2500, 3000, 3500, 4000, 4500]
		"2":
			tiers = [4000, 6000, 8000, 10000, 12000]
		"3":
			tiers = [5000, 7000, 9000, 11000, 13000]
		"4":
			tiers = [16000, 18000, 20000, 23000, 25000]
		"5":
			tiers = [3500, 4000, 5000, 6000, 8000]
		"6":
			tiers = [8000, 10000, 12000, 14000, 16000]


	$Main/vert/wbroke/wNum.text = str(Manager.wallsBroke)
	var ogTime = Manager.timer
	var minutes = 0
	var seconds = 0

	while ogTime >= 60:
		ogTime -= 60
		minutes += 1
	seconds = ogTime
	$Main/vert/time/timeNum.text = str(minutes) + ":" + str(int(seconds)).pad_zeros(2)
	$Main/vert/Combo/combNum.text = str(Manager.mult)
	$Main/vert/Deaths/deathNum.text = str(Manager.deaths * -500)

	var theScore = Manager.score + (Manager.wallsBroke * 100) + (Manager.deaths * -500) + (Manager.mult * 500)

	var yourTier = 0

	for tier in tiers:
		if theScore >= tier:
			yourTier += 1

	match yourTier:
		0:
			$Results.text = "Results: Yikes"
		1:
			$Results.text = "Results: D rank"
		2:
			$Results.text = "Results: C rank"
		3:
			$Results.text = "Results: B rank"
		4:
			$Results.text = "Results: A rank"
		5:
			$Results.text = "Results: S rank"

	$Main/vert/score/scoreNum.text = str(theScore)

	if Manager.current_scene == "3" or Manager.current_scene == "6":
		$Next.disabled = true
	
	
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
	Manager.gamePaused = false
	Manager.timer = 0
	Manager.levelState = 1
	Manager.gunType = 0
	Manager.ammoCount = 0
	Manager.score = 0
	Manager.mult = 1
	Manager.enemyAmount = 0
	
	match Manager.current_scene:
		"-2":
			Manager.next_scene = "res://scenes/lvlScenes/Lvl4.tscn"
			Manager.current_scene = "4"
			Manager.playerRespawnPos = Vector2(1391.0, 1901.0)
			Manager.startNextScene()

		"tutorial":
			Manager.playerRespawnPos = Vector2(418.0, 145.0)
			Manager.current_scene = "1"
			Manager.next_scene = "res://scenes/lvlScenes/Lvl1.tscn"
			Manager.startNextScene()

		"1":
			Manager.playerRespawnPos = Vector2(271.0, 756.0)
			Manager.current_scene = "2"
			Manager.next_scene = "res://scenes/lvlScenes/Lvl2.tscn"
			Manager.startNextScene()
		"2":
			Manager.playerRespawnPos = Vector2(714.0, 136.0)
			Manager.current_scene = "3"
			Manager.next_scene = "res://scenes/lvlScenes/Lvl3.tscn"
			Manager.startNextScene()
		"4":
			Manager.playerRespawnPos = Vector2(287.0, 97.0)
			Manager.current_scene = "5"
			Manager.next_scene = "res://scenes/lvlScenes/Lvl5.tscn"
			Manager.startNextScene()
		"5":
			Manager.current_scene = "6"
			Manager.playerRespawnPos = Vector2(1828.0, 245.0)
			Manager.next_scene = "res://scenes/lvlScenes/Lvl6.tscn"
			Manager.startNextScene()
