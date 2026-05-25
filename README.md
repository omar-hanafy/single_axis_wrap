<h1 align="center">SingleAxisWrap</h1>

<p align="center">
  <a href="https://pub.dev/packages/single_axis_wrap"><img src="https://img.shields.io/pub/v/single_axis_wrap.svg" alt="Pub"></a>
  <a href="https://github.com/omar-hanafy/single_axis_wrap/stargazers"><img src="https://img.shields.io/github/stars/omar-hanafy/single_axis_wrap" alt="Stars"></a>
  <a href="https://github.com/omar-hanafy/single_axis_wrap/blob/main/LICENSE"><img src="https://img.shields.io/github/license/omar-hanafy/single_axis_wrap" alt="License"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Platform-Flutter-02569B?logo=flutter" alt="Platform"></a>
</p>

`SingleAxisWrap` is a Flutter widget that chooses one complete layout axis for
all children. It can try a row first and fall back to a column, or try a column
first and fall back to a row.

Unlike `Wrap`, it never breaks children into multiple runs. Unlike
`OverflowBar`, it is symmetric: it can be horizontal-first or vertical-first,
with separate spacing, alignment, directionality, callback, and layout-lock
controls for the final row or column.

<p align="center">
  <img src="https://raw.githubusercontent.com/omar-hanafy/single_axis_wrap/refs/heads/main/assets/demo.gif" width="60%" alt="SingleAxisWrap demo">
</p>

## When To Use It

Use `SingleAxisWrap` when a group of widgets should stay together as one row or
one column:

- Dialog actions that should not partially wrap.
- Filter chips that should switch from one row to one column.
- Compact navigation items that should preserve a single visual axis.
- Toolbars or segmented controls that need a stable fallback layout.
- Animated containers where the chosen axis should not flicker while resizing.

Prefer built-in Flutter widgets when the problem is simpler:

- Use `Row` or `Column` when the axis is fixed.
- Use `Wrap` when children should flow into multiple lines or columns.
- Use `OverflowBar` first for simple row-first dialog action layouts.

## Requirements

- Dart `^3.12.0`
- Flutter `>=3.44.0`
- No runtime dependencies beyond Flutter

## Installation

Add the package to `pubspec.yaml`:

```yaml
dependencies:
  single_axis_wrap: ^1.0.3
```

Import it:

```dart
import 'package:single_axis_wrap/single_axis_wrap.dart';
```

## Quick Start

```dart
SingleAxisWrap(
  spacing: 8,
  children: [
    ElevatedButton(onPressed: () {}, child: const Text('Cancel')),
    ElevatedButton(onPressed: () {}, child: const Text('Apply')),
    ElevatedButton(onPressed: () {}, child: const Text('Save')),
  ],
)
```

With the default `primaryDirection: Axis.horizontal`, this lays children out as
one row when they fit. If their total width plus spacing exceeds the available
width, it switches to one column.

## How The Axis Is Chosen

`SingleAxisWrap` follows a small, deterministic decision model:

1. Measure the `primaryDirection`.
2. If the primary main axis is unbounded, keep the primary direction.
3. If the primary main axis is bounded, check whether all children plus spacing
   fit in that axis.
4. If they fit, use the primary direction.
5. If they do not fit, use the opposite direction.
6. The fallback direction can still overflow if that axis is also too small.

For example, horizontal-first layout checks width first:

```dart
SingleAxisWrap(
  primaryDirection: Axis.horizontal,
  spacing: 12,
  children: const [
    SizedBox(width: 120, height: 48),
    SizedBox(width: 120, height: 48),
    SizedBox(width: 120, height: 48),
  ],
)
```

Vertical-first layout checks height first:

```dart
SingleAxisWrap(
  primaryDirection: Axis.vertical,
  verticalSpacing: 8,
  horizontalSpacing: 16,
  children: const [
    SizedBox(width: 120, height: 48),
    SizedBox(width: 120, height: 48),
    SizedBox(width: 120, height: 48),
  ],
)
```

## Sizing And Constraints

`SingleAxisWrap` shrink-wraps its children unless a parent gives it a larger
minimum size, a tight size, or a finite max size with one of the space
distributing alignments:

- `WrapAlignment.spaceBetween`
- `WrapAlignment.spaceAround`
- `WrapAlignment.spaceEvenly`

That means `WrapAlignment.center` and `WrapAlignment.end` only visibly move
children when the widget itself has extra space. In loose constraints, such as
inside `Center`, the widget may be only as wide or tall as its children.

Use a parent such as `SizedBox`, `ConstrainedBox`, or `Expanded` when you want
alignment inside a larger area:

```dart
SizedBox(
  width: 360,
  child: SingleAxisWrap(
    spacing: 8,
    horizontalAlignment: WrapAlignment.end,
    children: [
      OutlinedButton(onPressed: () {}, child: const Text('Back')),
      FilledButton(onPressed: () {}, child: const Text('Next')),
    ],
  ),
)
```

### Common Gotcha

If `WrapAlignment.end` or `WrapAlignment.center` appears to do nothing, check
the parent constraints first. In loose constraints, `SingleAxisWrap` may
shrink-wrap to its children, leaving no extra main-axis space to distribute.

## Directionality

`textDirection` controls horizontal child order and horizontal `start` / `end`
alignment. If omitted, `SingleAxisWrap` reads the ambient `Directionality`.

`verticalDirection` controls vertical child order and vertical `start` / `end`
alignment:

- `VerticalDirection.down` places the first child near the top.
- `VerticalDirection.up` places the first child near the bottom.

These rules apply to the final chosen axis, whether it is the primary axis or
the fallback axis.

## Alignment

Main-axis alignment is configured separately for each final layout:

```dart
SingleAxisWrap(
  spacing: 8,
  horizontalAlignment: WrapAlignment.center,
  verticalAlignment: WrapAlignment.spaceEvenly,
  horizontalCrossAxisAlignment: WrapCrossAlignment.center,
  verticalCrossAxisAlignment: WrapCrossAlignment.end,
  children: const [
    SizedBox(width: 100, height: 40),
    SizedBox(width: 120, height: 48),
    SizedBox(width: 90, height: 36),
  ],
)
```

Spacing can also be split per final axis:

```dart
SingleAxisWrap(
  spacing: 8,
  horizontalSpacing: 16,
  verticalSpacing: 6,
  children: const [
    Chip(label: Text('Open')),
    Chip(label: Text('Assigned')),
    Chip(label: Text('Urgent')),
  ],
)
```

## Maintaining The Chosen Axis

Set `maintainLayout: true` when a parent animation or resize would otherwise
make the group flip repeatedly between row and column.

```dart
SingleAxisWrap(
  maintainLayout: true,
  spacing: 8,
  children: [
    OutlinedButton(onPressed: () {}, child: const Text('Preview')),
    FilledButton(onPressed: () {}, child: const Text('Publish')),
  ],
)
```

The first chosen direction stays locked until one of these happens:

- `maintainLayout` is set back to `false`.
- `primaryDirection` changes.
- The render object is recreated, for example by changing the widget key.

Spacing, alignment, and `measurementStrategy` changes relayout the locked axis;
they do not clear the lock by themselves.

## Direction Change Callback

Use `onLayoutDirectionChanged` to coordinate external animation or state with
the resolved row or column.

```dart
SingleAxisWrap(
  spacing: 8,
  onLayoutDirectionChanged: (direction) {
    debugPrint(
      'SingleAxisWrap changed to '
      '${direction == Axis.horizontal ? 'row' : 'column'}',
    );
  },
  children: [
    TextButton(onPressed: () {}, child: const Text('Later')),
    FilledButton(onPressed: () {}, child: const Text('Continue')),
  ],
)
```

The callback is scheduled after layout, so it is safe to call `setState` from
it. It is not called for the initial layout because there is no previous
direction. If several changes occur in the same frame, only the latest pending
notification is delivered.

## Measurement Strategy

Most apps should keep the default:

```dart
SingleAxisWrap(
  measurementStrategy: MeasurementStrategy.layout,
  children: children,
)
```

`MeasurementStrategy.layout` performs a real primary-axis layout during
`performLayout`. If that layout fits, the result is reused. If it does not fit,
children are laid out once more in the fallback axis. Dry layout uses equivalent
dry measurements so parents receive a consistent size answer.

Children must tolerate the primary-axis fit-check constraints. For example,
horizontal-first layout first measures children with unbounded width, like
non-flex children in a `Row`.

`MeasurementStrategy.intrinsic` uses intrinsic dimensions for the fit decision.
Use it only after profiling shows the default strategy is too expensive. It can
choose differently for children whose intrinsic size differs from their laid-out
size, such as wrapping `Text`.

`MeasurementStrategy.preferPrimary` is deprecated in `1.0.3`. It is equivalent
to `MeasurementStrategy.layout`, because the default strategy already keeps the
primary direction when the primary main axis is unbounded.

## Overflow And Clipping

The fallback direction is not guaranteed to fit. If both axes are too small,
children may visually overflow.

```dart
SingleAxisWrap(
  clipBehavior: Clip.hardEdge,
  spacing: 8,
  children: const [
    SizedBox(width: 200, height: 80),
    SizedBox(width: 200, height: 80),
  ],
)
```

`Clip.none` allows overflowing children to paint outside the widget, but it does
not expand hit testing outside the widget's own bounds.

## Common Patterns

### Toggle Buttons

```dart
SingleAxisWrap(
  spacing: 8,
  children: [
    ElevatedButton(onPressed: () {}, child: const Text('Option 1')),
    ElevatedButton(onPressed: () {}, child: const Text('Option 2')),
    ElevatedButton(onPressed: () {}, child: const Text('Option 3')),
  ],
)
```

### Filter Chips

```dart
SingleAxisWrap(
  spacing: 8,
  horizontalCrossAxisAlignment: WrapCrossAlignment.center,
  children: [
    FilterChip(label: const Text('Category 1'), onSelected: (_) {}),
    FilterChip(label: const Text('Category 2'), onSelected: (_) {}),
    FilterChip(label: const Text('Category 3'), onSelected: (_) {}),
  ],
)
```

### Navigation Items

```dart
SingleAxisWrap(
  spacing: 16,
  horizontalAlignment: WrapAlignment.spaceEvenly,
  verticalAlignment: WrapAlignment.start,
  children: const [
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(Icons.home), SizedBox(width: 4), Text('Home')],
    ),
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(Icons.search), SizedBox(width: 4), Text('Search')],
    ),
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(Icons.person), SizedBox(width: 4), Text('Profile')],
    ),
  ],
)
```

## API Reference

```dart
SingleAxisWrap({
  Key? key,
  required List<Widget> children,
  Axis primaryDirection = Axis.horizontal,
  double spacing = 0.0,
  double? horizontalSpacing,
  double? verticalSpacing,
  WrapAlignment horizontalAlignment = WrapAlignment.start,
  WrapAlignment verticalAlignment = WrapAlignment.start,
  WrapCrossAlignment horizontalCrossAxisAlignment = WrapCrossAlignment.start,
  WrapCrossAlignment verticalCrossAxisAlignment = WrapCrossAlignment.start,
  TextDirection? textDirection,
  VerticalDirection verticalDirection = VerticalDirection.down,
  Clip clipBehavior = Clip.none,
  LayoutDirectionCallback? onLayoutDirectionChanged,
  bool maintainLayout = false,
  MeasurementStrategy measurementStrategy = MeasurementStrategy.layout,
})
```

| Property | Type | Behavior |
|---|---|---|
| `children` | `List<Widget>` | Widgets laid out together in one final row or one final column. |
| `primaryDirection` | `Axis` | Axis measured first. Defaults to `Axis.horizontal`. |
| `spacing` | `double` | Default finite, non-negative gap between adjacent children. |
| `horizontalSpacing` | `double?` | Gap used only when the final layout is horizontal. Falls back to `spacing`. |
| `verticalSpacing` | `double?` | Gap used only when the final layout is vertical. Falls back to `spacing`. |
| `horizontalAlignment` | `WrapAlignment` | Main-axis alignment for the horizontal final layout. |
| `verticalAlignment` | `WrapAlignment` | Main-axis alignment for the vertical final layout. |
| `horizontalCrossAxisAlignment` | `WrapCrossAlignment` | Cross-axis alignment for the horizontal final layout. |
| `verticalCrossAxisAlignment` | `WrapCrossAlignment` | Cross-axis alignment for the vertical final layout. |
| `textDirection` | `TextDirection?` | Resolves horizontal order and horizontal `start` / `end`. Uses ambient `Directionality` when null. |
| `verticalDirection` | `VerticalDirection` | Resolves vertical order and vertical `start` / `end`. |
| `clipBehavior` | `Clip` | Clips paint overflow when overflow exists. `Clip.none` does not expand hit testing. |
| `onLayoutDirectionChanged` | `LayoutDirectionCallback?` | Called after an existing resolved direction changes. Not called for the initial layout. |
| `maintainLayout` | `bool` | Locks the first chosen direction until explicitly reset. |
| `measurementStrategy` | `MeasurementStrategy` | Controls how the fit decision measures children. Defaults to `layout`. |

## Compared To Built-In Widgets

| Feature | `SingleAxisWrap` | `OverflowBar` | `Wrap` | `Row` / `Column` |
|---|---|---|---|---|
| Automatic row/column fallback | Yes | Yes, row to column | No, wraps into runs | No |
| Single axis only, no partial wrapping | Yes | Yes | No | Yes |
| Horizontal-first or vertical-first | Yes | No, row-first only | Not applicable | No, fixed by widget choice |
| Main-axis alignment in fallback | Full `WrapAlignment` | Start, center, end | Full `WrapAlignment` per run | Not applicable |
| Cross-axis alignment | Configurable per final axis | Centered | Configurable | Configurable |
| Separate row/column spacing | Yes | Yes | `spacing` and `runSpacing` | Fixed-axis spacing only |
| Fallback child order | `textDirection` / `verticalDirection` | `overflowDirection` | Not applicable | Not applicable |
| Maintain chosen axis while resizing | Yes | No | Not applicable | Not applicable |
| Direction-change callback | Yes | No | No | No |
| RTL support | Yes | Yes | Yes | Yes |

## Contributing

Contributions are welcome. Please open an issue or pull request on GitHub.

## License

This project is licensed under the BSD 3-Clause License. See [LICENSE](LICENSE) for details.

## Support

<a href="https://www.buymeacoffee.com/omar.hanafy" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>
