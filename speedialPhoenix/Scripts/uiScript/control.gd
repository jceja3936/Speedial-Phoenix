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
		prevScore = score
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

var happenOnceInator = false
var happendCount = 0
func levelBeat():
	if oTweener >= 1.0:
		oTweener = 0.0
		beatPretty()
	if !happenOnceInator:
		playAnim()
		happenOnceInator = true
	lb = true
	$AmAm.hide()
	$Path2D/PathFollow2D/funTxt.show()

func playAnim():
	$Path2D/PathFollow2D/funTxt.play()
	
func _on_fun_txt_animation_finished() -> void:
	if happendCount <= 3:
		happendCount += 1
		playAnim()

func beatPretty():
	$Path2D/PathFollow2D.progress_ratio = oTweener
	$Path2D/PathFollow2D/funTxt.skew = deg_to_rad(sCurve.sample(oTweener))
	$Path2D/PathFollow2D/funTxt.scale = Vector2(1.0 + oCurve.sample(oTweener), 1.0 + oCurve.sample(oTweener))
	await get_tree().create_timer(.02).timeout
	oTweener += .008
	if oTweener < 1.0:
		beatPretty()


func playFFanim():
	wait()
	if tweener == 1.0:
		tweener = 0.0
		finisher()

func wait():
	await get_tree().create_timer(10).timeout
	tweener = 1.0

func finisher():
	if $FloorBeat:
		$FloorBeat.position = Vector2((4100.0 * curve.sample(tweener) - 1000.0), 245.0)
		await get_tree().create_timer(.01).timeout
		tweener += .005
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
	if score == prevScore:
		if mult > Manager.mult:
			Manager.mult = mult
		mult = 1
		comboDirection = true
		slideComboAway()
		updateMult()
		

	multManager()

var comboDirection = true

func updateMult():
	if mult > 1:
		comboDirection = false
		slideComboto()

	$ComboCont/mult.text = str(mult)

func slideComboto():
	$ComboCont.position.x = lerp($ComboCont.position.x, 1766.0, .05)
	if $ComboCont.position.x > 1780.0 and !comboDirection:
		await get_tree().create_timer(.02).timeout
		slideComboto()

func slideComboAway():
	$ComboCont.position.x = lerp($ComboCont.position.x, 2127.0, .05)
	if $ComboCont.position.x <= 2120.0 and comboDirection:
		await get_tree().create_timer(.02).timeout
		slideComboAway()
		

func updateScore(value):
	makePretty()
	score += value * mult
	if value != 0:
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
