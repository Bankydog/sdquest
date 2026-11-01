<!-- BEGIN:godot-mcp -->
## Godot (managed by godot-mcp; edit outside these markers)

- This is a Godot 4.7 project. Your training data may be older: use Godot 4 APIs and GDScript 2.0 syntax, never Godot 3.
- Use the `godot_*` MCP tools. Start with `godot_status`, then `godot_project_info` for the main scene, autoloads and input actions.
- Change scenes with the scene/node tools, not by hand-editing `.tscn` text. If the editor is open, edits there are undoable; save with `godot_scene_save`.
- Don't edit `.godot/` (generated cache). Keep `*.uid` and `*.import` files next to their resources when moving files.
- Check your work: `godot_run_start` (mode "process"), then `godot_run_output` with level "error".
<!-- END:godot-mcp -->

## Repository engineering rules

- Inspect the current implementation and the relevant design documents before editing.
- Treat `docs/game-design/` as established canon. Do not silently alter it; explicitly propose and document approved canon changes.
- Keep gameplay logic independent of presentation. In particular, battle state and rules must not depend on battle UI nodes or art assets.
- Prefer data-driven Godot `Resource` definitions for jobs, monsters, skills, drops, and encounters.
- Keep monster definitions separate from encounter definitions, and character/job definitions separate from runtime party members.
- Do not hardcode content, combat rules, or encounter data directly into battle UI scripts or scenes.
- Use Godot MCP for useful editor, project, scene, node, and runtime inspection. Use scene/node tools rather than hand-editing `.tscn` files.
- Follow the resolution and scaling policy in `docs/architecture/godot-architecture.md`; author responsive UI against the 2K reference canvas rather than a single physical display size.
- Keep changes scoped to the requested task; do not add speculative gameplay, assets, scenes, or unrelated refactors.
- After meaningful gameplay or system changes, run the relevant validation and inspect Godot errors.

## Repository engineering rules

- Inspect the current implementation and the relevant design documents before editing.
- Treat `docs/game-design/` as established canon. Do not silently alter it; explicitly propose and document approved canon changes.
- Keep gameplay logic independent of presentation. In particular, battle state and rules must not depend on battle UI nodes or art assets.
- Prefer data-driven Godot `Resource` definitions for jobs, monsters, skills, drops, and encounters.
- Keep monster definitions separate from encounter definitions, and character/job definitions separate from runtime party members.
- Do not hardcode content, combat rules, or encounter data directly into battle UI scripts or scenes.
- Use Godot MCP for useful editor, project, scene, node, and runtime inspection. Use scene/node tools rather than hand-editing `.tscn` files.
- Keep changes scoped to the requested task; do not add speculative gameplay, assets, scenes, or unrelated refactors.
- After meaningful gameplay or system changes, run the relevant validation and inspect Godot errors.
