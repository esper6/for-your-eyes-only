# File Boundaries & Change Safety

- Never commit or rely on binary asset diffs unless explicitly asked.
- Scene edits should be **surgical**: add a signal connection, adjust a node property, or add a child—don't regenerate the entire file.
- Keep script-to-scene coupling minimal: resolve nodes via `@onready var` with robust paths (or `%NodeName` unique names) rather than deep brittle chains.
- If changing node names or hierarchy, include a migration note and update all dependent scripts.
