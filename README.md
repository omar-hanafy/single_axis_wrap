# single_axis_wrap

<p align="center">
  <a href="https://pub.dev/packages/single_axis_wrap"><img src="https://img.shields.io/pub/v/single_axis_wrap.svg" alt="Pub"></a>
  <a href="https://github.com/omar-hanafy/single_axis_wrap/stargazers"><img src="https://img.shields.io/github/stars/omar-hanafy/single_axis_wrap" alt="Stars"></a>
  <a href="https://github.com/omar-hanafy/single_axis_wrap/blob/main/LICENSE"><img src="https://img.shields.io/github/license/omar-hanafy/single_axis_wrap" alt="License"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Platform-Flutter-02569B?logo=flutter" alt="Platform"></a>
</p>

A Flutter layout widget that attempts to place all children in a single primary axis, falling back to the opposite axis if they exceed the available space.

Unlike Flutter's built-in `Wrap` (which breaks children into multiple runs) or `OverflowBar` (which is strictly horizontal-first), `SingleAxisWrap` commits to exactly one axis for all children and supports both horizontal-first and vertical-first layouts.

<p align="center">
  <img src="https://raw.githubusercontent.com/omar-hanafy/single_axis_wrap/refs/heads/main/assets/demo.gif" width="60%" alt="SingleAxisWrap demo">
</p>

## Features

- Chooses one complete row or one complete column from the available space.
- Supports both horizontal-first and vertical-first layouts.
- Provides separate main-axis and cross-axis alignment for horizontal and
  vertical outcomes.
- Supports shared spacing, plus optional horizontal-only and vertical-only
  spacing.
- Calls `onLayoutDirectionChanged` after the chosen axis changes.
- Can lock the first chosen axis with `maintainLayout` to avoid flicker during
  resize animations.

## When To Use It

Use it for UI groups that should stay together as one row when space allows and
become one column when space is tight:

- Dialog or form actions.
- Button groups and compact toolbars.
- Filter chips or navigation controls that should not split across multiple
  runs.

## How It Differs

`Wrap` flows children into multiple rows or columns when they do not fit.
`SingleAxisWrap` does not create runs. It chooses one complete row or one
complete column.

`OverflowBar` is horizontal-first. `SingleAxisWrap` can be horizontal-first or
vertical-first, with independent spacing, alignment, cross-axis alignment,
direction-change callbacks, and optional layout locking.

## Requirements

- Dart `^3.12.0`
- Flutter `>=3.44.0`
- No runtime dependencies beyond Flutter

## Installation

Add the package to your Flutter project:

```sh
flutter pub add single_axis_wrap
```

Then import it:

```dart
import 'package:single_axis_wrap/single_axis_wrap.dart';
```

## Usage

A common use case is a button group that stays in a row when space allows and
falls back to a column on narrow screens.

```dart
SingleAxisWrap(
  spacing: 8,
  horizontalAlignment: WrapAlignment.end,
  children: [
    TextButton(
      onPressed: () {},
      child: const Text('Cancel'),
    ),
    FilledButton(
      onPressed: () {},
      child: const Text('Save'),
    ),
  ],
)
```

By default, `SingleAxisWrap` tries `Axis.horizontal` first. If the row does not
fit the available width, it uses `Axis.vertical`.

For vertical-first layout, set `primaryDirection`:

```dart
SingleAxisWrap(
  primaryDirection: Axis.vertical,
  spacing: 8,
  children: const [
    Chip(label: Text('Open')),
    Chip(label: Text('Assigned')),
    Chip(label: Text('Urgent')),
  ],
)
```

## Direction Changes

Use `onLayoutDirectionChanged` to react when the widget switches between row and
column. Add `maintainLayout: true` when resizing or animation would otherwise
make the layout flip repeatedly.

```dart
SingleAxisWrap(
  maintainLayout: true,
  spacing: 8,
  onLayoutDirectionChanged: (direction) {
    debugPrint('SingleAxisWrap changed to $direction');
  },
  children: [
    TextButton(onPressed: () {}, child: const Text('Cancel')),
    FilledButton(onPressed: () {}, child: const Text('Save')),
  ],
)
```

The callback is scheduled after layout and is not called for the initial layout.
`maintainLayout` keeps the first chosen direction until it is turned off,
`primaryDirection` changes, or the render object is recreated.

## Configuration

| Property | Description |
| --- | --- |
| `children` | Widgets laid out together in one final row or one final column. |
| `primaryDirection` | Axis attempted first. Defaults to `Axis.horizontal`. |
| `spacing` | Default gap between adjacent children in either layout. |
| `horizontalSpacing` | Gap used when the final layout is horizontal. Overrides `spacing`. |
| `verticalSpacing` | Gap used when the final layout is vertical. Overrides `spacing`. |
| `horizontalAlignment` | Main-axis alignment when the final layout is horizontal. |
| `verticalAlignment` | Main-axis alignment when the final layout is vertical. |
| `horizontalCrossAxisAlignment` | Cross-axis alignment when the final layout is horizontal. |
| `verticalCrossAxisAlignment` | Cross-axis alignment when the final layout is vertical. |
| `textDirection` | Resolves horizontal child order and horizontal `start` / `end`. |
| `verticalDirection` | Resolves vertical child order and vertical `start` / `end`. |
| `clipBehavior` | Controls paint clipping when children overflow. |
| `onLayoutDirectionChanged` | Called after an existing resolved direction changes. |
| `maintainLayout` | Reuses the first chosen direction until reset. |
| `measurementStrategy` | Defaults to `MeasurementStrategy.layout`. Use `intrinsic` only after profiling. |

## Notes

- `SingleAxisWrap` always commits to exactly one row or one column.
- It does not create multiple rows or multiple columns. Use `Wrap` for that.
- If both axes are too small, the fallback layout can still overflow. Use
  `clipBehavior` to control paint clipping.
- Alignment values like `center` and `end` only visibly move children when the
  parent gives `SingleAxisWrap` extra space.

## Contributing

Contributions are welcome. Please open an issue or pull request on GitHub.

## License

This project is licensed under the BSD 3-Clause License. See [LICENSE](LICENSE)
for details.

## Support

<a href="https://www.buymeacoffee.com/omar.hanafy" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>
