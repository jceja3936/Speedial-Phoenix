extends Control

var mult = 1
var score = 0
var prevScore = 0

func _ready():
	multManager()
	SignalBus.updateAmmo.connect(updateAmmo)
	SignalBus.updateResp.connect(updateResp)
	SignalBus.updateScore.connect(updateScore)
	SignalBus.saveScore.connect(saveScore)
	$AmAm.hide()
	$resp.hide()
	$fadeAway.modulate = Color(0, 0, 0, 0)
	if Manager.score != 0:
		score = Manager.score
		updateScore(0)


func updateAmmo(value):
	if value == -1:
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
	await get_tree().create_timer(.75).timeout
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
