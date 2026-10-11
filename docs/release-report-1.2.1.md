# Release Report: flutter_blocx 1.2.1

Date: 2026-10-11
Repository: `abolfazlkhanmohammdi/flutter_blocx`
Branch: `develop`
Target Release: `1.2.1`

---

## 1. Work Package Execution Status

| Work Package | Title | Status | Commit / Notes |
| :--- | :--- | :--- | :--- |
| **WP0** | Preflight Verification | **DONE** | Pub.dev at 1.2.0; test suite clean (59 tests); 1.2.0 release commit verified at `3021b90` (merged PR #10 from `d06fed5`). |
| **WP2** | Documentation Accuracy & Readme Guard | **DONE** | Commit `be71215`. Fixed standalone view code snippets, casing, and descriptions; added `test/readme_view_examples_test.dart` and `tool/check_readme.dart`. |
| **WP3** | Dropdown Pending Selection Fix | **DONE** | Commit `6d38e91`. Fixed issue where unrelated rebuilds reverted pending dropdown selections; added red/green regression tests in `test/form/dropdown_binding_test.dart`. |
| **WP4** | API Surface Hygiene | **DONE** | Commit `7350d44`. Added `@visibleForTesting` to `onVisibilityChanged` across all six collection widgets. |
| **WP5** | Web Platform Support Investigation | **DONE** | Commit `b1a7725`. Investigated platform support on pub.dev. Confirmed transitive dependency `implicitly_animated_list` -> `list_diff` imports `dart:isolate`, excluding Web from pub.dev badges. Added explicit note in README Limitations. |
| **WP6** | Token-Free Release Workflows | **DONE** | Commit `5867979`. Updated `release.yml` and `publish.yml` to Appendix A3 & A4 (token-free, OIDC via `workflow_dispatch`). Verified 0 occurrences of `RELEASE_TOKEN`. |
| **WP7** | Version Bump, Changelog & Report | **DONE** | Bumped version to `1.2.1` in `pubspec.yaml`, updated `CHANGELOG.md` with `## [1.2.1] - 2026-10-11`, generated release report. |

---

## 2. Quality Gate Verification

### Baseline (WP0):
- `dart format --output=none --set-exit-if-changed .`: Passed
- `flutter analyze --fatal-infos`: Passed (0 issues found)
- `flutter test`: Passed (59 test cases)

### Final Gate (WP7):
- `dart format --output=none --set-exit-if-changed .`: Passed (0 files changed)
- `flutter analyze --fatal-infos`: Passed (0 issues found)
- `flutter test`: Passed (62 test cases)
- `dart run tool/check_readme.dart`: Passed (34 symbols verified, 0 forbidden tokens)

---

## 3. Platform Support Investigation (WP5)

Pub.dev score card for `flutter_blocx` reports:
- Supported: Android, iOS, Windows, Linux, macOS
- Not supported: Web
- Cause:
  ```text
  package:flutter_blocx/flutter_blocx.dart ->
  package:flutter_blocx/list_widget.dart ->
  package:flutter_blocx/src/widgets/collection/options/animated_sliver_infinite_list.dart ->
  package:implicitly_animated_list/implicitly_animated_list.dart ->
  package:list_diff/list_diff.dart ->
  package:list_diff/isolated.dart ->
  dart:isolate
  ```
- Decision: Per instruction decision rule, transitive isolate usage prevents automated Web badge. Documented in `README.md` Limitations.

---

## 4. Owner Actions Required

1. **Re-point published tags on origin (once before merging release PR):**
   ```bash
   git tag v1.2.0 3021b90 && git push origin v1.2.0
   git push origin --delete v1.1.0 v1.0.1
   ```
2. **Confirm Pub.dev Automated Publishing:**
   Verify at https://pub.dev/packages/flutter_blocx/admin that automated publishing is enabled with tag pattern `v{{version}}` and environment `pub.dev`.
3. **Merge Release PR:**
   Merge the `develop` -> `main` Release PR. The workflow will run CI, check changelog, create tag `v1.2.1`, and trigger `publish.yml`.
4. **Approve Publishing:**
   Approve the `pub.dev` deployment environment on GitHub Actions.
5. **Fallback (if dispatch run rejected by pub.dev):**
   ```bash
   git push origin --delete v1.2.1
   git tag v1.2.1 <main-commit-hash> && git push origin v1.2.1
   ```
