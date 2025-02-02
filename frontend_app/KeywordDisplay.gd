extends HBoxContainer

func _on_DeleteButton_pressed():
	queue_free()

func set_keyword(keyword):
	$Label.text = keyword

func get_keyword():
	return $Label.text

func _process(delta):
	if $Label.text == "ex":
		$DeleteButton.disabled = true
