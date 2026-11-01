class_name BattleBalance
extends RefCounted

## INITIAL / TUNABLE balance constants for the v0.1 battle domain.

const NORMAL_STAT_MIN := 1
const NORMAL_STAT_MAX := 999

const SPD_MULTIPLIER_MIN := 0.40
const SPD_MULTIPLIER_MAX := 2.00
const BASE_GAUGE_TIME_AT_100_SPD := 5.0
const GAUGE_TIME_MIN := 1.25
const GAUGE_TIME_MAX := 12.0

const BASE_FLEE_CHANCE := 0.50
const SPEED_FLEE_WEIGHT := 0.30
const FLEE_CHANCE_MIN := 0.10
const FLEE_CHANCE_MAX := 0.90

const BASE_ACCURACY := 0.85
const DEX_ACCURACY_WEIGHT := 0.10
const HIT_CHANCE_MIN := 0.05
const HIT_CHANCE_MAX := 0.99

const BASE_CRIT_CHANCE := 0.05
const DEX_CRIT_WEIGHT := 0.10
const CRIT_CHANCE_MAX := 0.75
const BASE_CRIT_DAMAGE_MULTIPLIER := 1.50

static func clamp_normal_stat(value: int) -> int:
	return clampi(value, NORMAL_STAT_MIN, NORMAL_STAT_MAX)

static func clamp_spd_multiplier(value: float) -> float:
	return clampf(value, SPD_MULTIPLIER_MIN, SPD_MULTIPLIER_MAX)
