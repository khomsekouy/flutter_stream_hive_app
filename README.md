# Flutter Stream Hive App ⚽📺

![coverage][coverage_badge]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

**StreamHive** is a Flutter sports‑streaming app: a live‑stream home dashboard,
matches schedule, highlights library, and a profile section, with live match
scores delivered over a WebSocket. It is built on a strict **Clean
Architecture + feature‑first** layout and powered by the
[bloc](https://bloclibrary.dev) state‑management library.

---

## Tech Stack 🧰

| Concern              | Package                                                        |
| -------------------- | ------------------------------------------------------------- |
| State management     | `bloc`, `flutter_bloc` (Cubits)                               |
| Navigation           | `go_router` (stateful shell + bottom nav)                     |
| Dependency injection | `get_it`                                                      |
| Networking           | `dio` (REST), `web_socket_channel` (live scores)              |
| Functional errors    | `fpdart` (`Either<Failure, T>`)                               |
| Value equality       | `equatable`                                                   |
| Images               | `cached_network_image`                                        |
| Notifications        | `top_snackbar_flutter` (top toasts)                           |
| i18n                 | `intl` + ARB files (`flutter_localizations`)                  |
| Asset codegen        | `flutter_gen_runner`                                          |
| Lint / quality       | `very_good_analysis`, `bloc_lint`                             |
| Testing              | `flutter_test`, `bloc_test`, `mocktail`                       |

Requires the Flutter/Dart SDK declared in `pubspec.yaml`
(`sdk: ^3.11.0`, `flutter: ^3.41.0`).

---

## Architecture 🏛️

The codebase follows **Clean Architecture**, sliced **feature‑first**. Each
feature owns three layers, and dependencies only ever point inward
(`presentation → domain ← data`):

```
presentation  →  Cubits + States + Views/Widgets (Flutter)
   │
   ▼
domain        →  Entities, Repository interfaces, Use cases  (pure Dart)
   ▲
   │
data          →  DTOs, Remote/WS data sources, Repository impls
```

- **domain** is the stable core — plain Dart, no Flutter or package imports
  beyond `fpdart`/`equatable`. It defines *what* the app does (entities, use
  cases) and *contracts* (abstract repositories).
- **data** implements those contracts: DTOs map JSON ⇄ entities, data sources
  talk to the network/WebSocket, and `*RepositoryImpl` returns
  `Either<Failure, T>`.
- **presentation** drives the UI with Cubits that call use cases and emit
  immutable states.

Each feature exposes a single **barrel file** (e.g. `live_stream.dart`) as its
public surface. The router, DI, and other features import *only* the barrel —
never a feature's internals — so internal structure can change freely.

### Directory layout

```
lib/
├── main_development.dart        # Flavor entrypoints
├── main_staging.dart            # (call bootstrap → runApp)
├── main_production.dart
├── bootstrap.dart               # BlocObserver, error hook, DI init, runApp
│
├── app/view/app.dart            # Root MaterialApp.router (theme, l10n, routes)
│
├── core/                        # Cross-cutting infrastructure (no feature logic)
│   ├── di/injection.dart        # get_it graph: data sources → repos → use cases → cubits
│   ├── error/                   # Failures (domain) + Exceptions (data)
│   ├── navigation/              # ScaffoldWithNavBar (bottom-nav shell)
│   ├── network/dio_client.dart  # Shared Dio instance + base URL
│   ├── notifications/           # NotificationManager (top toasts)
│   ├── router/app_router.dart   # go_router config + AppRoute names
│   ├── theme/                   # AppColors, AppTheme, AppSemanticColors
│   └── usecase/usecase.dart     # UseCase<Type, Params> base contract
│
├── features/
│   ├── live_stream/             # Home dashboard + stream detail + live scores
│   ├── matches/                 # Matches schedule
│   ├── highlight_list/          # Highlights library
│   ├── profile/                 # User profile
│   ├── auth/                    # Auth (scaffolded)
│   ├── onboarding/              # Onboarding carousel
│   └── splash/                  # Animated splash
│       └── <feature>/
│           ├── data/{datasources,models,repositories}/
│           ├── domain/{entities,repositories,usecases}/
│           ├── presentation/{cubit,view,widgets,content}/
│           └── <feature>.dart   # public barrel
│
├── gen/                         # flutter_gen output (type-safe asset refs)
└── l10n/{arb,gen}/              # ARB sources + generated localizations
```

### Navigation

`AppRouter` (go_router) uses a `StatefulShellRoute.indexedStack` to host the
four bottom‑nav tabs — **Home** (`/`), **Matches** (`/matches`),
**Highlights** (`/highlights`), **Profile** (`/profile`) — inside
`ScaffoldWithNavBar`, each tab keeping its own navigation state. `splash`,
`onboarding`, and the full‑screen `stream/:id` detail are pushed on the root
navigator so they cover the shell (no bottom bar).

### Dependency injection

`core/di/injection.dart` registers the entire graph in `configureDependencies()`,
called once from `bootstrap` before `runApp`. Data sources and repositories are
lazy singletons; use cases and cubits are factories (cubits that need runtime
arguments — e.g. a `streamId` — use `registerFactoryParam`).

> **Note:** data sources are currently registered as **fakes**
> (`FakeLiveStreamRemoteDataSource`, etc.). The `Dio` client and `kApiBaseUrl`
> in `core/network/dio_client.dart` are wired and ready — swap the fakes for
> real HTTP/WS implementations to go live.

---

## Getting Started 🚀

This project ships 3 flavors: **development**, **staging**, **production**.

```sh
# Install dependencies
flutter pub get

# Run a flavor (use the matching launch config in VS Code / Android Studio,
# or the CLI):
flutter run --flavor development --target lib/main_development.dart
flutter run --flavor staging     --target lib/main_staging.dart
flutter run --flavor production  --target lib/main_production.dart
```

_\*StreamHive runs on iOS, Android, Web, macOS, and Windows._

### Code generation

Regenerate type‑safe asset references after adding/removing files in `assets/`:

```sh
dart run build_runner build --delete-conflicting-outputs
```

Assets must also be declared in `pubspec.yaml` (subfolders are **not** included
recursively — each must be listed).

---

## Adding a Feature 🧩

A helper script scaffolds a new feature with the full data/domain/presentation
layering used by `live_stream`:

```sh
./create_feature.sh <feature_name>            # snake_case, e.g. fixtures
./create_feature.sh --with-test <feature_name> # also scaffold cubit + repo tests
```

It generates `lib/features/<feature_name>/`, formats it, and prints the DI and
router snippets to paste (it intentionally does **not** edit
`injection.dart`/`app_router.dart` for you).

---

## Running Tests 🧪

```sh
# All unit + widget tests with coverage
very_good test --coverage --test-randomize-ordering-seed random

# Or with the plain Flutter tooling
flutter test --coverage
```

View the coverage report with [lcov](https://github.com/linux-test-project/lcov):

```sh
genhtml coverage/lcov.info -o coverage/   # Generate
open coverage/index.html                  # Open
```

Tests live under `test/`, mirroring `lib/` (`test/features/<feature>/...`).
Cubits are tested with `bloc_test`; repositories/data sources with `mocktail`.

---

## Code Quality & Bloc Lints 🔍

The project uses `very_good_analysis` plus `bloc_lint`’s recommended rules
(see `analysis_options.yaml`).

```sh
# Static analysis
flutter analyze

# Bloc-specific lint rules
dart run bloc_tools:bloc lint .
```

You can also use the
[official bloc VS Code extension](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc).
Learn more at <https://bloclibrary.dev/lint/>.

---

## Working with Translations 🌐

This project follows the
[official Flutter internationalization guide][internationalization_link] using
[ARB files][arb_documentation_link].

1. Add a key/value (and optional `@description`) to `lib/l10n/arb/app_en.arb`.
2. Use it in the UI:

   ```dart
   import 'package:flutter_stream_hive_app/l10n/l10n.dart';

   @override
   Widget build(BuildContext context) {
     final l10n = context.l10n;
     return Text(l10n.helloWorld);
   }
   ```

3. For a new locale, add `lib/l10n/arb/app_<locale>.arb` and add the locale to
   `CFBundleLocalizations` in `ios/Runner/Info.plist`.
4. Generate (also runs automatically on `flutter run`):

   ```sh
   flutter gen-l10n --arb-dir="lib/l10n/arb"
   ```

l10n config lives in `l10n.yaml`; generated output goes to `lib/l10n/gen/`.

---

## License 📄

Distributed under the MIT License. See [`LICENSE`](LICENSE).

[coverage_badge]: coverage_badge.svg
[internationalization_link]: https://docs.flutter.dev/ui/internationalization
[arb_documentation_link]: https://github.com/google/app-resource-bundle
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
