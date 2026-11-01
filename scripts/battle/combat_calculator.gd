class_name CombatCalculator
extends RefCounted

const BalanceConfig = preload("res://scripts/battle/battle_balance.gd")

## Centralized v0.1 formulas. Battle UI, actor scripts, and skill scripts must call
## this layer instead of duplicating formulas.

static func calculate_effective_stat(
	base_stat: int,
	percent_modifier: float = 1.0,
	flat_modifier: int = 0
) -> int:
	var adjusted_value: int = roundi(float(base_stat) * percent_modifier) + flat_modifier
	return BalanceConfig.clamp_normal_stat(adjusted_value)

static func calculate_base_gauge_time(effective_spd: int) -> float:
	var clamped_spd := BalanceConfig.clamp_normal_stat(effective_spd)
	var seconds := BalanceConfig.BASE_GAUGE_TIME_AT_100_SPD * sqrt(
		100.0 / float(clamped_spd)
	)
	return clampf(seconds, BalanceConfig.GAUGE_TIME_MIN, BalanceConfig.GAUGE_TIME_MAX)

static func calculate_next_gauge_time(
	effective_spd: int,
	action_recovery_multiplier: float
) -> float:
	var recovery := maxf(action_recovery_multiplier, 0.01)
	return calculate_base_gauge_time(effective_spd) * recovery

static func calculate_gauge_fill_rate(
	effective_spd: int,
	action_recovery_multiplier: float = 1.0
) -> float:
	return 100.0 / calculate_next_gauge_time(effective_spd, action_recovery_multiplier)

static func calculate_physical_damage(
	attacker_effective_str: int,
	weapon_damage: int,
	skill_physical_power: int,
	skill_multiplier: float,
	target_effective_vit: int,
	armor_defense: int,
	other_damage_multiplier: float = 1.0
) -> int:
	var attack_value := attacker_effective_str + maxi(weapon_damage, 0) + skill_physical_power
	var defense_value := target_effective_vit + maxi(armor_defense, 0)
	var raw_damage := float(attack_value) * maxf(skill_multiplier, 0.0)
	var mitigated_damage := maxf(0.0, raw_damage - float(defense_value))
	var final_damage := roundi(mitigated_damage * maxf(other_damage_multiplier, 0.0))
	return maxi(1, final_damage)

static func calculate_hit_chance(
	attacker_effective_dex: int,
	skill_accuracy_modifier: float = 0.0,
	target_accuracy_penalty: float = 0.0
) -> float:
	var clamped_dex := BalanceConfig.clamp_normal_stat(attacker_effective_dex)
	var dex_accuracy_bonus := BalanceConfig.DEX_ACCURACY_WEIGHT * sqrt(
		float(clamped_dex) / float(BalanceConfig.NORMAL_STAT_MAX)
	)
	var chance := (
		BalanceConfig.BASE_ACCURACY
		+ dex_accuracy_bonus
		+ skill_accuracy_modifier
		- target_accuracy_penalty
	)
	return clampf(chance, BalanceConfig.HIT_CHANCE_MIN, BalanceConfig.HIT_CHANCE_MAX)

static func calculate_critical_chance(effective_dex: int, weapon_modifier: float = 0.0, skill_modifier: float = 0.0, buff_modifier: float = 0.0) -> float:
	var dex := BalanceConfig.clamp_normal_stat(effective_dex)
	var bonus := BalanceConfig.DEX_CRIT_WEIGHT * sqrt(float(dex) / float(BalanceConfig.NORMAL_STAT_MAX))
	return clampf(BalanceConfig.BASE_CRIT_CHANCE + bonus + weapon_modifier + skill_modifier + buff_modifier, 0.0, BalanceConfig.CRIT_CHANCE_MAX)

static func calculate_critical_damage(normal_damage: int, critical_damage_multiplier: float = BalanceConfig.BASE_CRIT_DAMAGE_MULTIPLIER) -> int:
	return maxi(1, roundi(float(normal_damage) * critical_damage_multiplier))

static func calculate_flee_chance(party_effective_spd: float, enemy_effective_spd: float) -> float:
	var party_speed := maxf(party_effective_spd, 1.0)
	var enemy_speed := maxf(enemy_effective_spd, 1.0)
	var speed_reference := maxf(party_speed, enemy_speed)
	var relative_speed := (party_speed - enemy_speed) / speed_reference
	var chance := BalanceConfig.BASE_FLEE_CHANCE + (
		relative_speed * BalanceConfig.SPEED_FLEE_WEIGHT
	)
	return clampf(chance, BalanceConfig.FLEE_CHANCE_MIN, BalanceConfig.FLEE_CHANCE_MAX)
