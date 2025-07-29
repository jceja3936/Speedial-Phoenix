extends Control

var curve: Curve = load("res://assets/fbeatCurve.tres")
var oCurve: Curve = load("res://assets/lBeatCurve.tres")
var sCurve: Curve = load("res://assets/lBeatSkewCurve.tres")
var sCSC: Curve = load("res://assets/UpDownCurve.tres")

var mult = 1
var score = 0
var prevScore = 0
var tweener = 1.0
var oTweener = 1.0
var bsTweener = 1.0
var oBS = 1.0
var lb = false

func _ready():
	mult = 1
	multManager()
	updateMult()
	SignalBus.updateAmmo.connect(updateAmmo)
	SignalBus.updateResp.connect(updateResp)
	SignalBus.updateScore.connect(updateScore)
	SignalBus.saveScore.connect(saveScore)
	SignalBus.floorBeat.connect(playFFanim)
	SignalBus.levelBeat.connect(levelBeat)
	SignalBus.playCutscene.connect(cutScene)
	SignalBus.teleporting.connect(scutScene)
	$AmAm.hide()
	$resp.hide()
	if Manager.score != -1:
		score = Manager.score
		updateScore(0)

func scutScene():
	oBS = 0.0
	sbsFinisher()

func sbsFinisher():
	if $blackScreen:
		oBS += .1
		$blackScreen.material.set_shader_parameter("myOpaq", sCSC.sample(oBS))
		await get_tree().create_timer(.05).timeout
		if oBS < 1.0:
			sbsFinisher()

func cutScene():
	if bsTweener == 1.0:
		bsTweener = 0.0
		bsFinisher()

func bsFinisher():
	if $blackScreen:
		bsTweener += .05
		$blackScreen.material.set_shader_parameter("myOpaq", bsTweener)
		await get_tree().create_timer(.05).timeout
		if bsTweener < 1.0:
			bsFinisher()

	
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
		$FloorBeat.position = Vector2((4000.0 * curve.sample(tweener) - 907.0), 245.0)
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
	await get_tree().create_timer(1.25).timeout
	if score == prevScore or score == Manager.score:
		if mult > Manager.mult:
			Manager.mult = mult
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
	$Score.text = str(score).pad_zeros(4)


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
