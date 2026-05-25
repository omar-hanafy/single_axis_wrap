/// Adaptive single-axis layout widgets for Flutter.
///
/// Import this library to use [SingleAxisWrap], a widget that chooses one
/// complete layout axis at a time instead of wrapping children into multiple
/// runs.
///
/// See also:
///
/// * [MeasurementStrategy], which controls how children are measured for the
///   axis-fit decision.
/// * [LayoutDirectionCallback], the signature for the notification fired when
///   the chosen axis changes.
library;

export 'src/single_axis_wrap.dart';
export 'src/single_axis_wrap_types.dart';
