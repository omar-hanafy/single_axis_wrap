# Changelog

## 1.0.3

- Fixed dry layout and real layout parity when the primary direction falls back.
- Stabilized intrinsic sizing, including finite opposite-axis queries.
- Fixed RTL, `verticalDirection`, and single-child `spaceBetween` positioning semantics.
- Fixed unbounded constraint handling and finite spacing validation.
- Deprecated `MeasurementStrategy.preferPrimary`; use `MeasurementStrategy.layout` instead.
- Improved direction-change callback delivery, dry baseline support, and clipping semantics.
- Clarified layout decisions, constraints, `maintainLayout`, callbacks, and measurement strategies in the docs.

## 1.0.2

- Organized code and enhanced code documentation.

## 1.0.1

- Added demo in the readme.

## 1.0.0

### Initial release

- Introduced `SingleAxisWrap` widget that automatically chooses between row and column layouts based on available space
- Implemented robust RTL (right-to-left) support
- Added customizable spacing for both horizontal and vertical layouts
- Added alignment options using WrapAlignment and WrapCrossAlignment
- Implemented `maintainLayout` feature to prevent unwanted layout changes during animations
- Added `onLayoutDirectionChanged` callback for reacting to layout changes
- Comprehensive test suite ensuring widget reliability
- Full documentation and examples
