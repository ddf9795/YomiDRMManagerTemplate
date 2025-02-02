extends Node
export var version = "v1.0.0"

onready var signin_layer = $"%SignInLayer"
onready var char_select_layer = $"%CharSelectLayer"
onready var add_layer = $"%AddLayer"
onready var edit_layer = $"%EditLayer"
onready var home_layer = $"%HomeLayer"
onready var credits_layer = $"%CreditsLayer"

onready var music = $"%Music"

var logged_in = false
var username
var password

var restricted = false

var error_tween

#const URL = "[INSERT YOUR API URL HERE]" # Make sure the url starts with an http/https and ends in a /
const URL = "http://127.0.0.1:8080/" # Use this for local server testing

func _ready():
	signin_layer.show()
	char_select_layer.hide()
	add_layer.hide()
	edit_layer.hide()
	home_layer.hide()
	credits_layer.hide()
	$"%Version".text = version

func send_login_http_request(username, password):
	restricted = true
	var params = 'login'
	var http_request = HTTPRequest.new()
	http_request.set_script(load("res://Request.gd"))
	http_request.timeout = 30
	http_request.connect("request_completed", self, "_on_login_request_completed")
	add_child(http_request)
	var headers = ["Content-Type: application/json"]
	http_request.request(URL + params, headers, true, HTTPClient.METHOD_POST, JSON.print({'user':username, 'pass':password}))
	message("Polling...")

func send_add_http_request(charname: String, steamid, nickname, options):
	restricted = true
	var params = 'add'
	var http_request = HTTPRequest.new()
	http_request.set_script(load("res://Request.gd"))
	http_request.timeout = 30
	http_request.connect("request_completed", self, "_on_add_request_completed")
	add_child(http_request)
	var headers = ["Content-Type: application/json"]
	http_request.request(URL + params, headers, true, HTTPClient.METHOD_POST, JSON.print({'char':charname, 'steamid':steamid, "nickname":nickname, "options":JSON.print(options), "security":JSON.print({"username": username, "password": password})}))
	message("Polling...")

func send_getall_http_request(charname: String):
	restricted = true
	var params = 'getAll/' + charname
	var http_request = HTTPRequest.new()
	http_request.set_script(load("res://Request.gd"))
	http_request.timeout = 30
	http_request.connect("request_completed", self, "_on_getall_request_completed")
	add_child(http_request)
	http_request.request(URL + params)
	message("Polling...")

func send_update_http_request(charname, steamid, obj_id, data):
	restricted = true
	var params = 'update'
	var http_request = HTTPRequest.new()
	http_request.set_script(load("res://Request.gd"))
	http_request.timeout = 30
	http_request.connect("request_completed", self, "_on_update_request_completed")
	add_child(http_request)
	var headers = ["Content-Type: application/json"]
	http_request.request(URL + params, headers, true, HTTPClient.METHOD_POST, JSON.print({'context':{'char':charname, 'steamid':steamid, "_id":obj_id}, 'data':data, "security":JSON.print({"username": username, "password": password})}))
	message("Polling...")
	
func send_delete_http_request(charname, obj_id):
	restricted = true
	var params = 'delete'
	var http_request = HTTPRequest.new()
	http_request.set_script(load("res://Request.gd"))
	http_request.timeout = 30
	http_request.connect("request_completed", self, "_on_delete_request_completed")
	add_child(http_request)
	var headers = ["Content-Type: application/json"]
	http_request.request(URL + params, headers, true, HTTPClient.METHOD_POST, JSON.print({'context':{'char':charname, "_id":obj_id}, "security":JSON.print({"username": username, "password": password})}))
	message("Polling...")
	
func error(message):
	$"%ErrorLabel".add_color_override("font_color", Color("ff0000"))
	if is_instance_valid(error_tween):
		error_tween.kill()
	error_tween = create_tween()
	$"%ErrorLabel".text = message
	$"%ErrorLabel".show()
	error_tween.tween_method(self, "set_error_visible", 1.0, 0.0, 5.0)

func message(message):
	$"%ErrorLabel".add_color_override("font_color", Color.white)
	if is_instance_valid(error_tween):
		error_tween.kill()
	error_tween = create_tween()
	$"%ErrorLabel".text = message
	$"%ErrorLabel".show()
	error_tween.tween_method(self, "set_error_visible", 1.0, 0.0, 5.0)

func success(message):
	$"%ErrorLabel".add_color_override("font_color", Color("00ff00"))
	if is_instance_valid(error_tween):
		error_tween.kill()
	error_tween = create_tween()
	$"%ErrorLabel".text = message
	$"%ErrorLabel".show()
	error_tween.tween_method(self, "set_error_visible", 1.0, 0.0, 5.0)

func set_error_visible(amount:float):
	if amount <= 0.001:
		$"%ErrorLabel".visible = false
		return 
	$"%ErrorLabel".visible = true

func _on_add_request_completed(result, response_code, headers, body):
	restricted = false
	match response_code:
		201:
			success("User added successfully!")
		_:
			var json = JSON.parse(body.get_string_from_utf8())
			error('Error ' + str(response_code) + ': ' + str(json.result.message))

func _on_getall_request_completed(result, response_code, headers, body):
	restricted = false
	var json = JSON.parse(body.get_string_from_utf8())
	var edit_array = json.result.users
	edit_layer.on_edit_array_populated(edit_array)
	message("Populated")

func _on_update_request_completed(result, response_code, headers, body):
	print(response_code)

func _on_login_request_completed(result, response_code, headers, body):
	restricted = false
	if str(response_code) == "200":
		success("Logged in successfully!")
		logged_in = true
		var json = JSON.parse(body.get_string_from_utf8())
		username = json.result.context.user
		password = json.result.context.pass
		signin_layer.hide()
		home_layer.show()
	else:
		var json = JSON.parse(body.get_string_from_utf8())
		error('Error ' + str(response_code) + ': ' + str(json.result.message))

func _on_MuteButton_toggled(button_pressed):
	music.playing = not button_pressed
	if button_pressed:
		$"%MuteButton".modulate = Color.red
	else:
		$"%MuteButton".modulate = Color.white
