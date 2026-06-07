extends Node

var themes: Array = []

func _ready() -> void:
	var t = _get_all_kde_system_themes()
	var f = _get_kde_fonts()
	
	for i in t:
		var data = t[i]
		themes.append({
			"name": i,
			"dark_mode": data.dark_mode,
			"theme": create_godot_theme(data, f)
		})


func _get_all_kde_system_themes() -> Dictionary:
	var themes_data = {}
	var paths = ["/usr/share/color-schemes/", OS.get_environment("HOME") + "/.local/share/color-schemes/"]
	
	for path in paths:
		if not DirAccess.dir_exists_absolute(path): continue
		
		var dir = DirAccess.open(path)
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".colors"):
				var full_path = path + file_name
				var theme_data = _extract_full_theme_data(full_path)
				themes_data[file_name.get_basename()] = theme_data
			file_name = dir.get_next()
			
	return themes_data
func _extract_full_theme_data(file_path: String) -> Dictionary:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file: return {}

	var data = {
		# Metadata
		"name": "",
		"color_scheme": "",
		"dark_mode": false,
		"contrast": 4,

		# Window
		"window_bg":              Color.BLACK,
		"window_fg":              Color.WHITE,
		"window_fg_inactive":     Color.GRAY,
		"window_fg_link":         Color.BLUE,

		# Button
		"button_bg":              Color.DARK_GRAY,
		"button_fg":              Color.WHITE,

		# Selection / Accent
		"accent":                 Color.BLUE,
		"accent_fg":              Color.WHITE,

		# View (listas, árvores, editores)
		"view_bg":                Color.BLACK,
		"view_fg":                Color.WHITE,
		"view_fg_inactive":       Color.GRAY,
		"view_fg_link":           Color.BLUE,
		"view_fg_negative":       Color.RED,
		"view_fg_positive":       Color(0.2, 0.8, 0.2),

		# Tooltip
		"tooltip_bg":             Color(0.1, 0.1, 0.1),
		"tooltip_fg":             Color.WHITE,

		# Complementary (sidebars, headers alternativos)
		"complementary_bg":       Color(0.15, 0.15, 0.15),
		"complementary_fg":       Color.WHITE,
		"complementary_accent":   Color.BLUE,

		# Header (KDE 5.23+)
		"header_bg":              Color(0.1, 0.1, 0.1),
		"header_fg":              Color.WHITE,
		"header_accent":          Color.BLUE,

		# Window Manager (bordas de janela)
		"wm_active_bg":           Color(0.2, 0.2, 0.2),
		"wm_active_fg":           Color.WHITE,
		"wm_inactive_bg":         Color(0.15, 0.15, 0.15),
		"wm_inactive_fg":         Color.GRAY,
		"wm_active_blend":        Color(0.2, 0.2, 0.2),
	}

	var current_section = ""

	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line.is_empty() or line.begins_with(";"): continue

		if line.begins_with("[") and line.ends_with("]"):
			current_section = line
			continue

		if "=" not in line: continue
		var eq = line.find("=")
		var key = line.left(eq).strip_edges()
		var value = line.substr(eq + 1).strip_edges()

		match current_section:
			"[General]":
				if key == "Name":        data.name = value
				if key == "ColorScheme": data.color_scheme = value

			"[KDE]":
				if key == "contrast":    data.contrast = int(value)

			"[Colors:Window]":
				if key == "BackgroundNormal":   data.window_bg = _parse_kde_rgb(value)
				if key == "ForegroundNormal":   data.window_fg = _parse_kde_rgb(value)
				if key == "ForegroundInactive": data.window_fg_inactive = _parse_kde_rgb(value)
				if key == "ForegroundLink":     data.window_fg_link = _parse_kde_rgb(value)

			"[Colors:Button]":
				if key == "BackgroundNormal": data.button_bg = _parse_kde_rgb(value)
				if key == "ForegroundNormal": data.button_fg = _parse_kde_rgb(value)

			"[Colors:Selection]":
				if key == "BackgroundNormal": data.accent    = _parse_kde_rgb(value)
				if key == "ForegroundNormal": data.accent_fg = _parse_kde_rgb(value)

			"[Colors:View]":
				if key == "BackgroundNormal":    data.view_bg          = _parse_kde_rgb(value)
				if key == "ForegroundNormal":    data.view_fg          = _parse_kde_rgb(value)
				if key == "ForegroundInactive":  data.view_fg_inactive = _parse_kde_rgb(value)
				if key == "ForegroundLink":      data.view_fg_link     = _parse_kde_rgb(value)
				if key == "ForegroundNegative":  data.view_fg_negative = _parse_kde_rgb(value)
				if key == "ForegroundPositive":  data.view_fg_positive = _parse_kde_rgb(value)

			"[Colors:Tooltip]":
				if key == "BackgroundNormal": data.tooltip_bg = _parse_kde_rgb(value)
				if key == "ForegroundNormal": data.tooltip_fg = _parse_kde_rgb(value)

			"[Colors:Complementary]":
				if key == "BackgroundNormal": data.complementary_bg     = _parse_kde_rgb(value)
				if key == "ForegroundNormal": data.complementary_fg     = _parse_kde_rgb(value)
				if key == "BackgroundAlternate": data.complementary_accent = _parse_kde_rgb(value)

			"[Colors:Header]":
				if key == "BackgroundNormal": data.header_bg    = _parse_kde_rgb(value)
				if key == "ForegroundNormal": data.header_fg    = _parse_kde_rgb(value)
				if key == "DecorationFocus":  data.header_accent = _parse_kde_rgb(value)

			"[WM]":
				if key == "activeBackground":   data.wm_active_bg   = _parse_kde_rgb(value)
				if key == "activeForeground":   data.wm_active_fg   = _parse_kde_rgb(value)
				if key == "inactiveBackground": data.wm_inactive_bg = _parse_kde_rgb(value)
				if key == "inactiveForeground": data.wm_inactive_fg = _parse_kde_rgb(value)
				if key == "activeBlend":        data.wm_active_blend = _parse_kde_rgb(value)
		
		var bg = data.get("window_bg", Color(0.2, 0.2, 0.2))
		var luminance = 0.2126 * bg.r + 0.7152 * bg.g + 0.0722 * bg.b
		data.dark_mode = luminance < 0.5

	return data
func _parse_kde_rgb(rgb_str: String) -> Color:
	var components = rgb_str.split(",")
	if components.size() >= 3:
		return Color(
			float(components[0]) / 255.0, 
			float(components[1]) / 255.0, 
			float(components[2]) / 255.0
		)
	return Color.WHITE

func _get_kde_fonts() -> Dictionary:
	var fonts = {
		"general":      "",
		"monospace":    "",
		"small":        "",
		"toolbar":      "",
		"menu":         "",
		"window_title": ""
	}

	var path = OS.get_environment("HOME") + "/.config/kdeglobals"
	var file = FileAccess.open(path, FileAccess.READ)
	if not file: return fonts

	var in_general = false
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line == "[General]":
			in_general = true
			continue
		if line.begins_with("["):
			in_general = false
			continue
		if not in_general or "=" not in line: continue

		var eq = line.find("=")
		var key = line.left(eq).strip_edges()
		var value = line.substr(eq + 1).strip_edges()

		match key:
			"font":                 fonts.general      = _parse_kde_font(value)
			"fixed":                fonts.monospace    = _parse_kde_font(value)
			"smallestReadableFont": fonts.small        = _parse_kde_font(value)
			"toolBarFont":          fonts.toolbar      = _parse_kde_font(value)
			"menuFont":             fonts.menu         = _parse_kde_font(value)
			"activeFont":           fonts.window_title = _parse_kde_font(value)

	return fonts

func _parse_kde_font(font_str: String) -> String:
	var parts = font_str.split(",")
	if parts.size() >= 2:
		return parts[0].strip_edges() + "," + parts[1].strip_edges()
	return font_str
func _find_font_file(family: String) -> String:
	# Locais padrão onde fontes ficam no Linux
	var search_dirs = [
		"/usr/share/fonts/",
		"/usr/local/share/fonts/",
		OS.get_environment("HOME") + "/.local/share/fonts/",
		OS.get_environment("HOME") + "/.fonts/",
	]

	# Normaliza o nome pra comparação: "Noto Sans" → "notosans"
	var normalized = family.to_lower().replace(" ", "")

	for base_dir in search_dirs:
		var result = _search_font_recursive(base_dir, normalized)
		if result != "":
			return result

	return ""
func _search_font_recursive(path: String, normalized_family: String) -> String:
	if not DirAccess.dir_exists_absolute(path): return ""

	var dir = DirAccess.open(path)
	if not dir: return ""

	dir.list_dir_begin()
	var entry = dir.get_next()

	while entry != "":
		var full = path + entry

		if dir.current_is_dir():
			var found = _search_font_recursive(full + "/", normalized_family)
			if found != "": return found
		else:
			# Só aceita Regular/Normal — evita pegar Bold ou Italic por engano
			var lower = entry.to_lower()
			var name_match = lower.replace(" ", "").replace("-", "").begins_with(normalized_family)
			var is_regular = (
				"regular" in lower or
				"normal"  in lower or
				(not "bold"   in lower and
				 not "italic" in lower and
				 not "light"  in lower and
				 not "thin"   in lower and
				 not "medium" in lower and
				 not "black"  in lower)
			)
			var is_font = lower.ends_with(".ttf") or lower.ends_with(".otf")

			if is_font and name_match and is_regular:
				return full

		entry = dir.get_next()

	return ""
func _load_font_from_family(family: String, size: int) -> FontFile:
	var path = _find_font_file(family)
	if path == "":
		print("Font not found: ", family)
		return null

	var font = FontFile.new()
	var err = font.load_dynamic_font(path)
	if err != OK:
		print("Failed to load font: ", path)
		return null

	return font
	
func create_godot_theme(theme_data: Dictionary, font_data: Dictionary = {}) -> Theme:
	var theme = Theme.new()

	var is_dark_mode: bool = theme_data.dark_mode

	# --- Colors ---
	var window_bg: Color          = theme_data.get("window_bg",          Color(0.2, 0.2, 0.2))
	var window_fg: Color          = theme_data.get("window_fg",          Color(0.9, 0.9, 0.9))
	var window_fg_inactive: Color = theme_data.get("window_fg_inactive", Color(0.5, 0.5, 0.5))
	var button_bg: Color          = theme_data.get("button_bg",          Color(0.3, 0.3, 0.3))
	var button_fg: Color          = theme_data.get("button_fg",          Color(0.9, 0.9, 0.9))
	var accent: Color             = theme_data.get("accent",             Color(0.2, 0.5, 0.8))
	var accent_fg: Color          = theme_data.get("accent_fg",          Color(1.0, 1.0, 1.0))
	var view_bg: Color            = theme_data.get("view_bg",            Color(0.1, 0.1, 0.1))
	var view_fg: Color            = theme_data.get("view_fg",            Color(0.9, 0.9, 0.9))
	var view_fg_inactive: Color   = theme_data.get("view_fg_inactive",   Color(0.5, 0.5, 0.5))
	var view_fg_negative: Color   = theme_data.get("view_fg_negative",   Color(0.8, 0.2, 0.2))
	var view_fg_positive: Color   = theme_data.get("view_fg_positive",   Color(0.2, 0.8, 0.2))
	var view_fg_link: Color       = theme_data.get("view_fg_link",       Color(0.2, 0.5, 0.9))
	var tooltip_bg: Color         = theme_data.get("tooltip_bg",         Color(0.15, 0.15, 0.15))
	var tooltip_fg: Color         = theme_data.get("tooltip_fg",         Color(0.9, 0.9, 0.9))
	var comp_bg: Color            = theme_data.get("complementary_bg",   Color(0.15, 0.15, 0.15))
	var comp_fg: Color            = theme_data.get("complementary_fg",   Color(0.9, 0.9, 0.9))
	var header_bg: Color          = theme_data.get("header_bg",          comp_bg)
	var header_fg: Color          = theme_data.get("header_fg",          comp_fg)
	var header_accent: Color      = theme_data.get("header_accent",      accent)

	# --- Helpers ---
	var border_subtle = window_fg.darkened(0.6) if is_dark_mode else window_fg.lightened(0.6)

	# =========================================================
	# PANEL
	# =========================================================
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = window_bg
	panel_style.set_content_margin_all(10)
	
	theme.set_stylebox("panel", "Panel", panel_style)
	theme.set_stylebox("panel", "PanelContainer", panel_style)

	# =========================================================
	# BUTTON
	# =========================================================
	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color = button_bg
	btn_normal.set_corner_radius_all(4)
	btn_normal.content_margin_left   = 12
	btn_normal.content_margin_right  = 12
	btn_normal.content_margin_top    = 6
	btn_normal.content_margin_bottom = 6
	btn_normal.set_border_width_all(1)
	btn_normal.border_color = Color(accent.r, accent.g, accent.b, 0.25)

	var btn_hover = btn_normal.duplicate()
	btn_hover.bg_color = button_bg.lightened(0.1)
	btn_hover.set_border_width_all(1)
	btn_hover.border_color = accent

	var btn_pressed = btn_normal.duplicate()
	btn_pressed.bg_color = accent.darkened(0.15)

	var btn_focus = btn_normal.duplicate()
	btn_focus.bg_color = button_bg
	btn_focus.set_border_width_all(2)
	btn_focus.border_color = accent

	var btn_disabled = btn_normal.duplicate()
	btn_disabled.bg_color = button_bg.darkened(0.2)

	theme.set_stylebox("normal",   "Button", btn_normal)
	theme.set_stylebox("hover",    "Button", btn_hover)
	theme.set_stylebox("pressed",  "Button", btn_pressed)
	theme.set_stylebox("focus",    "Button", btn_focus)
	theme.set_stylebox("disabled", "Button", btn_disabled)
	theme.set_color("font_color",          "Button", button_fg)
	theme.set_color("font_hover_color",    "Button", window_fg)
	theme.set_color("font_pressed_color",  "Button", accent_fg)
	theme.set_color("font_disabled_color", "Button", window_fg_inactive)
	theme.set_color("font_focus_color",    "Button", window_fg)
	theme.set_color("icon_normal_color",   "Button", button_fg)
	theme.set_color("icon_hover_color",    "Button", window_fg)
	theme.set_color("icon_pressed_color",  "Button", accent_fg)
	theme.set_color("icon_disabled_color", "Button", window_fg_inactive)
	
	# =========================================================
	# MENUBAR
	# =========================================================

	var idle_menubar_bg = StyleBoxFlat.new()
	idle_menubar_bg.bg_color = Color.TRANSPARENT
	idle_menubar_bg.content_margin_left = 10
	idle_menubar_bg.content_margin_right = 10

	var hover_menubar_bg = StyleBoxFlat.new()
	hover_menubar_bg.bg_color = window_bg.lightened(0.25) if is_dark_mode else window_bg.darkened(0.25)
	hover_menubar_bg.content_margin_left = 10
	hover_menubar_bg.content_margin_right = 10
	
	var pressed_menubar_bg = StyleBoxFlat.new()
	pressed_menubar_bg.bg_color = window_bg
	pressed_menubar_bg.content_margin_left = 10
	pressed_menubar_bg.content_margin_right = 10
	
	theme.set_type_variation("CustomMenuBar", "Button")
	theme.set_stylebox("normal", "CustomMenuBar", idle_menubar_bg)
	theme.set_stylebox("hover", "CustomMenuBar", hover_menubar_bg)
	theme.set_stylebox("pressed", "CustomMenuBar", pressed_menubar_bg)
	theme.set_stylebox("focus", "CustomMenuBar", idle_menubar_bg)
	theme.set_stylebox("disabled", "CustomMenuBar", idle_menubar_bg)

	# =========================================================
	# LABEL
	# =========================================================
	theme.set_color("font_color",        "Label", window_fg)
	theme.set_color("font_shadow_color", "Label", Color(0, 0, 0, 0))

	# =========================================================
	# LINE EDIT
	# =========================================================
	var le_normal = StyleBoxFlat.new()
	le_normal.bg_color = view_bg
	le_normal.set_corner_radius_all(3)
	le_normal.set_border_width_all(1)
	le_normal.border_color = border_subtle
	le_normal.content_margin_left   = 8
	le_normal.content_margin_right  = 8
	le_normal.content_margin_top    = 5
	le_normal.content_margin_bottom = 5

	var le_focus = le_normal.duplicate()
	le_focus.border_color = accent
	le_focus.set_border_width_all(2)

	var le_read_only = le_normal.duplicate()
	le_read_only.bg_color = window_bg

	theme.set_stylebox("normal",    "LineEdit", le_normal)
	theme.set_stylebox("focus",     "LineEdit", le_focus)
	theme.set_stylebox("read_only", "LineEdit", le_read_only)
	theme.set_color("font_color",             "LineEdit", view_fg)
	theme.set_color("font_placeholder_color", "LineEdit", view_fg_inactive)
	theme.set_color("font_uneditable_color",  "LineEdit", window_fg_inactive)
	theme.set_color("selection_color",        "LineEdit", accent)
	theme.set_color("caret_color",            "LineEdit", accent)

	# =========================================================
	# TEXT EDIT
	# =========================================================
	var te_normal    = le_normal.duplicate()
	var te_focus     = le_focus.duplicate()
	var te_read_only = le_read_only.duplicate()

	theme.set_stylebox("normal",    "TextEdit", te_normal)
	theme.set_stylebox("focus",     "TextEdit", te_focus)
	theme.set_stylebox("read_only", "TextEdit", te_read_only)
	theme.set_color("font_color",             "TextEdit", view_fg)
	theme.set_color("font_placeholder_color", "TextEdit", view_fg_inactive)
	theme.set_color("font_readonly_color",    "TextEdit", window_fg_inactive)
	theme.set_color("selection_color",        "TextEdit", accent)
	theme.set_color("caret_color",            "TextEdit", accent)
	theme.set_color("word_highlighted_color", "TextEdit", accent.darkened(0.3))

	# =========================================================
	# ITEM LIST
	# =========================================================
	var il_bg = StyleBoxFlat.new()
	il_bg.bg_color = view_bg
	il_bg.set_border_width_all(1)
	il_bg.border_color = border_subtle

	var il_selected = StyleBoxFlat.new()
	il_selected.bg_color = accent
	il_selected.set_corner_radius_all(3)

	var il_selected_unfocus = il_selected.duplicate()
	il_selected_unfocus.bg_color = accent.darkened(0.3)

	var il_hovered = StyleBoxFlat.new()
	il_hovered.bg_color = accent.lightened(0.1)
	il_hovered.bg_color.a = 0.3
	il_hovered.set_corner_radius_all(3)

	theme.set_stylebox("panel",            "ItemList", il_bg)
	theme.set_stylebox("selected",         "ItemList", il_selected)
	theme.set_stylebox("selected_focus",   "ItemList", il_selected)
	theme.set_stylebox("cursor",           "ItemList", il_hovered)
	theme.set_stylebox("cursor_unfocused", "ItemList", il_hovered)
	theme.set_color("font_color",          "ItemList", view_fg)
	theme.set_color("font_selected_color", "ItemList", accent_fg)
	theme.set_color("font_hovered_color",  "ItemList", view_fg)
	theme.set_color("guide_color",         "ItemList", view_fg_inactive)

	# =========================================================
	# TREE
	# =========================================================
	var tree_bg = StyleBoxFlat.new()
	tree_bg.bg_color = view_bg
	tree_bg.set_border_width_all(1)
	tree_bg.border_color = border_subtle

	var tree_selected = StyleBoxFlat.new()
	tree_selected.bg_color = accent
	tree_selected.set_corner_radius_all(3)

	var tree_hover = StyleBoxFlat.new()
	tree_hover.bg_color = accent
	tree_hover.bg_color.a = 0.15
	tree_hover.set_corner_radius_all(3)

	theme.set_stylebox("panel",                "Tree", tree_bg)
	theme.set_stylebox("selected",             "Tree", tree_selected)
	theme.set_stylebox("selected_focus",       "Tree", tree_selected)
	theme.set_stylebox("cursor",               "Tree", tree_hover)
	theme.set_stylebox("cursor_unfocused",     "Tree", tree_hover)
	theme.set_color("font_color",              "Tree", view_fg)
	theme.set_color("font_selected_color",     "Tree", accent_fg)
	theme.set_color("font_outline_color",      "Tree", view_fg)
	theme.set_color("guide_color",             "Tree", view_fg_inactive)
	theme.set_color("relationship_line_color", "Tree", view_fg_inactive)
	theme.set_color("title_button_color",      "Tree", header_fg)

	# =========================================================
	# TOOLTIP
	# =========================================================
	var tooltip_style = StyleBoxFlat.new()
	tooltip_style.bg_color = tooltip_bg
	tooltip_style.set_corner_radius_all(4)
	tooltip_style.set_border_width_all(1)
	tooltip_style.border_color = border_subtle
	tooltip_style.content_margin_left   = 8
	tooltip_style.content_margin_right  = 8
	tooltip_style.content_margin_top    = 4
	tooltip_style.content_margin_bottom = 4

	theme.set_stylebox("panel",     "TooltipPanel", tooltip_style)
	theme.set_color("font_color",   "TooltipLabel", tooltip_fg)

	# =========================================================
	# POPUP MENU
	# =========================================================
	var popup_bg = StyleBoxFlat.new()
	popup_bg.bg_color = window_bg
	popup_bg.set_corner_radius_all(4)
	popup_bg.set_border_width_all(1)
	popup_bg.border_color = border_subtle
	popup_bg.content_margin_left   = 4
	popup_bg.content_margin_right  = 4
	popup_bg.content_margin_top    = 4
	popup_bg.content_margin_bottom = 4

	var popup_hover = StyleBoxFlat.new()
	popup_hover.bg_color = accent
	popup_hover.set_corner_radius_all(3)
	popup_hover.content_margin_left   = 8
	popup_hover.content_margin_right  = 8
	popup_hover.content_margin_top    = 3
	popup_hover.content_margin_bottom = 3

	var popup_separator = StyleBoxLine.new()
	popup_separator.color = border_subtle
	popup_separator.thickness = 1

	theme.set_stylebox("panel",     "PopupMenu", popup_bg)
	theme.set_stylebox("hover",     "PopupMenu", popup_hover)
	theme.set_stylebox("separator", "PopupMenu", popup_separator)
	theme.set_color("font_color",             "PopupMenu", window_fg)
	theme.set_color("font_hover_color",       "PopupMenu", accent_fg)
	theme.set_color("font_disabled_color",    "PopupMenu", view_fg_inactive)
	theme.set_color("font_accelerator_color", "PopupMenu", view_fg_inactive)
	theme.set_color("font_separator_color",   "PopupMenu", view_fg_inactive)

	# =========================================================
	# TAB BAR / TAB CONTAINER
	# =========================================================
	var tab_selected = StyleBoxFlat.new()
	
	tab_selected.bg_color = window_bg
	tab_selected.set_corner_radius_all(4)
	tab_selected.corner_radius_bottom_left  = 0
	tab_selected.corner_radius_bottom_right = 0
	tab_selected.set_border_width_all(0)
	tab_selected.border_width_bottom = 4
	tab_selected.border_color = accent
	tab_selected.content_margin_left   = 12
	tab_selected.content_margin_right  = 12
	tab_selected.content_margin_top    = 6
	tab_selected.content_margin_bottom = 6

	var tab_unselected = StyleBoxFlat.new()
	tab_unselected.bg_color = button_bg
	tab_unselected.set_corner_radius_all(4)
	tab_unselected.corner_radius_bottom_left  = 0
	tab_unselected.corner_radius_bottom_right = 0
	tab_unselected.content_margin_left   = 12
	tab_unselected.content_margin_right  = 12
	tab_unselected.content_margin_top    = 6
	tab_unselected.content_margin_bottom = 6

	var tab_hover = tab_unselected.duplicate()
	tab_hover.bg_color = window_bg.darkened(0.30)
	
	var tabbar_background = StyleBoxFlat.new()
	tabbar_background.bg_color = button_bg
	var tab_panel = StyleBoxFlat.new()
	tab_panel.bg_color = window_bg
	tab_panel.set_content_margin_all(10)

	theme.set_stylebox("tab_selected",   "TabBar", tab_selected)
	theme.set_stylebox("tab_unselected", "TabBar", tab_unselected)
	theme.set_stylebox("tab_hovered",    "TabBar", tab_hover)
	theme.set_color("font_selected_color",   "TabBar", window_fg)
	theme.set_color("font_unselected_color", "TabBar", window_fg)
	theme.set_color("font_hovered_color",    "TabBar", window_fg)

	theme.set_stylebox("tab_selected",      "TabContainer", tab_selected)
	theme.set_stylebox("tab_unselected",    "TabContainer", tab_unselected)
	theme.set_stylebox("tab_hovered",       "TabContainer", tab_hover)
	theme.set_stylebox("tabbar_background", "TabContainer", tabbar_background)
	theme.set_stylebox("panel",             "TabContainer", tab_panel)
	theme.set_color("font_selected_color",   "TabContainer", window_fg)
	theme.set_color("font_unselected_color", "TabContainer", window_fg)
	theme.set_color("font_hovered_color",    "TabContainer", window_fg)

	# =========================================================
	# SCROLL BAR (H and V)
	# =========================================================
	var scroll_bg = StyleBoxFlat.new()
	scroll_bg.bg_color = view_bg.lightened(0.05)

	var scroll_grabber = StyleBoxFlat.new()
	scroll_grabber.bg_color = window_fg_inactive
	scroll_grabber.set_corner_radius_all(4)
	scroll_grabber.content_margin_left   = 2
	scroll_grabber.content_margin_right  = 2
	scroll_grabber.content_margin_top    = 2
	scroll_grabber.content_margin_bottom = 2

	var scroll_grabber_hover = scroll_grabber.duplicate()
	scroll_grabber_hover.bg_color = window_fg

	var scroll_grabber_pressed = scroll_grabber.duplicate()
	scroll_grabber_pressed.bg_color = accent

	for bar in ["HScrollBar", "VScrollBar"]:
		theme.set_stylebox("scroll",             bar, scroll_bg)
		theme.set_stylebox("scroll_focus",       bar, scroll_bg)
		theme.set_stylebox("grabber",            bar, scroll_grabber)
		theme.set_stylebox("grabber_highlight",  bar, scroll_grabber_hover)
		theme.set_stylebox("grabber_pressed",    bar, scroll_grabber_pressed)

	# =========================================================
	# PROGRESS BAR
	# =========================================================
	var pb_bg = StyleBoxFlat.new()
	pb_bg.bg_color = view_bg
	pb_bg.set_corner_radius_all(4)
	pb_bg.set_border_width_all(1)
	pb_bg.border_color = border_subtle

	var pb_fill = StyleBoxFlat.new()
	pb_fill.bg_color = accent.darkened(0.5)
	pb_fill.set_corner_radius_all(4)

	theme.set_stylebox("background", "ProgressBar", pb_bg)
	theme.set_stylebox("fill",       "ProgressBar", pb_fill)
	theme.set_color("font_color",    "ProgressBar", window_fg)

	# =========================================================
	# CHECKBOX
	# =========================================================
	theme.set_color("font_color",          "CheckBox", window_fg)
	theme.set_color("font_hover_color",    "CheckBox", window_fg)
	theme.set_color("font_pressed_color",  "CheckBox", accent)
	theme.set_color("font_disabled_color", "CheckBox", window_fg_inactive)
	theme.set_color("font_focus_color",    "CheckBox", accent)

	# =========================================================
	# CHECK BUTTON
	# =========================================================
	theme.set_color("font_color",          "CheckButton", window_fg)
	theme.set_color("font_hover_color",    "CheckButton", window_fg)
	theme.set_color("font_pressed_color",  "CheckButton", accent)
	theme.set_color("font_disabled_color", "CheckButton", window_fg_inactive)
	theme.set_color("font_focus_color",    "CheckButton", accent)

	# =========================================================
	# OPTION BUTTON
	# =========================================================
	theme.set_stylebox("normal",   "OptionButton", btn_normal)
	theme.set_stylebox("hover",    "OptionButton", btn_hover)
	theme.set_stylebox("pressed",  "OptionButton", btn_pressed)
	theme.set_stylebox("focus",    "OptionButton", btn_focus)
	theme.set_stylebox("disabled", "OptionButton", btn_disabled)
	theme.set_color("font_color",          "OptionButton", window_fg)
	theme.set_color("font_hover_color",    "OptionButton", accent_fg)
	theme.set_color("font_pressed_color",  "OptionButton", accent_fg)
	theme.set_color("font_disabled_color", "OptionButton", window_fg_inactive)
	theme.set_color("font_focus_color",    "OptionButton", window_fg)

	# =========================================================
	# SPIN BOX
	# =========================================================
	theme.set_stylebox("normal",    "SpinBox", le_normal)
	theme.set_stylebox("focus",     "SpinBox", le_focus)
	theme.set_stylebox("read_only", "SpinBox", le_read_only)
	theme.set_color("up_icon_modulate", "SpinBox", window_fg)
	theme.set_color("down_icon_modulate", "SpinBox", window_fg)

	# =========================================================
	# SEPARATOR
	# =========================================================
	var sep_line = StyleBoxLine.new()
	sep_line.color = border_subtle
	sep_line.thickness = 1
	theme.set_stylebox("separator", "HSeparator", sep_line)
	theme.set_stylebox("separator", "VSeparator", sep_line)

	# =========================================================
	# RICH TEXT LABEL
	# =========================================================
	theme.set_color("default_color",      "RichTextLabel", window_fg)
	theme.set_color("font_shadow_color",  "RichTextLabel", Color(0, 0, 0, 0))
	theme.set_color("selection_color",    "RichTextLabel", accent)
	theme.set_color("font_outline_color", "RichTextLabel", Color(0, 0, 0, 0))


	# =========================================================
	# FONTS
	# =========================================================
	var font_map = {
		"general": [
			"Label","Button", "CheckBox", "CheckButton",
			"OptionButton", "PopupMenu", "TabBar", "TabContainer",
			"LineEdit", "SpinBox", "ItemList", "Tree", "TooltipLabel"
		],
		"monospace": [
			"TextEdit",
			"CodeEdit"
		],
	}

	for font_key in font_map:
		var raw = font_data.get(font_key, "")
		if raw == "": continue

		var parts  = raw.split(",")
		var family = parts[0].strip_edges()
		var size   = int(parts[1]) if parts.size() > 1 else 10

		var font_file = _load_font_from_family(family, size)
		if font_file == null: continue

		for control in font_map[font_key]:
			theme.set_font("font", control, font_file)
			theme.set_font_size("font_size", control, size)

	return theme
