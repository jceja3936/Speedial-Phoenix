extends Control

var curve: Curve = load("res://assets/fbeatCurve.tres")
var oCurve: Curve = load("res://assets/lBeatCurve.tres")
var sCurve: Curve = load("res://assets/lBeatSkewCurve.tres")

var mult = 1
var score = 0
var prevScore = 0
var tweener = 1.0
var oTweener = 1.0
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
	if oTweener >= 1.0:
		oTweener = 0.0
		beatPretty()
		
	lb = true
	$AmAm.hide()
	$Path2D/PathFollow2D/funTxt.show()

func beatPretty():
	$Path2D/PathFollow2D.progress_ratio = oTweener
	$Path2D/PathFollow2D/funTxt.skew = deg_to_rad(sCurve.sample(oTweener))
	$Path2D/PathFollow2D/funTxt.scale = Vector2(1.0 + oCurve.sample(oTweener), 1.0 + oCurve.sample(oTweener))
	await get_tree().create_timer(.05).timeout
	oTweener += .02
	if oTweener < 1.0:
		beatPretty()

func playFFanim():
	if tweener == 1.0:
		tweener = 0.0
		finisher()

func finisher():
	if $FloorBeat:
		$FloorBeat.position = Vector2((4000.0 * curve.sample(tweener) - 907.0), 542.0)
		await get_tree().create_timer(.05).timeout
		tweener += .02
		if tweener < 1.0:
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
