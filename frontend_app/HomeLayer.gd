extends CanvasLayer

onready var character_list = $"%CharacterList"
onready var character_select_button = $"%CharacterSelectButton"

var mode = "add"

func _on_CharacterSelectButton_pressed():
	if not character_list.is_anything_selected():
		get_parent().error("No character selected!")
		return
	match mode:
		"add":
			$"%CharSelectLayer".hide()
			$"%AddLayer".show()
			$"%CharNameLabel".text = character_list.get_item_text(character_list.get_selected_items()[0])
			for window in $"%AddLayerContainer".get_children():
				if not window is PanelContainer: continue
				window.setup()
				window.visible = character_list.get_item_text(character_list.get_selected_items()[0]) == window.charname
		"edit":
			$"%CharSelectLayer".hide()
			$"%EditLayer".show()
			$"%EditCharNameLabel".text = character_list.get_item_text(character_list.get_selected_items()[0])
			$"%EditLayer".selected_char = character_list.get_item_text(character_list.get_selected_items()[0])
			get_parent().send_getall_http_request(character_list.get_item_text(character_list.get_selected_items()[0]))

func _on_BackButton_pressed():
	$"%HomeLayer".show()
	$"%CharSelectLayer".hide()
