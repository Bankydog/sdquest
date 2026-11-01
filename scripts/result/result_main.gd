extends Control
@onready var _title: Label = $Outcome
@onready var _summary: Label = $Summary
func _ready() -> void:
	$ContinueButton.pressed.connect(_on_continue_pressed)
	_title.text = BattleResultState.outcome
	_summary.text = "%s\nHero HP: %d / %d\nBlue Slime HP: %d / %d" % [BattleResultState.outcome, int(BattleResultState.hero.get("hp", 0)), int(BattleResultState.hero.get("max_hp", 0)), int(BattleResultState.enemy.get("hp", 0)), int(BattleResultState.enemy.get("max_hp", 0))]
func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/battle/battle_scene.tscn")
