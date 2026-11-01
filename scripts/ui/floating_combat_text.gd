extends Label

func show_result(result: Dictionary, screen_position: Vector2, offset: Vector2) -> void:
	position = screen_position + offset
	if bool(result["is_miss"]):
		text = "MISS"
		modulate = Color(0.9, 0.9, 0.9)
	elif bool(result["is_heal"]):
		text = "+%d" % int(result["damage"])
		modulate = Color(0.4, 1.0, 0.5)
	else:
		text = str(result["damage"])
		modulate = Color(1.0, 0.2, 0.2) if bool(result["is_critical"]) else Color.WHITE
	var critical := bool(result["is_critical"])
	add_theme_font_size_override("font_size", 56 if critical else 42)
	scale = Vector2.ONE * (1.45 if critical else 1.15)
	var tween := create_tween()
	tween.tween_property(self, "position:y", position.y - (70.0 if critical else 50.0), 0.85)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.85)
	tween.tween_callback(queue_free)
