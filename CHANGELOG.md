# Changelog

## 1.0.3-dev.1

- Fixed dry layout and real layout parity when the primary direction does not fit.
- Stabilized intrinsic size calculations so they no longer depend on previous layout state and respect finite opposite-axis queries.
- Fixed RTL, `verticalDirection`, and single-child `spaceBetween` positioning semantics.
- Fixed unbounded constraint handling, narrowed `MeasurementStrategy.preferPrimary`, and prevented infinite sizes for space-based alignments.
- Deprecated `MeasurementStrategy.preferPrimary`; use `MeasurementStrategy.layout` instead.
- Tightened spacing validation, direction-change callback delivery, and clip semantics invalidation.
- Added dry baseline and approximate paint clip support.
- Expanded render-contract test coverage and clarified layout decision documentation.

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
