# Godot Architecture

## Status

This is the initial proposed architecture, not immutable canon. It should evolve through intentional decisions while preserving the game-design canon in `docs/game-design/`.

## Modular direction

Use data resources as the content layer:

- `MonsterDefinition`, `SkillDefinition`, `JobDefinition`, `CharacterDefinition`, and `DropTable` resources define reusable content.
- `EncounterDefinition` selects monsters, formations, rewards, and encounter-specific conditions; it does not duplicate monster definitions.
- `WorldLocationDefinition`, progression rules, rumors, and reputation definitions describe world state without coupling to menus or maps.

Keep runtime state separate from definitions:

- Runtime party members reference character and job definitions while holding mutable values such as HP, equipment, progression, and status effects.
- A pure or near-pure battle domain layer owns battle state, legal actions, resolution, and results. Provide deterministic inputs where practical, including an injectable randomness source for chance-based rules.
- Keep centralized battle formula utilities and balance constants separate from actor, skill, monster, and UI scripts. v0.1 uses `BattleBalance` and `CombatCalculator` as the only physical damage, accuracy, flee, and SPD-gauge formula path.
- World progression state owns location access, reputation, rumors, travel outcomes, saving metadata, and ending eligibility.

Keep adapters and presentation at the edge:

- Godot scenes and UI controllers render domain state and submit player intent; they must not contain combat formulas or content tables.
- Battle presentation can be replaced (pixel art or 2.5D) while preserving the same battle-domain contract.
- Save/load serialization maps runtime state to a stable data format; inns and autosave are callers of that service, not separate state systems.

## Suggested dependency direction

`content resources -> domain state/rules -> application services -> scenes and UI`

Presentation may read application/domain results, but domain code must not depend on scene nodes, controls, animation timing, or specific art assets.

## Validation direction

Put deterministic rule tests around battle resolution, encounter outcomes, world progression, and ending selection. Run Godot smoke tests for scene/resource integration and browser/mobile responsiveness once those scenes exist.

## Resolution and scaling policy

SDQuest's initial design canvas is **2560 x 1440 (2K, 16:9)**. Godot uses `canvas_items` stretching with an `expand` aspect policy so the same authored layout scales for browser and mobile targets while wider displays gain extra usable space.

- Treat 2560 x 1440 as the reference for new scene layouts, typography, and art placement.
- Prefer anchors, containers, and relative placement for UI; do not rely on a single physical display size.
- Test key screens at the 2K reference size and at narrower mobile/browser sizes before calling responsive UI complete.
- Keep gameplay coordinates and combat rules independent of display resolution.
