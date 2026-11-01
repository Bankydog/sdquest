# Combat

## Presentation contract

Combat uses an FF-like JRPG presentation: player party on the left, enemies on the right. UI and animation observe and render battle state; they do not own turn order, target legality, damage resolution, or encounter outcomes.

## v0.1 core stats

Players and monsters use the same core model where practical: **HP**, **SP**, **STR**, **VIT**, **SPD**, and **DEX**. Normal STR/VIT/SPD/DEX values are clamped to 1–999. HP and SP are not capped at 999.

- HP reaches defeat at 0. Maximum HP is data-driven from base values, progression, job, equipment, passives, items, and applicable effects. It is not derived from another primary stat.
- SP is the skill resource. Its maximum and recovery rules are data-driven and are not derived from another primary stat.
- STR is physical attack strength.
- VIT is physical defense strength.
- SPD controls the battle gauge and contributes to fleeing.
- DEX contributes to physical accuracy. Target evasion is not a primary stat in v0.1.

Base values are never mutated for combat buffs. Effective STR/VIT/SPD/DEX combine base values with equipment, flat modifiers, percent modifiers, and temporary buffs/debuffs. Runtime actor state owns current HP, SP, gauge progress, and active effects; static definition resources remain unchanged.

## Physical damage

Physical damage is resolved through one centralized calculation path:

```text
AttackValue  = EffectiveSTR + WeaponDMG + SkillPhysicalPower
DefenseValue = EffectiveVIT + ArmorDEF
RawDamage    = AttackValue × SkillMultiplier
FinalDamage  = max(1, (RawDamage - DefenseValue) × OtherDamageMultiplier)
```

Weapon DMG and Armor DEF are their primary contributions. Future equipment may also modify any core stat, HP, or SP. For a successful physical hit, v0.1 damage cannot be negative or zero unless a future explicit immunity/block rule permits it. The formula and tuning remain centralized; individual skills, actors, and UI must not duplicate them.

## SPD gauge and action recovery

Every actor uses a 0–100% SPD gauge. At 100%, the actor is ready to act. Gauge progress uses delta time and is not reset when a SPD modifier changes; only the remaining fill uses the new speed.

```text
EffectiveSPD  = clamp(BaseSPD × SPDModifier + FlatSPDModifier, 1, 999)
BaseGaugeTime = clamp(5.0 × sqrt(100.0 / EffectiveSPD), 1.25, 12.0)
NextGaugeTime = BaseGaugeTime × ActionRecoveryMultiplier
GaugeFillRate = 100.0 / NextGaugeTime
```

The SPD multiplier is clamped to **0.40x–2.00x**. Action recovery is supplied by each action: a normal attack defaults to 1.00, while quick/heavy actions can use their own values. The turn loop itself is not implemented yet.

## Accuracy and fleeing

Physical accuracy is DEX-based:

```text
DexAccuracyBonus = 0.10 × sqrt(EffectiveDEX / 999.0)
HitChance = clamp(0.85 + DexAccuracyBonus + SkillAccuracyModifier - TargetAccuracyPenalty, 0.05, 0.99)
```

Flee chance compares living party and enemy average effective SPD:

```text
FleeChance = clamp(
  BaseFleeChance + ((PartySpeed - EnemySpeed) / max(PartySpeed, EnemySpeed)) × SpeedFleeWeight,
  0.10,
  0.90
)
```

`BaseFleeChance = 0.50` and `SpeedFleeWeight = 0.30`. Special encounters and bosses must be able to disable fleeing later.

## Initial / tunable values

Gauge limits, SPD modifier limits, accuracy constants, flee constants, and damage tuning are **INITIAL / TUNABLE** balance values, not permanent balance canon. They are centralized in `res://scripts/battle/battle_balance.gd`.

## Critical hits

Critical values are **INITIAL / TUNABLE**. `BaseCritChance = 0.05`; `DexCritBonus = 0.10 × sqrt(EffectiveDEX / 999.0)`; and `CritChance = clamp(BaseCritChance + DexCritBonus + WeaponCritModifier + SkillCritModifier + BuffCritModifier, 0.0, 0.75)`. Base critical damage is `1.50x`, applied after defense reduction. DEX affects accuracy and modest critical chance, but not critical damage or dodge in v0.1.

## Future data contract

Static content should be represented by `CharacterDefinition`, `MonsterDefinition`, `EquipmentDefinition`, `SkillDefinition`, and `StatusEffectDefinition`; `RuntimeActorState` holds battle-time state. A future `SkillDefinition` must support SP cost, physical/magical category, power, damage multiplier, accuracy modifier, action recovery multiplier, target rules, and status effects.

The combat system remains responsible for turns, actions, skills, status effects, victory, defeat, and combat abandonment. Chance-based results should use an explicit randomness service rather than UI timing.
