extends "res://main.gd"

# Place this script in the root of your character files.

var authorname_charname_drm_manager

var authorname_charname_skin_features = []

func _ready():
	setupDRMNode_CharName()
	authorname_charname_drm_manager.send_http_request('CharName', SteamHustle.STEAM_ID) # Replace CharName with the name of your character
	
func setupDRMNode_Charname():
	if get_tree().get_current_scene().get_node_or_null("CharNameDRMManager") != null: # Replace with the name of your DRM Manager scene 
		authorname_charname_drm_manager = get_tree().get_current_scene().get_node("CharNameDRMManager") # Replace with the name of your DRM Manager scene 
	else:
		authorname_charname_drm_manager = Node.new()
		authorname_charname_drm_manager = preload("res://CharFolder/DRMManager.tscn").instance() # Replace CharFolder with the root folder of your character
		add_child(authorname_charname_drm_manager)
