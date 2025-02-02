extends Node

# Place this script, as well as DRMManager.tscn, in the root of your character files.

const URL = "[WEB API LINK]" # Make sure the url starts with an http/https and ends in a /
var data = {}

func _ready():
	SteamLobby.connect("received_spectator_match_data", self, "steamID_spectate_hook")
	var file = File.new()
	if file.file_exists("user://charnamecache.json"): # Replace charname with your character's name
		var dir = Directory.new()
		dir.remove("user://charnamecache.json") # Replace charname with your character's name
	file.open("user://charnamecache.json", File.WRITE) # Replace charname with your character's name
	file.store_string(JSON.print("  "))
	file.close()
	file.open("user://charnamecache.json", File.READ) # Replace charname with your character's name
	var string = file.get_as_text()
	var one_more_check = parse_json(string)
	if one_more_check is Dictionary:
		data = one_more_check

func send_http_request(charname: String, steamid):
	var http_request = HTTPRequest.new()
	http_request.set_script(load("res://CharFolder/Request.gd")) # Replace CharFolder with the root folder of your character
	http_request.timeout = 30
	http_request.connect("request_completed", self, "_on_request_completed")
	add_child(http_request)
	if steamid is String:
		var params = charname + '/' + steamid
		http_request.request(URL + params)
	else:
		var params = charname + '/' + str(steamid)
		http_request.request(URL + params)

func _on_request_completed(result, response_code, headers, body):
	if result != null:
		var json = JSON.parse(body.get_string_from_utf8())
#		print(json.result)
		var file = File.new()
		file.open("user://charnamecache.json", File.WRITE) # Replace charname with your character's name
		data[json.result["received"]["steamid"]] = json.result["access"]
		#file.store_string(JSON.print(json.result.access, "  "))
		file.store_string(JSON.print(data, "  "))
		file.close()
	
	

func get_data(steam):
	var file = File.new()
	file.open("user://charnamecache.json", File.READ) # Replace charname with your character's name
	var string = file.get_as_text()
	var data = parse_json(string)
	
	return data.get(steam)

func save_data_replay(data):
	var DRMdict = {"net_info":{}}
	if ReplayManager.frames.get("network_ids") and not ReplayManager.frames.get("net_info"):
		for player in ReplayManager.frames["network_ids"]:
			var what = ReplayManager.frames["network_ids"].find(player) + 1
#			print(player)
#			print(what)
			if what != -1 and get_charname(what, data) == "CharName": # Replace CharName with the name of your character's scene
				DRMdict["net_info"][what] = get_data(player)
		ReplayManager.frames.merge(DRMdict, false)
		

func get_charname(id: int, data):
	var cname = data.selected_characters[id]["name"]
	var filter = cname.rfind("__") 

	if filter != -1:
		filter += 2
		cname = cname.right(filter)
	return cname

func _process(delta):
	if is_instance_valid(Global.current_game) and not ReplayManager.frames.get("network_ids") and not SteamLobby.SPECTATING:
		id_setup(Global.current_game.match_data.get("singleplayer"), Global.current_game.match_data)
		if not ReplayManager.frames.get("net_info"):
			save_data_replay(Global.current_game.match_data)
#		print(str(Global.current_game.match_data))

func id_setup(singleplayer, data):
	var AlchemistV3_found
#	print("DRM is setting up ids")
#	print(str(singleplayer))
#	print(str(data.selected_characters))
	for charname in data.selected_characters:
		var cname = data.selected_characters[charname]["name"]
		var filter = cname.rfind("__") 

		if filter != -1:
			filter += 2
			cname = cname.right(filter)
		if cname == "CharName": # Replace CharName with the name of your character's scene
			AlchemistV3_found = true
	if AlchemistV3_found == true:
		if not ReplayManager.frames.get("network_ids") and singleplayer == true:
			#var overwrites = {"network_ids":[str(SteamHustle.STEAM_ID), null]}
			#ReplayManager.frames.merge(overwrites, true)
			ReplayManager.frames["network_ids"] = [str(SteamHustle.STEAM_ID), str(0)]
			#print("singleplayer setted")
		elif not ReplayManager.frames.get("network_ids") and Network.steam == true:
			ReplayManager.frames["network_ids"] = [str(Network.network_ids[1]), str(Network.network_ids[2])]
			for player in Network.network_ids:
				if not Network.network_ids.get(player) == SteamHustle.STEAM_ID and get_charname(player, data) == "AlchemistV3":
					send_http_request("CharName", Network.network_ids[player]) # Replace CharName with the name of your character's scene

func steamID_spectate_hook(data):
	var spec = SteamLobby.SPECTATING_ID
	var spec_lobby = SteamLobby.get_lobby_member(spec)
	var spec_name = spec_lobby.steam_name
	
	var opp = spec_lobby.opponent_id
	var opp_lobby = SteamLobby.get_lobby_member(opp).steam_name
	
	var player1 = spec
	var player2 = opp
	
	if spec_name != data.user_data.p1:
		spec = player2
	if opp_lobby != data.user_data.p2:
		opp = player1
	
	if not ReplayManager.frames.get("network_ids"):
		ReplayManager.frames["network_ids"] = [str(player1), str(player2)]
	if ReplayManager.frames.get("network_ids"):
		for player in ReplayManager.frames["network_ids"]:
			var what = ReplayManager.frames["network_ids"].find(player) + 1
#			print(player)
#			print(what)
			if what != 0 and get_charname(what, data) == "CharName": # Replace CharName with the name of your character's scene
				send_http_request("CharName", player) # Replace CharName with the name of your character's scene
#				print("we sent: " + player)
