extends PanelContainer

export var charname = "" # Set this in the inspector

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
	$VBoxContainer/Submit.connect("pressed", self, "on_submit")
	$VBoxContainer/SteamID/SteamIDField.connect("text_changed", self, "_on_LineEdit_text_changed")

func setup():
	$VBoxContainer/Nickname/NicknameField.text = ""
	$VBoxContainer/SteamID/SteamIDField.text = ""

func _process(delta):
	$VBoxContainer/Submit.disabled = get_parent().get_parent().get_parent().restricted

func on_submit():
	if $VBoxContainer/Nickname/NicknameField.text.length() == 0:
		get_parent().get_parent().get_parent().error("Please provide a nickname.")
		return
	if $VBoxContainer/SteamID/SteamIDField.text.length() == 0:
		get_parent().get_parent().get_parent().error("Please provide a Steam ID.")
		return
	get_parent().get_parent().get_parent().send_add_http_request(charname, $VBoxContainer/SteamID/SteamIDField.text, $VBoxContainer/Nickname/NicknameField.text, ['ex'])
