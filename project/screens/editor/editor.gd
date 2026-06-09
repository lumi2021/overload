extends Control


func _ready() -> void:
	if (len(ThemeServer.themes) < 9):
		print("TODO fix theme implementation. No theme selected")
		return
		
	var theme_info = ThemeServer.themes[9]
	print("loading theme " + theme_info.name)
	theme = theme_info.theme
