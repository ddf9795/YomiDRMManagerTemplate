extends CanvasLayer

var selected_char
var selected_index = 0
var obj_id
var data

var refresh_timer = 0

onready var NumberLineEdit = $VBoxContainer/SteamID/SteamIDField
onready var LineEditRegEx = RegEx.new()
var old_text = ""

func _on_LineEdit_text_changed(new_text):
	if LineEditRegEx.search(new_text):
		old_text = str(new_text)
	else:
		NumberLineEdit.text = old_text
		NumberLineEdit.set_cursor_position(NumberLineEdit.text.length())

func _ready():
	LineEditRegEx.compile("^[0-9.]*$")
	$Panel/VBoxContainer/SteamID/SteamIDField.connect("text_changed", self, "_on_LineEdit_text_changed")

func _process(delta):
	$Panel/VBoxContainer/HBoxContainer/Button.disabled = get_parent().restricted
	$Panel/VBoxContainer/HBoxContainer/DeleteButton.disabled = get_parent().restricted
	if refresh_timer > 0:
		refresh_timer -= delta
		if refresh_timer <= 0:
			get_parent().send_getall_http_request(selected_char)

func on_edit_array_populated(edit_array):
	$Panel/VBoxContainer/Nickname/NicknameField.text = ""
	$Panel/VBoxContainer/SteamID/SteamIDField.text = ""
	for item in $"%KeywordsList".get_children():
		item.queue_free()
	selected_index = -1
	obj_id = -1
	data = edit_array
	$ItemList.clear()
	for data in edit_array:
		var nickname = "no nickname"
		if data.has("nickname"):
			if not data.nickname == "":
				nickname = data.nickname
		$ItemList.add_item(nickname + ' (' + str(data.steamid) + ')')

func _on_BackButton_pressed():
	$"%EditLayer".hide()
	$"%HomeLayer".show()

func _on_ItemList_item_selected(index):
	if $ItemList.is_item_disabled(index): return
	selected_index = 0
	obj_id = str(data[index]._id)
	for item in $"%KeywordsList".get_children():
		item.queue_free()
	if data[index].get('nickname') != null:
		$Panel/VBoxContainer/Nickname/NicknameField.text = data[index].get('nickname')
	else: 
		$Panel/VBoxContainer/Nickname/NicknameField.text = ""
	$Panel/VBoxContainer/SteamID/SteamIDField.text = str(data[index].steamid)
	for key in data[index].access:
		var item = preload("res://KeywordDisplay.tscn").instance()
		item.set_keyword(key)
		$"%KeywordsList".add_child(item)

func _on_AddButton_pressed():
	var item = preload("res://KeywordDisplay.tscn").instance()
	item.set_keyword($Panel/VBoxContainer/Access/KeywordAdd/LineEdit.text)
	$"%KeywordsList".add_child(item)
	$Panel/VBoxContainer/Access/KeywordAdd/LineEdit.text = ''

func _on_Button_pressed():
	if $Panel/VBoxContainer/Nickname/NicknameField.text.length() == 0:
		get_parent().error("Please provide a nickname.")
		return
	if $Panel/VBoxContainer/SteamID/SteamIDField.text.length() == 0:
		get_parent().error("Please provide a Steam ID.")
		return
	var keys = []
	for key in $"%KeywordsList".get_children():
		keys.push_back(key.get_keyword())
	var data = {
		"nickname":$Panel/VBoxContainer/Nickname/NicknameField.text,
		"steamid":$Panel/VBoxContainer/SteamID/SteamIDField.text,
		"access":keys,
	}
	get_parent().send_update_http_request(selected_char, $Panel/VBoxContainer/SteamID/SteamIDField.text, obj_id, JSON.print(data))
	refresh_timer = 1
	get_parent().message("Refreshing...")

func _on_DeleteButton_pressed():
	get_parent().send_delete_http_request(selected_char, obj_id)
	refresh_timer = 1
	get_parent().message("Refreshing...")

func _on_SearchField_text_changed(new_text):
	new_text = new_text.to_lower()
	if new_text.length() == 0:
		for i in $ItemList.get_item_count():
			$ItemList.set_item_disabled(i, false)
	else:
		for i in $ItemList.get_item_count():
			var trimmed = $ItemList.get_item_text(i).to_lower().split(' (')
			$ItemList.set_item_disabled(i, not new_text in trimmed[0])
