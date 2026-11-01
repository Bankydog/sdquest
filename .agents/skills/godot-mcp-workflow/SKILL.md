# Godot MCP Workflow

Use this skill when work requires reading or changing Godot scenes, nodes, or resources through the live editor.

1. Call `godot_status`, then `godot_project_info` when project context is needed.
2. Inspect the current scene/node/resource state before editing.
3. Use Godot MCP scene and node tools instead of hand-editing `.tscn`; save editor changes when required.
4. Run the affected scene or project in process mode and inspect error output.
