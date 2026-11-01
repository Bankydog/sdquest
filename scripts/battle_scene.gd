extends Control

const FOREST_BACKGROUND_PATH := "res://assets/screens/bg/forrest-01.png"
const BATTLE_GROUND_PATH := "res://assets/screens/floor/grass-01.png"
const PARTY_ACTOR_PATH := "res://assets/characters/1-simple/test-cha.png"
const ENEMY_ACTOR_PATH := "res://assets/monsters/1-simple/403c7ba9-d006-410d-9217-d3ebe345de5d.png"
const FloatingCombatText = preload("res://scenes/ui/floating_combat_text.tscn")

@onready var _forest_background: TextureRect = $Background/ForestBackground
@onready var _battle_ground: TextureRect = $Background/BattleGround
@onready var _party_actor: Sprite2D = $Battlefield/PartyLayer/PartyActor
@onready var _enemy_actor: Sprite2D = $Battlefield/EnemyLayer/EnemyActor
@onready var _battle: Node = $BattleTestController
@onready var _buttons: Array[Button] = [$UILayer/CommandWindow/CommandList/AttackButton, $UILayer/CommandWindow/CommandList/SkillButton, $UILayer/CommandWindow/CommandList/GuardButton, $UILayer/CommandWindow/CommandList/ItemButton]

func _ready() -> void:
	_load_texture(_forest_background, FOREST_BACKGROUND_PATH)
	_load_texture(_battle_ground, BATTLE_GROUND_PATH)
	_load_actor(_party_actor, PARTY_ACTOR_PATH)
	_load_actor(_enemy_actor, ENEMY_ACTOR_PATH)
	get_viewport().size_changed.connect(_layout_actors)
	_layout_actors()
	_battle.state_changed.connect(_update_state)
	_battle.commands_enabled_changed.connect(_set_commands_enabled)
	_battle.damage_result.connect(_show_damage_result)
	$UILayer/CommandWindow/CommandList/AttackButton.pressed.connect(func(): _battle.select_command(&"attack"))
	$UILayer/CommandWindow/CommandList/SkillButton.pressed.connect(func(): _battle.select_command(&"skill"))
	$UILayer/CommandWindow/CommandList/GuardButton.pressed.connect(func(): _battle.select_command(&"guard"))
	$UILayer/CommandWindow/CommandList/ItemButton.pressed.connect(func(): _battle.select_command(&"item"))
	_set_commands_enabled(false)
	_update_state(_battle.get_state())

func _load_texture(target: TextureRect, path: String) -> void:
	if ResourceLoader.exists(path):
		var resource := ResourceLoader.load(path)
		if resource is Texture2D: target.texture = resource

func _load_actor(target: Sprite2D, path: String) -> void:
	if ResourceLoader.exists(path):
		var resource := ResourceLoader.load(path)
		if resource is Texture2D: target.texture = resource

func _layout_actors() -> void:
	_place(_party_actor, 0.41, 0.90, 0.47, 0.24)
	_place(_enemy_actor, 0.76, 0.89, 0.54, 0.34)

func _place(actor: Sprite2D, x: float, ground: float, height_ratio: float, width_ratio: float) -> void:
	if actor.texture == null: return
	var viewport_size := get_viewport_rect().size
	var texture_size := actor.texture.get_size()
	var scale_factor: float = minf(viewport_size.y * height_ratio / texture_size.y, viewport_size.x * width_ratio / texture_size.x)
	actor.scale = Vector2.ONE * scale_factor
	actor.position = Vector2(viewport_size.x * x, viewport_size.y * ground - texture_size.y * scale_factor * 0.5)

func _update_state(state: Dictionary) -> void:
	_update_panel("HeroStatus", state["hero"])
	_update_panel("EnemyStatus", state["enemy"])
	$UILayer/CommandWindow/CommandList/ItemButton.text = "Item (%d)" % int(state["potions"])

func _update_panel(panel_name: String, actor: Dictionary) -> void:
	var info: VBoxContainer = get_node("UILayer/%s/Info" % panel_name)
	info.get_node("Name").text = str(actor["name"])
	info.get_node("HP").text = "HP %d / %d" % [actor["hp"], actor["max_hp"]]
	info.get_node("SP").text = "SP %d / %d" % [actor["sp"], actor["max_sp"]]
	info.get_node("Stats").text = "STR %d  VIT %d  SPD %d  DEX %d" % [actor["str"], actor["vit"], actor["spd"], actor["dex"]]
	info.get_node("GaugeLabel").text = "SPD Gauge %.0f%%" % float(actor["gauge"])
	info.get_node("Gauge").value = float(actor["gauge"])

func _show_damage_result(target: StringName, result: Dictionary) -> void:
	var actor := _party_actor if target == &"hero" else _enemy_actor
	var floating := FloatingCombatText.instantiate()
	$EffectsLayer.add_child(floating)
	floating.show_result(result, actor.global_position, Vector2(-18.0 + randf_range(-12.0, 12.0), -actor.texture.get_size().y * actor.scale.y * 0.32))

func _set_commands_enabled(enabled: bool) -> void:
	for button in _buttons: button.disabled = not enabled
