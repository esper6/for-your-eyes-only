# Quality, Performance, and Style

- Use typed GDScript everywhere (e.g., `var hp: int = 100`).
- Prefer `@onready var` to cache node references.
- Avoid allocations in tight loops or per-frame logic; pre-allocate (arrays, nodes) when possible.
- Keep public APIs small; expose clear methods and signals.
- If a script grows beyond ~200–300 LOC or mixes concerns, propose a small component split.
- If tests exist (GdUnit4 or WAT), add/adjust tests with code changes.
- Validate exported properties (ranges, enums) to help the editor UI.
- For save data, avoid storing direct node references; use resource-friendly data.