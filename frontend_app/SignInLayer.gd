extends CanvasLayer

onready var username_field = $VBoxContainer/Username/UsernameField
onready var password_field = $VBoxContainer/Password/PasswordField
onready var sign_in_button = $VBoxContainer/SignInButton

func _input(event):
	if Input.is_key_pressed(KEY_ENTER) and visible:
		_on_SignInButton_pressed()

func _process(delta):
	sign_in_button.disabled = get_parent().restricted

func _on_SignInButton_pressed():
	if username_field.text.length() == 0 or password_field.text.length() == 0:
		get_parent().error("Missing username and/or password!")
		return
	get_parent().send_login_http_request(username_field.text, password_field.text)
	
