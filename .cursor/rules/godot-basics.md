# Godot 4.5.1 — Core Rules (GDScript-only)

- Target **Godot 4.5.x** APIs and GDScript 2.0 syntax.
- Do NOT modify: `.godot/`, `.import/`, `.mono/`, `*.import`, or export artifacts.
- Prefer editing `.gd` scripts and minimal diffs in `.tscn` only when necessary (signals, exported props, node names).
- Keep node paths stable. If refactoring a scene tree, update all `$Node` references, `@onready` paths, and signal connections.
- Use **signals** for decoupling and cross-node communication.
- Lifecycle:
  - `_ready()` for wiring and initial state
  - `_process(delta)` for visual/game loop logic
  - `_physics_process(delta)` for physics
- Use **InputMap** actions from `project.godot` (`Input.is_action_pressed(...)`) instead of hard-coded keys.
- For shared state, use **autoload singletons** sparingly and document them.
- Use `res://` paths and keep relative imports consistent across the project.
- Comment non-obvious logic; prefer short docstrings over long prose.