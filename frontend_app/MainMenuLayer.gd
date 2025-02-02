extends CanvasLayer

func _on_AddButton_pressed():
	$"%HomeLayer".hide()
	$"%CharSelectLayer".show()
	$"%CharSelectLayer".mode = "add"

func _on_EditButton_pressed():
	$"%HomeLayer".hide()
	$"%CharSelectLayer".show()
	$"%CharSelectLayer".mode = "edit"

func _on_SignOutButton_pressed():
	$"%SignInLayer".username_field.text = ""
	$"%SignInLayer".password_field.text = ""
	$"%HomeLayer".hide()
	$"%SignInLayer".show()
	get_parent().logged_in = false
	get_parent().username = ""
	get_parent().password = ""

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_CreditsButton_pressed():
	$"%HomeLayer".hide()
	$"%CreditsLayer".show()
