extends Node

const Calculator = preload("res://scripts/battle/combat_calculator.gd")

signal state_changed(state: Dictionary)
signal message_changed(message: String)
signal commands_enabled_changed(enabled: bool)
signal damage_result(target: StringName, result: Dictionary)

var _rng := RandomNumberGenerator.new()
var _hero: Dictionary
var _enemy: Dictionary
var _hero_ready := false
var _finished := false
var _potions := 2

func _ready() -> void:
	_rng.randomize()
	_hero = _make_actor("Hero", _rng.randi_range(280, 360), _rng.randi_range(30, 50), _rng.randi_range(25, 38), _rng.randi_range(18, 30), _rng.randi_range(75, 115), _rng.randi_range(65, 100))
	_enemy = _make_actor("Blue Slime", _rng.randi_range(180, 260), 0, _rng.randi_range(17, 29), _rng.randi_range(10, 18), _rng.randi_range(50, 85), _rng.randi_range(35, 65))
	_emit_state()
	message_changed.emit("Waiting for SPD gauges...")

func _process(delta: float) -> void:
	if _finished:
		return
	if not _hero_ready:
		_advance(_hero, delta)
	if float(_enemy["gauge"]) < 100.0:
		_advance(_enemy, delta)
	if float(_hero["gauge"]) >= 100.0 and not _hero_ready:
		_hero_ready = true
		commands_enabled_changed.emit(true)
		message_changed.emit("Hero is ready. Choose a command.")
	if float(_enemy["gauge"]) >= 100.0:
		_enemy_attack()
	_emit_state()

func select_command(command: StringName) -> void:
	if not _hero_ready or _finished:
		return
	if command == &"attack":
		_physical_action(_hero, _enemy, "Hero attacks", 8, 1.0, 0.0)
		_finish_hero_turn(1.0)
	elif command == &"skill":
		if int(_hero["sp"]) < 6:
			message_changed.emit("Not enough SP.")
			return
		_hero["sp"] = int(_hero["sp"]) - 6
		_physical_action(_hero, _enemy, "Hero uses Power Strike", 16, 1.3, 0.03)
		_finish_hero_turn(1.25)
	elif command == &"guard":
		_hero["guard"] = true
		message_changed.emit("Hero guards the next hit.")
		_finish_hero_turn(0.8)
	elif command == &"item":
		if _potions <= 0:
			message_changed.emit("No potions left.")
			return
		_potions -= 1
		var healed: int = mini(int(_hero["max_hp"]) - int(_hero["hp"]), 75)
		_hero["hp"] = int(_hero["hp"]) + healed
		message_changed.emit("Hero uses a potion and heals %d HP." % healed)
		_finish_hero_turn(1.0)
	_emit_state()

func get_state() -> Dictionary:
	return {"hero": _hero.duplicate(), "enemy": _enemy.duplicate(), "potions": _potions}

func _make_actor(actor_name: String, hp: int, sp: int, strength: int, vit: int, spd: int, dex: int) -> Dictionary:
	return {"name": actor_name, "hp": hp, "max_hp": hp, "sp": sp, "max_sp": sp, "str": strength, "vit": vit, "spd": spd, "dex": dex, "gauge": 0.0, "recovery": 1.0, "guard": false}

func _advance(actor: Dictionary, delta: float) -> void:
	var rate: float = Calculator.calculate_gauge_fill_rate(int(actor["spd"]), float(actor["recovery"]))
	actor["gauge"] = minf(100.0, float(actor["gauge"]) + rate * delta)

func _enemy_attack() -> void:
	_physical_action(_enemy, _hero, "Blue Slime attacks", 5, 1.0, 0.0)
	_enemy["gauge"] = 0.0
	_enemy["recovery"] = 1.0
	_check_finished()

func _physical_action(attacker: Dictionary, target: Dictionary, label: String, power: int, multiplier: float, accuracy_mod: float) -> void:
	var chance: float = Calculator.calculate_hit_chance(int(attacker["dex"]), accuracy_mod)
	if _rng.randf() > chance:
		damage_result.emit(&"hero" if target == _hero else &"enemy", {"damage": 0, "is_critical": false, "is_miss": true, "is_heal": false})
		message_changed.emit("%s, but misses!" % label)
		return
	var damage: int = Calculator.calculate_physical_damage(int(attacker["str"]), 0, power, multiplier, int(target["vit"]), 0)
	var is_critical := _rng.randf() < Calculator.calculate_critical_chance(int(attacker["dex"]))
	if is_critical:
		damage = Calculator.calculate_critical_damage(damage)
	if bool(target["guard"]):
		damage = maxi(1, roundi(float(damage) * 0.5))
		target["guard"] = false
	target["hp"] = maxi(0, int(target["hp"]) - damage)
	damage_result.emit(&"hero" if target == _hero else &"enemy", {"damage": damage, "is_critical": is_critical, "is_miss": false, "is_heal": false})
	message_changed.emit("%s for %d damage%s." % [label, damage, " CRITICAL" if is_critical else ""])
	_check_finished()

func _finish_hero_turn(recovery: float) -> void:
	_hero["gauge"] = 0.0
	_hero["recovery"] = recovery
	_hero_ready = false
	commands_enabled_changed.emit(false)
	_check_finished()

func _check_finished() -> void:
	if int(_enemy["hp"]) <= 0:
		_finished = true
		commands_enabled_changed.emit(false)
		message_changed.emit("Victory! Blue Slime is defeated.")
		BattleResultState.set_result("VICTORY", _hero, _enemy)
		get_tree().call_deferred("change_scene_to_file", "res://scenes/result/result_main.tscn")
	elif int(_hero["hp"]) <= 0:
		_finished = true
		commands_enabled_changed.emit(false)
		message_changed.emit("Defeat. Hero is defeated.")
		BattleResultState.set_result("DEFEAT", _hero, _enemy)
		get_tree().call_deferred("change_scene_to_file", "res://scenes/result/result_main.tscn")

func _emit_state() -> void:
	state_changed.emit(get_state())
