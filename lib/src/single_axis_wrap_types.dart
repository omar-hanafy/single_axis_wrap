import 'package:flutter/widgets.dart';

/// Called after `SingleAxisWrap` changes between row and column layout.
///
/// The callback receives the resolved layout direction after a completed layout
/// pass. It is useful for coordinating parent state or animations with the
/// final axis, but it is not called for the initial layout because no previous
/// direction exists.
typedef LayoutDirectionCallback = void Function(Axis layoutDirection);

/// Controls how `SingleAxisWrap` measures children for its fit decision.
///
/// The strategy only affects the decision step. The final child layout still
/// uses the chosen axis and the current [BoxConstraints].
enum MeasurementStrategy {
  /// Measures children with layout-compatible constraints.
  ///
  /// This is the default and the most accurate option. During real layout,
  /// children are laid out in the primary direction and reused when they fit.
  /// During dry layout, equivalent dry measurements are used so
  /// [RenderBox.computeDryLayout] stays consistent with real layout.
  layout,

  /// Measures children with intrinsic dimensions before choosing an axis.
  ///
  /// Use this only after profiling shows the default strategy is too expensive.
  /// It can make a different decision for children whose intrinsic size differs
  /// from their laid-out size, such as wrapping [Text] or custom render boxes
  /// that resolve size from constraints.
  intrinsic,

  /// Deprecated alias for [layout].
  ///
  /// Earlier versions allowed this as a readability signal for scroll views or
  /// other parents that leave the primary main axis unconstrained. The default
  /// [layout] strategy now keeps the primary direction in that case, so this no
  /// longer changes layout results.
  @Deprecated(
    'MeasurementStrategy.preferPrimary is equivalent to '
    'MeasurementStrategy.layout. Use MeasurementStrategy.layout instead.',
  )
  preferPrimary,
}
