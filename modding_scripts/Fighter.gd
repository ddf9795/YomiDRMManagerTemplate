extends Node

# Copy these methods AS APPROPRIATE to your character's fighter script.
# !!! DO NOT COPY THIS SCRIPT INTO YOUR FILES DIRECTLY !!!

func GetDRM(id):
#	print("getting DRM")
	var file = File.new()
	file.open("user://charnamecache.json", File.READ) # Replace charname with your character's name
	var string = file.get_as_text()
	var data = parse_json(string)
	if Network.multiplayer_active and not SteamLobby.SPECTATING and Network.network_ids[2] != null:
		return data.get(str(Network.network_ids[id]))
	if ReplayManager.frames.get("net_info"):
#		print("net_info is here")
		return ReplayManager.frames["net_info"].get(id)
	if ReplayManager.frames.get("network_ids"):
		var our_id = ReplayManager.frames["network_ids"][id - 1]
#		print("we are, in fact reading off of network_ids")
#		print(our_id)
#		print(data)
		return data.get(our_id)
	if not ReplayManager.frames.get("network_ids") and SteamHustle.STARTED:
		if not Network.multiplayer_active:
			if id == 1:
				return data.get(str(SteamHustle.STEAM_ID))
		return ["network_ids is not found!"]

func apply_style(style):
	if ( not SteamHustle.STARTED) or Global.steam_demo_version:
		return 
	if style != null and not is_ghost:
		ivy_effect = is_ivy() and style.style_name == "ivy"
		is_color_active = true
		is_style_active = true
		applied_style = style
		if Global.enable_custom_colors:
			var e1 = style.get("extra_color_1")
			var e2 = style.get("extra_color_2")
			if e1 == null:
				use_extra_color_1 = false
			if e2 == null:
				use_extra_color_2 = false
			
			set_color(style.get("character_color"), e1, e2)
			Custom.apply_style_to_material(style, sprite.get_material())
			sprite.get_material().set_shader_param("extra_replace_color_1", extra_color_1)
			sprite.get_material().set_shader_param("extra_replace_color_2", extra_color_2)
			sprite.get_material().set_shader_param("use_extra_color_1", use_extra_color_1)
			sprite.get_material().set_shader_param("use_extra_color_2", use_extra_color_2)

		else :
			sprite.get_material().set_shader_param("use_extra_color_1", false)
			sprite.get_material().set_shader_param("use_extra_color_2", false)
	
		if Global.enable_custom_particles and not is_ghost and style.get("show_aura") and style.has("aura_settings"):
			reset_aura()
			is_aura_active = true
			aura_particle = preload("res://fx/CustomTrailParticle.tscn").instance()
			particles.add_child(aura_particle)
			aura_particle.load_settings(style.get("aura_settings"))
			aura_particle.position = hurtbox_pos_float()
			aura_particle.start_emitting()
			if aura_particle.show_behind_parent:
				aura_particle.z_index = - 1
		if style.has("hitspark"):
			custom_hitspark = load(Custom.hitsparks[style.get("hitspark")])
			for hitbox in hitboxes:
				hitbox.HIT_PARTICLE = custom_hitspark
	
	var style_name
	
	if style != null:
		style_name = style.get("style_name")

	var check = GetDRM(id)
	
	if check != null:
		if check.has("ex"):
			pass # Do your skin checks here
