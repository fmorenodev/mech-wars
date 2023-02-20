extends HBoxContainer

signal row_button_pressed

func _on_TextureButton_pressed():
	emit_signal("row_button_pressed", self.name)
