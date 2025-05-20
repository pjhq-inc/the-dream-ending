extends Living


func _process(delta: float) -> void:
	$Sprite3D/SubViewport/Control/ProgressBar.value = health
