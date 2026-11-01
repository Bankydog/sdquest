extends Node
var outcome := "VICTORY"
var hero: Dictionary = {}
var enemy: Dictionary = {}
func set_result(new_outcome: String, hero_state: Dictionary, enemy_state: Dictionary) -> void:
	outcome = new_outcome
	hero = hero_state.duplicate()
	enemy = enemy_state.duplicate()
