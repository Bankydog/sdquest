# JRPG UI

Use this skill only for battle presentation, HUD, menus, party/enemy layout, or responsive browser/mobile UI.

1. Read `docs/game-design/core-rules.md` and `combat.md`; consult architecture guidance.
2. Inspect the existing scene and UI implementation with Godot MCP before changing nodes.
3. Preserve the battle contract: party left, enemies right; UI renders state and submits intent without owning rules.
4. Check responsive layout and run the affected scene for Godot errors.
