extends Control

var curve: Curve = load("res://assets/fbeatCurve.tres")

var mult = 1
var score = 0
var prevScore = 0
var tweener = 4.0
var lb = false

func _ready():
	multManager()
	SignalBus.updateAmmo.connect(updateAmmo)
	SignalBus.updateResp.connect(updateResp)
	SignalBus.updateScore.connect(updateScore)
	SignalBus.saveScore.connect(saveScore)
	SignalBus.floorBeat.connect(playFFanim)
	SignalBus.levelBeat.connect(levelBeat)
	$AmAm.hide()
	$resp.hide()
	if Manager.score != 0:
		score = Manager.score
		updateScore(0)

func levelBeat():
	lb = false
	$AmAm.hide()
	$"Level Beat".show()


func playFFanim():
	if tweener == 4.0:
		tweener = 0.0
		finisher()

func finisher():
	if $FloorBeat:
		$FloorBeat.material.set_shader_parameter("dissolved", curve.sample(tweener))
		await get_tree().create_timer(.08).timeout
		tweener += .1
		if tweener < 4.0:
			finisher()


func updateAmmo(value):
	if value == -1 or lb == true:
		$AmAm.hide()
	else:
		$AmAm.show()
	$AmAm.text = "Ammo: " + str(value)

func updateResp(value):
	match value:
		true:
			$resp.show()
		false:
			$resp.hide()

func multManager():
	prevScore = score
	await get_tree().create_timer(1.5).timeout
	if score == prevScore:
		mult = 1
		updateMult()
	multManager()

func updateMult():
	$mult.text = str(mult)

func updateScore(value):
	makePretty()
	score += value * mult
	mult += 1
	updateMult()
	if score < 1000:
		$Score.text = "Score : 0"
	else:
		$Score.text = "Score : "
	$Score.text = $Score.text + str(score)


func makePretty():
	$Score.modulate = Color(255, 255, 0, 255)
	await get_tree().create_timer(.05).timeout
	$Score.modulate = Color(255, 255, 255, 255)
	await get_tree().create_timer(.1).timeout
	$Score.modulate = Color(255, 255, 0, 255)
	await get_tree().create_timer(.05).timeout
	$Score.modulate = Color(255, 255, 255, 255)

func saveScore():
	Manager.score = score
