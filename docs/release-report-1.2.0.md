# Release Report: flutter_blocx 1.2.0

**Package:** `flutter_blocx`  
**Version:** `1.2.0`  
**Date:** 2026-10-10  
**Branch:** `release/1.2.0-prep`  

## 1. Summary of Changes
- **F8 / U1 (Form Hydration):** Pre-hydrated newly created `TextEditingController` instances in `BlocxFormWidgetState.getTextEditingController(key)`. When a field controller is created on demand (e.g. conditionally rendered or late-mounted multi-step form fields), it immediately populates with existing values from `bloc.formData[key]`.
- **F9 / U2 (AutoScrollTag Wrapping Order):** Fixed the widget hierarchy on bottom loading trigger items in infinite collection widgets (`InfiniteList`, `SliverInfiniteList`, `InfiniteGrid`, `SliverInfiniteGrid`, `AnimatedInfiniteList`, and `AnimatedSliverInfiniteList`). Items are wrapped in `AutoScrollTag` before `VisibilityDetector` to ensure programmatic scrolling (`scroll_to_index`) targets the container without breaking visibility reporting.
- **F10 / U3 (Visibility Callback Freshness):** In all infinite list, grid, and sliver widgets, `onVisibilityChanged` now reads live `bloc.state` directly instead of referencing potentially stale build-time closures, preventing missed or duplicate page fetches.
- **F11 / U4 (Concurrent Refresh Verification):** Added test coverage verifying that concurrent pull-to-refresh during an active load-more request cleanly resets pagination flags and collection states.
- **CI/CD:** Configured GitHub Actions workflows (`ci.yml`, `release.yml`, `publish.yml`) for automated testing, release tagging on merge to `main`, and OIDC trusted publishing on tag push.

## 2. Gate Verification
- **Formatting:** `dart format --output=none --set-exit-if-changed lib test example/lib` -> **PASSED** (0 changed files).
- **Static Analysis:** `flutter analyze --fatal-infos` -> **PASSED** (0 issues).
- **Unit & Widget Tests:** `flutter test` -> **PASSED** (40 tests passed).
- **Package Dry Run:** `flutter pub publish --dry-run` -> **PASSED**.

## 3. Breaking Changes
- **None.** All public APIs remain backward-compatible with 1.1.0. Dependents can continue using `blocx_core: ^1.1.0`.
