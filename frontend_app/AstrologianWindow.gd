extends "res://CharWindow.gd"

func on_submit():
	if $VBoxContainer/Nickname/NicknameField.text.length() == 0:
		get_parent().get_parent().get_parent().error("Please provide a nickname.")
		return
	if $VBoxContainer/SteamID/SteamIDField.text.length() == 0:
		get_parent().get_parent().get_parent().error("Please provide a Steam ID.")
		return
	var access_array = ['ex']
	for option in $VBoxContainer/Access/AccessList.get_selected_items():
		access_array.push_back($VBoxContainer/Access/AccessList.get_item_text(option))
	get_parent().get_parent().get_parent().send_add_http_request(charname, $VBoxContainer/SteamID/SteamIDField.text, $VBoxContainer/Nickname/NicknameField.text, access_array)

func setup():
	.setup()
	$VBoxContainer/Access/AccessList.unselect_all()

func _on_AccessList_nothing_selected():
	$VBoxContainer/Access/AccessList.unselect_all()
