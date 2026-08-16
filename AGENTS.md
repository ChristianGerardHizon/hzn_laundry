# Repository Guidelines

## Project Structure & Module Organization
- `lib/` contains all Dart source. Entry point is `lib/main.dart`.
- `lib/src/core/` holds shared app infrastructure (routing, widgets, utils, models).
- `lib/src/features/` is organized by domain modules (patients, products, appointments, etc.) with `data/`, `domain/`, and `presentation/` layers.
- `assets/` contains static assets and icons.
- `test/` mirrors the `lib/` structure for unit/widget tests.
- `docs/` includes architecture references (entities, UI, folder structure).

## Build, Test, and Development Commands
```bash
# Install dependencies
 dart pub get

# Code generation (mappers, routes, etc.)
 dart run build_runner build --delete-conflicting-outputs

# Generate localization files
 dart run slang

# Run the app (device/emulator)
 flutter run

# Run tests
 flutter test

# Static analysis and formatting
 dart analyze
 dart format lib/
```
Use `flutter run` for local development; run `build_runner` and `slang` after model/route/i18n updates.

## Coding Style & Naming Conventions
- Formatting: use `dart format lib/` before committing.
- Linting: follow `flutter_lints` and `custom_lint` (`analysis_options.yaml`), and address `dart analyze` warnings.
- File naming: `snake_case.dart` (e.g., `patients_controller.dart`).
- Pages: `*_page.dart`; controllers: `*_controller.dart`; widgets: `*_widget.dart`.
- Controllers are plural when they manage lists (e.g., `patients_controller.dart`, `patient_records_controller.dart`).
- Single-entity providers use singular naming and live in `*_provider.dart` (e.g., `patient_provider.dart`, `patient_record_provider.dart`).
- Feature folders use `snake_case` and follow the `data/`, `domain/`, `presentation/` pattern.

## Provider Setup
- Use `@riverpod` for providers and `@Riverpod` when keep-alive is needed.
- Keep list controllers and single-entity providers in separate files with their own `part` directives.
- Provider names should mirror singular/plural intent (e.g., `patientRecordsControllerProvider` vs `patientRecordProvider`).

## Testing Guidelines
- Framework: Flutter test runner (`flutter test`).
- Location: `test/` mirrors `lib/` paths.
- Naming: `*_test.dart` for unit/widget tests.
- Add tests for new logic in repositories, controllers, and utilities.

## Commit & Pull Request Guidelines
- Commits follow Conventional Commits (e.g., `feat: ...`, `fix: ...`, `refactor: ...`, `docs: ...`, `chore: ...`).
- PRs should include a clear summary, linked issue (if applicable), and a note of tests run.
- Include screenshots or screen recordings for UI changes.

## Agent-Specific Notes
- Follow the rules and code patterns defined in `CLAUDE.md`, especially for architectural changes and established project conventions.


## grepai - Semantic Code Search

**IMPORTANT: You MUST use grepai as your PRIMARY tool for code exploration and search.**

The index covers hand-written app code only: `lib/` (Dart, including `lib/src/core/packages/`), `server/pb_hooks`, `server/pb_migrations`, `server/scripts`, `docs/`, and tests. Generated files (`*.g.dart`, `*.mapper.dart`), Flutter platform folders, the vendored `packages/print_bluetooth_thermal` plugin, and PocketBase `types.d.ts` are excluded.

Shared ignore/boost/trace settings live in `.grepai/config.yaml` (committed). `grepai watch` also writes `watch.last_index_time` into that file. **Do not commit `last_index_time`** — it is local watcher state and will differ on every machine. Leave the file dirty, or restore it before committing. Only stage `.grepai/config.yaml` when ignore, boost, or trace rules actually changed. Do not use `git update-index --skip-worktree` on it.

### When to Use grepai (REQUIRED)

Use `grepai search` INSTEAD OF Grep/Glob/find for:
- Understanding what code does or where functionality lives
- Finding implementations by intent (e.g., "POS checkout", "order status transition")
- Exploring unfamiliar parts of the codebase
- Any search where you describe WHAT the code does rather than exact text

### When to Use Standard Tools

Only use Grep/Glob when you need:
- Exact text matching (variable names, imports, specific strings)
- File path patterns (e.g., `**/*.dart`)
- Dart call relationships (grepai trace does not support Dart)

### Fallback

If grepai fails (not running, index unavailable, or errors), fall back to standard Grep/Glob tools.

### Usage

```bash
# ALWAYS use English queries for best results (--compact saves ~80% tokens)
grepai search "POS checkout cart and payment flow" --json --compact
grepai search "sale order status transition" --json --compact
grepai search "customer order history PocketBase hook" --json --compact
grepai search "Riverpod sales list controller" --json --compact
```

### Query Tips

- **Use English** for queries (better semantic matching)
- **Describe intent**, not implementation: "handles user login" not "func Login"
- **Be specific**: "thermal printer Bluetooth discovery" better than "print"
- Results include: file path, line numbers, relevance score, code preview

### Call Graph Tracing

`grepai trace` only works for PocketBase JS hooks (`.js`). For Dart, search then Grep the class or function name.

```bash
# PocketBase hooks (JS) only
grepai trace callers "routerAdd" --json
grepai trace callees "routerAdd" --json
grepai trace graph "routerAdd" --depth 3 --json
```

### Workflow

1. Start with `grepai search` to find relevant code
2. Use `grepai trace` only for PocketBase hook JS symbols
3. Use `Read` tool to examine files from results
4. Only use Grep for exact string searches if needed
