# SingleAxisWrap example

A resizable demo with two counters and two switches. All four controls share
one row when they fit, then move into one column. Their values survive layout
changes, and short windows can scroll to every control.

Requires Flutter 3.47.7 or newer with Dart 3.13.5 or newer in the Dart 3 series.

Run from this directory:

```sh
flutter pub get
flutter run -d macos
```

Choose another available device from `flutter devices` to run on other platforms.
The example scaffolds follow the Flutter 3.47.7 toolchain:

| Platform | Requirements |
| --- | --- |
| Android | Java 17, Gradle 9.3.1, AGP 9.1.0, Kotlin 2.4.0; minimum API 24 |
| iOS | iOS 15.0 or newer; UIScene lifecycle |
| macOS | macOS 12.0 or newer |

Android SDK, target SDK and NDK versions come from the selected Flutter SDK.

```sh
flutter analyze
flutter test test/demo_test.dart
flutter test integration_test/demo_test.dart -d macos
```

The integration tests run the controls through wide, narrow and short layout
constraints in a native app, and check maintained-layout intrinsic sizing after
a resize.
