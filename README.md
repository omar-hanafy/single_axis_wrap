<h1 align="center">SingleAxisWrap</h1>

<p align="center">
  <a href="https://pub.dev/packages/single_axis_wrap"><img src="https://img.shields.io/pub/v/single_axis_wrap.svg" alt="Pub"></a>
  <a href="https://github.com/omar-hanafy/single_axis_wrap/stargazers"><img src="https://img.shields.io/github/stars/omar-hanafy/single_axis_wrap" alt="Stars"></a>
  <a href="https://github.com/omar-hanafy/single_axis_wrap/blob/main/LICENSE"><img src="https://img.shields.io/github/license/omar-hanafy/single_axis_wrap" alt="License"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Platform-Flutter-02569B?logo=flutter" alt="Platform"></a>
</p>

A Flutter widget that automatically decides between row or column layout based on available space. 

Unlike Flutter's built-in `Wrap` widget, which can mix horizontal and vertical layouts by wrapping to new lines, `SingleAxisWrap` makes an "all or nothing" layout decision: either all children in a single row, or all children in a single column.

<p align="center">
  <img src="https://raw.githubusercontent.com/omar-hanafy/single_axis_wrap/refs/heads/main/assets/demo.gif" width="60%" alt="Cover">
</p>

## Features

- **Automatic Layout Decision**: Seamlessly switches between row and column layouts based on available space
- **RTL Support**: Fully supports right-to-left languages and layouts
- **Layout Persistence**: Option to maintain the chosen layout when constraints change slightly
- **Customizable Spacing**: Separate spacing options for horizontal and vertical layouts
- **Flexible Alignment**: Control alignment in both main and cross axes
- **Change Callbacks**: Get notified when layout direction changes
- **Lightweight**: No external dependencies

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  single_axis_wrap: ^1.0.1
```

## Usage

### Basic Example

```dart
SingleAxisWrap(
  primaryDirection: Axis.horizontal,
  spacing: 8.0,
  children: [
    Container(width: 100, height: 50, color: Colors.blue),
    Container(width: 100, height: 50, color: Colors.green),
    Container(width: 100, height: 50, color: Colors.red),
  ],
)
```

This will display all items in a row if there's enough horizontal space, otherwise it will switch to a column layout.

### With Alignment

```dart
SingleAxisWrap(
  primaryDirection: Axis.horizontal,
  spacing: 8.0,
  horizontalAlignment: WrapAlignment.center,
  verticalAlignment: WrapAlignment.spaceEvenly,
  horizontalCrossAxisAlignment: WrapCrossAlignment.center,
  verticalCrossAxisAlignment: WrapCrossAlignment.end,
  children: [
    Container(width: 100, height: 50, color: Colors.blue),
    Container(width: 100, height: 50, color: Colors.green),
    Container(width: 100, height: 50, color: Colors.red),
  ],
)
```

### Maintaining Layout During Animations

```dart
SingleAxisWrap(
  primaryDirection: Axis.horizontal,
  spacing: 8.0,
  maintainLayout: true, // Prevents unwanted layout changes
  children: [
    Container(width: 100, height: 50, color: Colors.blue),
    Container(width: 100, height: 50, color: Colors.green),
    Container(width: 100, height: 50, color: Colors.red),
  ],
)
```

### Responding to Layout Changes

```dart
SingleAxisWrap(
  primaryDirection: Axis.horizontal,
  spacing: 8.0,
  onLayoutDirectionChanged: (direction) {
    print('Layout changed to: ${direction == Axis.horizontal ? 'Row' : 'Column'}');
    // Trigger animations or state changes
  },
  children: [
    Container(width: 100, height: 50, color: Colors.blue),
    Container(width: 100, height: 50, color: Colors.green),
    Container(width: 100, height: 50, color: Colors.red),
  ],
)
```

## Full API Reference

### Constructor

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
  void Function(Axis)? onLayoutDirectionChanged,
  bool maintainLayout = false,
})
```

### Properties

| Property                       | Type                 | Description                                                                                   |
|--------------------------------|----------------------|-----------------------------------------------------------------------------------------------|
| `primaryDirection`             | `Axis`               | The primary layout direction to attempt first.                                                |
| `spacing`                      | `double`             | Default spacing between children in both layouts.                                             |
| `horizontalSpacing`            | `double?`            | Spacing between children when in horizontal (row) layout. If null, falls back to `spacing`.   |
| `verticalSpacing`              | `double?`            | Spacing between children when in vertical (column) layout. If null, falls back to `spacing`.  |
| `horizontalAlignment`          | `WrapAlignment`      | Alignment of children along the main axis when in horizontal (row) layout.                    |
| `verticalAlignment`            | `WrapAlignment`      | Alignment of children along the main axis when in vertical (column) layout.                   |
| `horizontalCrossAxisAlignment` | `WrapCrossAlignment` | Alignment of children along the cross axis when in horizontal (row) layout.                   |
| `verticalCrossAxisAlignment`   | `WrapCrossAlignment` | Alignment of children along the cross axis when in vertical (column) layout.                  |
| `textDirection`                | `TextDirection?`     | Determines the order to lay children out horizontally and how to interpret `start` and `end`. |
| `verticalDirection`            | `VerticalDirection`  | Determines the order to lay children out vertically and how to interpret `start` and `end`.   |
| `clipBehavior`                 | `Clip`               | How to clip children that exceed the size of the container.                                   |
| `onLayoutDirectionChanged`     | `Function(Axis)?`    | Called when the layout direction changes between horizontal and vertical.                     |
| `maintainLayout`               | `bool`               | Whether to maintain the current layout direction once chosen, even if constraints change.     |

## Common Use Cases

### Toggle Buttons

Create toggle buttons that are either all in a row or all in a column:

```dart
SingleAxisWrap(
  spacing: 8.0,
  children: [
    ElevatedButton(onPressed: () {}, child: Text('Option 1')),
    ElevatedButton(onPressed: () {}, child: Text('Option 2')),
    ElevatedButton(onPressed: () {}, child: Text('Option 3')),
  ],
)
```

### Filter Chips

Display filter chips that don't partially wrap:

```dart
SingleAxisWrap(
  spacing: 8.0,
  horizontalCrossAxisAlignment: WrapCrossAlignment.center,
  children: [
    FilterChip(label: Text('Category 1'), onSelected: (_) {}),
    FilterChip(label: Text('Category 2'), onSelected: (_) {}),
    FilterChip(label: Text('Category 3'), onSelected: (_) {}),
  ],
)
```

### Navigation Items

Create navigation items that adapt to available space:

```dart
SingleAxisWrap(
  spacing: 16.0,
  horizontalAlignment: WrapAlignment.spaceEvenly,
  verticalAlignment: WrapAlignment.start,
  children: [
    NavigationItem(icon: Icons.home, label: 'Home'),
    NavigationItem(icon: Icons.search, label: 'Search'),
    NavigationItem(icon: Icons.person, label: 'Profile'),
  ],
)
```

## Compared to Other Solutions

| Feature                            | SingleAxisWrap | Wrap | Flex (Row/Column) |
|------------------------------------|----------------|------|-------------------|
| Automatic row/column decision      | ✅              | ✅    | ❌                 |
| Single axis only                   | ✅              | ❌    | ✅                 |
| RTL support                        | ✅              | ✅    | ✅                 |
| Maintains layout during animations | ✅              | N/A  | N/A               |
| Layout change notifications        | ✅              | ❌    | ❌                 |

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## License
This project is licensed under the MIT License—see the LICENSE file for details.

## Support
<a href="https://www.buymeacoffee.com/omar.hanafy" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>
