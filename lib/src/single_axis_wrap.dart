import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:single_axis_wrap/src/single_axis_wrap_parent_data.dart';
import 'package:single_axis_wrap/src/single_axis_wrap_types.dart';

export 'single_axis_wrap_types.dart';

/// Lays out children in either one complete row or one complete column.
///
/// Unlike [Wrap], which can place children into multiple runs,
/// [SingleAxisWrap] commits to one axis for every child. It first tries
/// [primaryDirection]. If the primary main axis is finite and all children plus
/// spacing fit, that axis is used. Otherwise the opposite axis is used.
///
/// This is closest to [OverflowBar], but it supports both horizontal-first and
/// vertical-first layouts, separate alignment for each final axis, and a
/// direction-change callback.
///
/// If the primary main axis is unbounded, the primary direction is kept because
/// there is no finite limit to overflow. The fallback axis can still overflow
/// when it is also too small; use [clipBehavior] to control paint clipping in
/// that case.
///
/// A button group that arranges actions in a row when space allows and falls
/// back to a column on narrow screens:
///
/// ```dart
/// SingleAxisWrap(
///   spacing: 8,
///   horizontalAlignment: WrapAlignment.end,
///   children: [
///     TextButton(onPressed: () {}, child: Text('Cancel')),
///     ElevatedButton(onPressed: () {}, child: Text('Save')),
///   ],
/// )
/// ```
class SingleAxisWrap extends MultiChildRenderObjectWidget {
  /// Creates a layout that chooses one axis for all [children].
  ///
  /// By default, it attempts a horizontal row first with no spacing and start
  /// alignment. [spacing], [horizontalSpacing], and [verticalSpacing] must be
  /// finite and non-negative.
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
  }) : assert(
         spacing >= 0.0 && spacing < double.infinity,
         'Spacing must be finite and non-negative',
       ),
       assert(
         horizontalSpacing == null ||
             (horizontalSpacing >= 0.0 && horizontalSpacing < double.infinity),
         'Horizontal spacing must be finite and non-negative',
       ),
       assert(
         verticalSpacing == null ||
             (verticalSpacing >= 0.0 && verticalSpacing < double.infinity),
         'Vertical spacing must be finite and non-negative',
       );

  /// The axis attempted before falling back to the opposite axis.
  ///
  /// If set to [Axis.horizontal], all children are first measured as one row.
  /// If the row does not fit a finite width, the widget uses a column.
  ///
  /// If set to [Axis.vertical], all children are first measured as one column.
  /// If the column does not fit a finite height, the widget uses a row.
  ///
  /// If the primary main axis is unbounded, the primary direction is used
  /// because there is no finite main-axis limit to exceed.
  final Axis primaryDirection;

  /// Default gap between adjacent children in either final layout.
  ///
  /// This value is used for both axes unless [horizontalSpacing] or
  /// [verticalSpacing] is provided. It must be finite and non-negative.
  final double spacing;

  /// Gap between adjacent children when the final layout is horizontal.
  ///
  /// If null, [spacing] is used. When provided, it must be finite and
  /// non-negative.
  final double? horizontalSpacing;

  /// Gap between adjacent children when the final layout is vertical.
  ///
  /// If null, [spacing] is used. When provided, it must be finite and
  /// non-negative.
  final double? verticalSpacing;

  /// Main-axis alignment used when the final layout is horizontal.
  ///
  /// The `start` and `end` values are resolved using [textDirection]. Space
  /// based values expand only when the incoming horizontal constraint is finite;
  /// otherwise the widget shrink-wraps its children.
  ///
  /// Non-space values such as [WrapAlignment.center] and [WrapAlignment.end]
  /// distribute only the space inside this widget's actual width. In loose
  /// constraints, the widget can shrink-wrap its children, leaving no extra
  /// horizontal space for those values to visibly move children.
  final WrapAlignment horizontalAlignment;

  /// Main-axis alignment used when the final layout is vertical.
  ///
  /// The `start` and `end` values are resolved using [verticalDirection]. Space
  /// based values expand only when the incoming vertical constraint is finite;
  /// otherwise the widget shrink-wraps its children.
  ///
  /// Non-space values such as [WrapAlignment.center] and [WrapAlignment.end]
  /// distribute only the space inside this widget's actual height. In loose
  /// constraints, the widget can shrink-wrap its children, leaving no extra
  /// vertical space for those values to visibly move children.
  final WrapAlignment verticalAlignment;

  /// Cross-axis alignment used when the final layout is horizontal.
  ///
  /// The `start` and `end` values are resolved using [verticalDirection].
  final WrapCrossAlignment horizontalCrossAxisAlignment;

  /// Cross-axis alignment used when the final layout is vertical.
  ///
  /// The `start` and `end` values are resolved using [textDirection].
  final WrapCrossAlignment verticalCrossAxisAlignment;

  /// Resolves horizontal child order and horizontal `start` / `end` alignment.
  ///
  /// If null, the widget reads the ambient [Directionality] during build. A
  /// [Directionality] ancestor is therefore required unless this is provided.
  final TextDirection? textDirection;

  /// Resolves vertical child order and vertical `start` / `end` alignment.
  ///
  /// [VerticalDirection.down] places the first child near the top in vertical
  /// layouts. [VerticalDirection.up] places the first child near the bottom.
  final VerticalDirection verticalDirection;

  /// Controls paint clipping when children exceed this widget's final size.
  ///
  /// Clipping is only applied when visual overflow exists. Defaults to
  /// [Clip.none], which allows overflowing children to paint outside the box.
  /// Like most [RenderBox] widgets, hit testing remains limited to this
  /// widget's own bounds.
  final Clip clipBehavior;

  /// Called after the final layout direction changes.
  ///
  /// Use this to coordinate external animation or state with the chosen axis.
  /// The callback is scheduled after layout, so it is safe to call `setState`
  /// from it.
  ///
  /// It is not called for the initial layout because there is no previous
  /// direction to change from. If multiple direction changes are scheduled in
  /// one frame, only the latest pending notification is delivered.
  final LayoutDirectionCallback? onLayoutDirectionChanged;

  /// Whether to keep the currently chosen layout direction.
  ///
  /// When true, the first chosen direction is reused even if later constraints
  /// would choose the opposite axis. This avoids row-column flicker while a
  /// parent is resizing or animating.
  ///
  /// The direction stays locked until this widget is rebuilt with
  /// [maintainLayout] set to false, [primaryDirection] changes, or the render
  /// object is recreated. Changes to spacing, alignment, or
  /// [measurementStrategy] relayout the existing locked direction; they do not
  /// clear the lock by themselves.
  final bool maintainLayout;

  /// Measurement strategy used for the axis fit decision.
  ///
  /// Most users should keep the default [MeasurementStrategy.layout]. Use
  /// [MeasurementStrategy.intrinsic] only after profiling.
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
    BuildContext context,
    RenderSingleAxisWrap renderObject,
  ) {
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
      ..add(
        EnumProperty<WrapAlignment>('horizontalAlignment', horizontalAlignment),
      )
      ..add(EnumProperty<WrapAlignment>('verticalAlignment', verticalAlignment))
      ..add(
        EnumProperty<WrapCrossAlignment>(
          'horizontalCrossAxisAlignment',
          horizontalCrossAxisAlignment,
        ),
      )
      ..add(
        EnumProperty<WrapCrossAlignment>(
          'verticalCrossAxisAlignment',
          verticalCrossAxisAlignment,
        ),
      )
      ..add(
        EnumProperty<TextDirection>(
          'textDirection',
          textDirection,
          defaultValue: null,
        ),
      )
      ..add(
        EnumProperty<VerticalDirection>('verticalDirection', verticalDirection),
      )
      ..add(EnumProperty<Clip>('clipBehavior', clipBehavior))
      ..add(
        EnumProperty<MeasurementStrategy>(
          'measurementStrategy',
          measurementStrategy,
        ),
      )
      ..add(
        FlagProperty(
          'maintainLayout',
          value: maintainLayout,
          ifTrue: 'enabled',
          ifFalse: 'disabled',
        ),
      );
  }
}
