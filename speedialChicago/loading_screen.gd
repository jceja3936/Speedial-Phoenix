extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ResourceLoader.load_threaded_request(Manager.next_scene)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var progress = []
	ResourceLoader.load_threaded_get_status(Manager.next_scene, progress)
	$percent.text = str(progress[0] * 100) + "%"

	if progress[0] == 1:
		var packed_scene = ResourceLoader.load_threaded_get(Manager.next_scene)
		get_tree().change_scene_to_packed(packed_scene)