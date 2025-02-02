extends HTTPRequest

# Place this script in the root of your character files.

var timer_start = false
var timer = 0

func _ready():
	connect("request_completed", self, "on_request_completed")

func _process(delta):
	timer += delta
	if timer >= 1 and timer_start:
		queue_free()

func on_request_completed(result, response_code, headers, body):
	timer_start = true
