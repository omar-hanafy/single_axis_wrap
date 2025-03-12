import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:single_axis_wrap/src/single_axis_wrap_parent_data.dart';

/// Callback for when the layout direction changes between horizontal and vertical.
typedef LayoutDirectionCallback = void Function(Axis layoutDirection);

/// Strategy for measuring children when determining if they fit in a direction.
enum MeasurementStrategy {
  /// Use layout measurements for accurate sizing (default).
  /// More accurate but potentially more expensive.
  layout,

  /// Use intrinsic size measurements.
  /// Less accurate but potentially faster.
  intrinsic,

  /// Prefer the primary direction when one or both directions have unbounded constraints.
  /// Useful when you want to enforce a direction despite unbounded constraints.
  preferPrimary,
}

/// A widget that lays out its children either in a single row or a single column,
/// making an "all or nothing" layout decision based on available space.
///
/// Unlike [Wrap], which can mix horizontal and vertical layouts by wrapping to new lines,
/// [SingleAxisWrap] will commit fully to either a row or a column layout based on whether
/// all children can fit in the primary direction.
///
/// For example, if [primaryDirection] is [Axis.horizontal], SingleAxisWrap will attempt to
/// place all children in a row. If they don't fit within the available width, it will
/// switch to a column layout instead.
class SingleAxisWrap extends MultiChildRenderObjectWidget {
  /// Creates a widget that makes an "all or nothing" layout decision between row and column.
  ///
  /// By default, it attempts to lay out children in a horizontal row first.
  const SingleAxisWrap({
    required super.children,
    super.key,
    this.primaryDirection = Axis.horizontal,
    this.spacing = 0.0,
    this.horizontalSpacing,
    this.verticalSpacing,
    this.horizontalAlignment = WrapAlignment.start,
    this.verticalAlignment = WrapAlignment.start,
    this.horizontalCrossAxisAlignment = WrapCrossAlignment.start,
    this.verticalCrossAxisAlignment = WrapCrossAlignment.start,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.clipBehavior = Clip.none,
    this.onLayoutDirectionChanged,
    this.maintainLayout = false,
    this.measurementStrategy = MeasurementStrategy.layout,
  })  : assert(spacing >= 0.0, 'Spacing must be non-negative'),
        assert(horizontalSpacing == null || horizontalSpacing >= 0.0,
            'Horizontal spacing must be non-negative'),
        assert(verticalSpacing == null || verticalSpacing >= 0.0,
            'Vertical spacing must be non-negative');

  /// The primary direction to attempt first.
  ///
  /// If set to [Axis.horizontal], SingleAxisWrap will try to lay out all children
  /// in a single row. If they don't fit, it will use a column layout instead.
  ///
  /// If set to [Axis.vertical], SingleAxisWrap will try to lay out all children
  /// in a single column. If they don't fit, it will use a row layout instead.
  final Axis primaryDirection;

  /// Default spacing between children in both layouts.
  ///
  /// This value is used for both horizontal and vertical spacing unless
  /// [horizontalSpacing] or [verticalSpacing] are specifically provided.
  final double spacing;

  /// Spacing between children when in horizontal (row) layout.
  ///
  /// If null, [spacing] is used instead.
  final double? horizontalSpacing;

  /// Spacing between children when in vertical (column) layout.
  ///
  /// If null, [spacing] is used instead.
  final double? verticalSpacing;

  /// Alignment of children along the main axis when in horizontal (row) layout.
  final WrapAlignment horizontalAlignment;

  /// Alignment of children along the main axis when in vertical (column) layout.
  final WrapAlignment verticalAlignment;

  /// Alignment of children along the cross axis when in horizontal (row) layout.
  final WrapCrossAlignment horizontalCrossAxisAlignment;

  /// Alignment of children along the cross axis when in vertical (column) layout.
  final WrapCrossAlignment verticalCrossAxisAlignment;

  /// Determines the order to lay children out horizontally and how to interpret
  /// `start` and `end` in the horizontal direction.
  ///
  /// If null, defaults to the ambient [Directionality].
  final TextDirection? textDirection;

  /// Determines the order to lay children out vertically and how to interpret
  /// `start` and `end` in the vertical direction.
  final VerticalDirection verticalDirection;

  /// How to clip children that exceed the size of the container.
  final Clip clipBehavior;

  /// Called when the layout direction changes.
  ///
  /// This callback is useful for coordinating animations or other visual changes
  /// when the layout switches between horizontal and vertical.
  final LayoutDirectionCallback? onLayoutDirectionChanged;

  /// Whether to maintain the current layout direction once chosen.
  ///
  /// If true, once a layout direction is chosen (row or column), it will be
  /// maintained even if the constraints change, preventing the layout from
  /// flipping back and forth as the container size changes.
  ///
  /// This is useful to prevent unwanted layout changes during animations or
  /// when the available space fluctuates.
  final bool maintainLayout;

  /// Strategy to use when measuring children to determine if they fit.
  ///
  /// This affects how children are measured during the layout decision phase.
  final MeasurementStrategy measurementStrategy;

  @override
  RenderSingleAxisWrap createRenderObject(BuildContext context) {
    return RenderSingleAxisWrap(
      primaryDirection: primaryDirection,
      spacing: spacing,
      horizontalSpacing: horizontalSpacing,
      verticalSpacing: verticalSpacing,
      horizontalAlignment: horizontalAlignment,
      verticalAlignment: verticalAlignment,
      horizontalCrossAxisAlignment: horizontalCrossAxisAlignment,
      verticalCrossAxisAlignment: verticalCrossAxisAlignment,
      textDirection: textDirection ?? Directionality.of(context),
      verticalDirection: verticalDirection,
      clipBehavior: clipBehavior,
      onLayoutDirectionChanged: onLayoutDirectionChanged,
      maintainLayout: maintainLayout,
      measurementStrategy: measurementStrategy,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderSingleAxisWrap renderObject) {
    renderObject
      ..primaryDirection = primaryDirection
      ..spacing = spacing
      ..horizontalSpacing = horizontalSpacing
      ..verticalSpacing = verticalSpacing
      ..horizontalAlignment = horizontalAlignment
      ..verticalAlignment = verticalAlignment
      ..horizontalCrossAxisAlignment = horizontalCrossAxisAlignment
      ..verticalCrossAxisAlignment = verticalCrossAxisAlignment
      ..textDirection = textDirection ?? Directionality.of(context)
      ..verticalDirection = verticalDirection
      ..clipBehavior = clipBehavior
      ..onLayoutDirectionChanged = onLayoutDirectionChanged
      ..maintainLayout = maintainLayout
      ..measurementStrategy = measurementStrategy;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<Axis>('primaryDirection', primaryDirection))
      ..add(DoubleProperty('spacing', spacing))
      ..add(DoubleProperty('horizontalSpacing', horizontalSpacing))
      ..add(DoubleProperty('verticalSpacing', verticalSpacing))
      ..add(EnumProperty<WrapAlignment>(
          'horizontalAlignment', horizontalAlignment))
      ..add(EnumProperty<WrapAlignment>('verticalAlignment', verticalAlignment))
      ..add(EnumProperty<WrapCrossAlignment>(
          'horizontalCrossAxisAlignment', horizontalCrossAxisAlignment))
      ..add(EnumProperty<WrapCrossAlignment>(
          'verticalCrossAxisAlignment', verticalCrossAxisAlignment))
      ..add(EnumProperty<TextDirection>('textDirection', textDirection,
          defaultValue: null))
      ..add(EnumProperty<VerticalDirection>(
          'verticalDirection', verticalDirection))
      ..add(EnumProperty<Clip>('clipBehavior', clipBehavior))
      ..add(EnumProperty<MeasurementStrategy>(
          'measurementStrategy', measurementStrategy))
      ..add(FlagProperty('maintainLayout',
          value: maintainLayout, ifTrue: 'enabled', ifFalse: 'disabled'));
  }
}
