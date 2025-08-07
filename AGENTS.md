# ARKit Flutter Plugin - Agent Guidelines

## Build/Test Commands
- `flutter pub get` - Install dependencies
- `flutter analyze` - Run static analysis
- `flutter test` - Run tests (no test directory exists currently)
- `flutter pub run build_runner build` - Generate code (json_serializable)
- `cd example && flutter run` - Run example app

## Code Style Guidelines
- Use `flutter_lints` package rules (analysis_options.yaml)
- Import order: Flutter SDK, external packages, internal packages
- Use explicit types for public APIs, `var` for local variables
- Prefix private members with underscore
- Use `final` for immutable variables, `const` for compile-time constants
- Class names: PascalCase (ARKitNode, ARKitSceneView)
- Method/variable names: camelCase
- Constants: camelCase with descriptive names
- Use ValueNotifier for reactive properties
- Prefer composition over inheritance
- Use json_annotation for serialization with .g.dart files
- Error handling: Use try-catch blocks, return null for optional failures
- Documentation: Use /// for public APIs with clear descriptions