# Flutter BlocX 1.1.0 Release Report

**Package:** `flutter_blocx`  
**Version:** `1.1.0`  
**Release Date:** 2026-10-10  
**Target Branch:** `develop`

---

## 1. Executive Summary

Flutter BlocX 1.1.0 delivers seamless integration with `blocx_core: ^1.1.0`, hardens dependency injection and context lookup, introduces automatic payload reloads on widget updates, wires managed `FocusNode` instances across form inputs with declaration-order error focusing, aligns SDK constraints with Dart 3.8+ / Flutter 3.32+, and decouples local path overrides from committed package manifests.

All changes are non-breaking additions or fixes conforming to semantic versioning.

---

## 2. CI Root Cause Analysis & Resolution

### Root Cause
The CI pipeline previously failed on `flutter pub get` with:
```
Because flutter_blocx depends on blocx_core from path which doesn't exist (../blocx_core), version solving failed.
```
Committed `dependency_overrides` pointing to `../blocx_core` in `pubspec.yaml` and `../../blocx_core` in `example/pubspec.yaml` prevented CI runners from resolving dependencies when the repository was checked out in isolation.

### Resolution
- Removed committed `dependency_overrides` blocks from `pubspec.yaml` and `example/pubspec.yaml`.
- Adopted Dart-standard `pubspec_overrides.yaml` and `example/pubspec_overrides.yaml` for local development, adding them to `.gitignore`.
- Updated GitHub Actions CI (`.github/workflows/ci.yml`) to check out `blocx_core` at `_blocx_core` and synthesize `pubspec_overrides.yaml` dynamically during the build job.
- Excluded `_blocx_core/**` from `analysis_options.yaml`.
- Aligned SDK floors to `sdk: ">=3.8.0 <4.0.0"` and `flutter: ">=3.32.0"`.

---

## 3. Tasks Completed

### Task T7: CI Alignment & Path Override Cleanup
- **Commit:** `033a5e6` (`ci(ui): resolve blocx_core from source in CI, drop committed path override`)
- Removed committed `dependency_overrides` from package manifests.
- Configured local and CI overrides via `pubspec_overrides.yaml`.
- Aligned `environment` to `sdk: ">=3.8.0 <4.0.0"` and `flutter: ">=3.32.0"`.
- Formatted entire repository and resolved Dart 3.8+ lint diagnostics (`unnecessary_underscores`, `use_null_aware_elements`).

### Task T8: Hardened DI Provider Lookup & Documentation
- **Commit:** `e8c6e89` (`fix(ui): clarify and harden DI lookup for provided blocs`)
- Wrapped `context.read` in `BlocxCollectionWidgetState.generateBloc` and `BlocxFormWidgetState.generateBloc` with `try / on ProviderNotFoundException`.
- Threw a descriptive `FlutterError` guiding developers to provide the BLoC typed as the base class (`BlocProvider<BlocxCollectionBloc<...>>`), pass via constructor, or override `generateBloc`.
- Updated `README.md` to document the base-class typing requirement.
- Added comprehensive widget tests in `test/widgets/di_provider_type_test.dart` following Red -> Green TDD.

### Task T9: Automatic Payload Reload on Updates
- **Commit:** `da73a2b` (`feat(ui): reload hosts when the payload changes`)
- Added `shouldReloadOnPayloadChange` getter (defaulting to `true`) in `BlocxCollectionWidgetState` and `BlocxFormWidgetState`.
- Implemented `didUpdateWidget` to trigger `reload()` when `widget.payload` changes, with an assertion verifying `widget.bloc == oldWidget.bloc`.
- Added widget tests in `test/widgets/payload_reload_test.dart` covering payload update triggers, unchanged no-ops, and disabled flags following Red -> Green TDD.

### Task T10: Managed FocusNode Wiring & Declaration-Order Error Focus
- **Commit:** `e8f8383` (`fix(ui): attach managed FocusNodes to text fields and dropdowns, focus first error in field order`)
- Added optional `focusNode` parameter to `BlocXFormTextField` and `BlocXFormDropdown` and forwarded to underlying Flutter inputs.
- Attached managed `FocusNode` instances via `getFocusNode(key)` in `BlocxFormWidgetState.textField` and `dropdown` helpers while respecting user-supplied nodes.
- Updated `BlocxFormWidgetState.requestFocusOnError` to traverse `keys` in declaration order, focusing the first active error on screen.
- Added widget tests in `test/form/focus_wiring_test.dart` following Red -> Green TDD.

### Task T11: Documentation & Changelog Updates
- **Commit:** `4e705a7` (`docs(ui): document DI rule, payload reload, focus handling and limitations`)
- Documented Automatic Payload Reload (`shouldReloadOnPayloadChange`), Automatic Focus Management & `requestFocusOnError`, and architectural Limitations in `README.md`.
- Updated `CHANGELOG.md` under `[1.1.0]` with complete Added, Changed, and Fixed sections.

### Task T12: Final Quality Gate Verification
- Verified all quality gates locally:
  - `dart format --output=none --set-exit-if-changed lib test example/lib` $\rightarrow$ 0 files changed.
  - `flutter analyze --fatal-infos` $\rightarrow$ 0 issues found.
  - `flutter test --coverage` $\rightarrow$ 38 tests passed (100% pass rate).
  - `example` web build $\rightarrow$ Clean build with `--wasm` dry-run compatibility.
  - `flutter pub publish --dry-run` $\rightarrow$ 0 warnings, 1 hint (expected local overrides hint).

---

## 4. Quality Gate Results Summary

| Gate | Command | Result |
| :--- | :--- | :--- |
| Code Formatting | `dart format --output=none --set-exit-if-changed lib test example/lib` | PASSED (0 changed) |
| Static Analysis | `flutter analyze --fatal-infos` | PASSED (0 issues) |
| Automated Tests | `flutter test --coverage` | PASSED (38 passing tests) |
| Example Web Build | `cd example && flutter build web` | PASSED (Clean build) |
| Packaging Validation | `flutter pub publish --dry-run` | PASSED (0 warnings) |
