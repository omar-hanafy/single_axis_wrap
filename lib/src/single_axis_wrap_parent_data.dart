// ignore_for_file: prefer_initializing_formals, unnecessary_getters_setters

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import 'package:single_axis_wrap/src/single_axis_wrap_types.dart';

/// Stores the physical paint offset assigned by [RenderSingleAxisWrap].
///
/// Each child receives this data during layout. Consumers normally interact
/// with `SingleAxisWrap` instead of reading this class directly.
class SingleAxisWrapParentData extends ContainerBoxParentData<RenderBox> {
  @override
  String toString() => 'offset=$offset';
}

/// Render object that chooses either one row or one column for all children.
///
/// The object first measures [primaryDirection]. If the primary main axis is
/// finite and the children plus spacing do not fit, it lays out the opposite
/// axis instead.
///
/// Dry layout and dry baselines use the same axis decision as [performLayout].
/// Intrinsic dimensions use the maintained direction when locked. Otherwise
/// minimum intrinsic values expose the compact fallback shape where that axis
/// can shrink, while maximum values keep the preferred all-in-primary-axis
/// shape. Queries that provide the primary main-axis limit still reproduce
/// fallback from that limit.
///
/// Prefer using `SingleAxisWrap` unless you are composing render objects
/// directly.
class RenderSingleAxisWrap extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, SingleAxisWrapParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, SingleAxisWrapParentData> {
  /// Creates the render object used by `SingleAxisWrap`.
  ///
  /// The widget resolves nullable configuration before constructing this
  /// object. In particular, [textDirection] must already be non-null.
  RenderSingleAxisWrap({
    required Axis primaryDirection,
    required double spacing,
    required double? horizontalSpacing,
    required double? verticalSpacing,
    required WrapAlignment horizontalAlignment,
    required WrapAlignment verticalAlignment,
    required WrapCrossAlignment horizontalCrossAxisAlignment,
    required WrapCrossAlignment verticalCrossAxisAlignment,
    required TextDirection textDirection,
    required VerticalDirection verticalDirection,
    required Clip clipBehavior,
    required LayoutDirectionCallback? onLayoutDirectionChanged,
    required bool maintainLayout,
    required MeasurementStrategy measurementStrategy,
    List<RenderBox>? children,
  }) : assert(
         spacing >= 0.0 && spacing.isFinite,
         'Spacing must be finite and non-negative',
       ),
       assert(
         horizontalSpacing == null ||
             (horizontalSpacing >= 0.0 && horizontalSpacing.isFinite),
         'Horizontal spacing must be finite and non-negative',
       ),
       assert(
         verticalSpacing == null ||
             (verticalSpacing >= 0.0 && verticalSpacing.isFinite),
         'Vertical spacing must be finite and non-negative',
       ),
       _primaryDirection = primaryDirection,
       _spacing = spacing,
       _horizontalSpacing = horizontalSpacing,
       _verticalSpacing = verticalSpacing,
       _horizontalAlignment = horizontalAlignment,
       _verticalAlignment = verticalAlignment,
       _horizontalCrossAxisAlignment = horizontalCrossAxisAlignment,
       _verticalCrossAxisAlignment = verticalCrossAxisAlignment,
       _textDirection = textDirection,
       _verticalDirection = verticalDirection,
       _clipBehavior = clipBehavior,
       _onLayoutDirectionChanged = onLayoutDirectionChanged,
       _maintainLayout = maintainLayout,
       _measurementStrategy = measurementStrategy {
    addAll(children);
  }

  /// The layout axis measured before the fallback axis.
  ///
  /// Changing this resets the maintained direction, because the existing lock
  /// may no longer match the caller's preferred layout.
  Axis get primaryDirection => _primaryDirection;
  Axis _primaryDirection;

  set primaryDirection(Axis value) {
    if (_primaryDirection == value) return;
    _primaryDirection = value;
    _currentLayoutDirection = null;
    markNeedsLayout();
  }

  /// Default non-negative gap between adjacent children.
  ///
  /// Used when [horizontalSpacing] or [verticalSpacing] is null.
  double get spacing => _spacing;
  double _spacing;

  set spacing(double value) {
    assert(
      value >= 0.0 && value.isFinite,
      'Spacing must be finite and non-negative',
    );
    if (_spacing == value) return;
    _spacing = value;
    markNeedsLayout();
  }

  /// Horizontal-layout gap between adjacent children.
  ///
  /// A null value falls back to [spacing]. Non-null values must be
  /// non-negative.
  double? get horizontalSpacing => _horizontalSpacing;
  double? _horizontalSpacing;

  set horizontalSpacing(double? value) {
    assert(
      value == null || (value >= 0.0 && value.isFinite),
      'Horizontal spacing must be finite and non-negative',
    );
    if (_horizontalSpacing == value) return;
    _horizontalSpacing = value;
    markNeedsLayout();
  }

  /// Vertical-layout gap between adjacent children.
  ///
  /// A null value falls back to [spacing]. Non-null values must be
  /// non-negative.
  double? get verticalSpacing => _verticalSpacing;
  double? _verticalSpacing;

  set verticalSpacing(double? value) {
    assert(
      value == null || (value >= 0.0 && value.isFinite),
      'Vertical spacing must be finite and non-negative',
    );
    if (_verticalSpacing == value) return;
    _verticalSpacing = value;
    markNeedsLayout();
  }

  /// Main-axis alignment when the chosen direction is [Axis.horizontal].
  WrapAlignment get horizontalAlignment => _horizontalAlignment;
  WrapAlignment _horizontalAlignment;

  set horizontalAlignment(WrapAlignment value) {
    if (_horizontalAlignment == value) return;
    _horizontalAlignment = value;
    markNeedsLayout();
  }

  /// Main-axis alignment when the chosen direction is [Axis.vertical].
  WrapAlignment get verticalAlignment => _verticalAlignment;
  WrapAlignment _verticalAlignment;

  set verticalAlignment(WrapAlignment value) {
    if (_verticalAlignment == value) return;
    _verticalAlignment = value;
    markNeedsLayout();
  }

  /// Cross-axis alignment when the chosen direction is [Axis.horizontal].
  WrapCrossAlignment get horizontalCrossAxisAlignment =>
      _horizontalCrossAxisAlignment;
  WrapCrossAlignment _horizontalCrossAxisAlignment;

  set horizontalCrossAxisAlignment(WrapCrossAlignment value) {
    if (_horizontalCrossAxisAlignment == value) return;
    _horizontalCrossAxisAlignment = value;
    markNeedsLayout();
  }

  /// Cross-axis alignment when the chosen direction is [Axis.vertical].
  WrapCrossAlignment get verticalCrossAxisAlignment =>
      _verticalCrossAxisAlignment;
  WrapCrossAlignment _verticalCrossAxisAlignment;

  set verticalCrossAxisAlignment(WrapCrossAlignment value) {
    if (_verticalCrossAxisAlignment == value) return;
    _verticalCrossAxisAlignment = value;
    markNeedsLayout();
  }

  /// Text direction used to resolve horizontal order and start/end alignment.
  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;

  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  /// Vertical direction used to resolve vertical order and start/end alignment.
  VerticalDirection get verticalDirection => _verticalDirection;
  VerticalDirection _verticalDirection;

  set verticalDirection(VerticalDirection value) {
    if (_verticalDirection == value) return;
    _verticalDirection = value;
    markNeedsLayout();
  }

  /// Paint clipping behavior applied only when visual overflow exists.
  Clip get clipBehavior => _clipBehavior;
  Clip _clipBehavior;

  set clipBehavior(Clip value) {
    if (_clipBehavior == value) return;
    _clipBehavior = value;
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  /// Callback scheduled after the chosen layout direction changes.
  ///
  /// The callback is not invoked for the first layout. Pending notifications
  /// are coalesced within a frame and call the latest callback assigned before
  /// the post-frame notification runs.
  LayoutDirectionCallback? get onLayoutDirectionChanged =>
      _onLayoutDirectionChanged;
  LayoutDirectionCallback? _onLayoutDirectionChanged;

  set onLayoutDirectionChanged(LayoutDirectionCallback? value) {
    _onLayoutDirectionChanged = value;
  }

  /// Whether the first chosen direction should be reused on later layouts.
  ///
  /// Disabling this clears the lock so the next layout can choose from current
  /// constraints again.
  bool get maintainLayout => _maintainLayout;
  bool _maintainLayout;

  set maintainLayout(bool value) {
    if (_maintainLayout == value) return;
    _maintainLayout = value;
    if (!value) {
      _currentLayoutDirection = null;
    }
    markNeedsLayout();
  }

  /// Measurement strategy used while deciding whether the primary axis fits.
  MeasurementStrategy get measurementStrategy => _measurementStrategy;
  MeasurementStrategy _measurementStrategy;

  set measurementStrategy(MeasurementStrategy value) {
    if (_measurementStrategy == value) return;
    _measurementStrategy = value;
    markNeedsLayout();
  }

  // `_currentLayoutDirection` powers maintainLayout. `_lastLaidOutDirection`
  // is kept separate so resetting the lock does not suppress change callbacks.
  Axis? _currentLayoutDirection;
  Axis? _lastLaidOutDirection;
  int _directionNotificationGeneration = 0;

  final LayerHandle<ClipRectLayer> _clipRectLayer =
      LayerHandle<ClipRectLayer>();
  bool _hasVisualOverflow = false;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! SingleAxisWrapParentData) {
      child.parentData = SingleAxisWrapParentData();
    }
  }

  Axis get _fallbackDirection =>
      primaryDirection == Axis.horizontal ? Axis.vertical : Axis.horizontal;

  double _getSpacingForDirection(Axis direction) {
    return direction == Axis.horizontal
        ? horizontalSpacing ?? spacing
        : verticalSpacing ?? spacing;
  }

  WrapAlignment _getAlignmentForDirection(Axis direction) {
    return direction == Axis.horizontal
        ? horizontalAlignment
        : verticalAlignment;
  }

  WrapCrossAlignment _getCrossAlignmentForDirection(Axis direction) {
    return direction == Axis.horizontal
        ? horizontalCrossAxisAlignment
        : verticalCrossAxisAlignment;
  }

  BoxConstraints _childConstraintsFor(
    Axis direction,
    BoxConstraints constraints,
  ) {
    return direction == Axis.horizontal
        ? BoxConstraints(maxHeight: constraints.maxHeight)
        : BoxConstraints(maxWidth: constraints.maxWidth);
  }

  double _maxMainAxisExtent(Axis direction, BoxConstraints constraints) {
    return direction == Axis.horizontal
        ? constraints.maxWidth
        : constraints.maxHeight;
  }

  double _constrainMainAxisExtent(
    Axis direction,
    BoxConstraints constraints,
    double value,
  ) {
    return direction == Axis.horizontal
        ? constraints.constrainWidth(value)
        : constraints.constrainHeight(value);
  }

  double _constrainCrossAxisExtent(
    Axis direction,
    BoxConstraints constraints,
    double value,
  ) {
    return direction == Axis.horizontal
        ? constraints.constrainHeight(value)
        : constraints.constrainWidth(value);
  }

  Size _sizeForAxisExtents(
    Axis direction,
    double mainAxisExtent,
    double crossAxisExtent,
  ) {
    return direction == Axis.horizontal
        ? Size(mainAxisExtent, crossAxisExtent)
        : Size(crossAxisExtent, mainAxisExtent);
  }

  double _mainAxisExtent(Axis direction, Size size) {
    return direction == Axis.horizontal ? size.width : size.height;
  }

  double _crossAxisExtent(Axis direction, Size size) {
    return direction == Axis.horizontal ? size.height : size.width;
  }

  bool _alignmentExpandsMainAxis(WrapAlignment alignment) {
    return alignment == WrapAlignment.spaceBetween ||
        alignment == WrapAlignment.spaceAround ||
        alignment == WrapAlignment.spaceEvenly;
  }

  bool _preferPrimaryForUnboundedConstraints(BoxConstraints constraints) {
    // Keep supporting the deprecated value until the next breaking release.
    // ignore: deprecated_member_use_from_same_package
    return measurementStrategy == MeasurementStrategy.preferPrimary &&
        !_maxMainAxisExtent(primaryDirection, constraints).isFinite;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return _computeIntrinsicWidth(_IntrinsicExtent.min, height);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _computeIntrinsicWidth(_IntrinsicExtent.max, height);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _computeIntrinsicHeight(_IntrinsicExtent.min, width);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _computeIntrinsicHeight(_IntrinsicExtent.max, width);
  }

  double _computeIntrinsicWidth(_IntrinsicExtent extent, double height) {
    if (childCount == 0) {
      return 0.0;
    }

    final direction = _resolveIntrinsicWidthDirection(extent, height);
    return _intrinsicWidthForDirection(direction, extent, height);
  }

  double _computeIntrinsicHeight(_IntrinsicExtent extent, double width) {
    if (childCount == 0) {
      return 0.0;
    }

    final direction = _resolveIntrinsicHeightDirection(extent, width);
    return _intrinsicHeightForDirection(direction, extent, width);
  }

  double _intrinsicWidthForDirection(
    Axis direction,
    _IntrinsicExtent extent,
    double height,
  ) {
    return direction == Axis.horizontal
        ? _computeIntrinsicMainAxisExtent(direction, extent, height)
        : _computeIntrinsicCrossAxisExtent(direction, extent, double.infinity);
  }

  double _intrinsicHeightForDirection(
    Axis direction,
    _IntrinsicExtent extent,
    double width,
  ) {
    return direction == Axis.horizontal
        ? _computeIntrinsicCrossAxisExtent(direction, extent, double.infinity)
        : _computeIntrinsicMainAxisExtent(direction, extent, width);
  }

  Axis _resolveIntrinsicWidthDirection(_IntrinsicExtent extent, double height) {
    if (maintainLayout && _currentLayoutDirection != null) {
      return _currentLayoutDirection!;
    }

    if (primaryDirection == Axis.horizontal) {
      if (extent == _IntrinsicExtent.max) {
        return Axis.horizontal;
      }

      final fallbackRequiredHeight = _computeIntrinsicMainAxisExtent(
        Axis.vertical,
        _IntrinsicExtent.max,
        double.infinity,
      );
      return !height.isFinite || fallbackRequiredHeight <= height
          ? Axis.vertical
          : Axis.horizontal;
    }

    if (primaryDirection == Axis.vertical) {
      final constraints = BoxConstraints(maxHeight: height);
      return _fitsUsingIntrinsics(Axis.vertical, constraints)
          ? Axis.vertical
          : Axis.horizontal;
    }

    return primaryDirection;
  }

  Axis _resolveIntrinsicHeightDirection(_IntrinsicExtent extent, double width) {
    if (maintainLayout && _currentLayoutDirection != null) {
      return _currentLayoutDirection!;
    }

    if (primaryDirection == Axis.horizontal) {
      final constraints = BoxConstraints(maxWidth: width);
      return _fitsUsingIntrinsics(Axis.horizontal, constraints)
          ? Axis.horizontal
          : Axis.vertical;
    }

    if (primaryDirection == Axis.vertical) {
      if (extent == _IntrinsicExtent.max) {
        return Axis.vertical;
      }

      final fallbackRequiredWidth = _computeIntrinsicMainAxisExtent(
        Axis.horizontal,
        _IntrinsicExtent.max,
        double.infinity,
      );
      return !width.isFinite || fallbackRequiredWidth <= width
          ? Axis.horizontal
          : Axis.vertical;
    }

    return primaryDirection;
  }

  double _computeIntrinsicMainAxisExtent(
    Axis direction,
    _IntrinsicExtent extent,
    double crossAxisExtent,
  ) {
    final spacing = _getSpacingForDirection(direction);
    var total = 0.0;
    var isFirst = true;

    var child = firstChild;
    while (child != null) {
      if (!isFirst) {
        total += spacing;
      }
      total += _childIntrinsicMainAxisExtent(
        child,
        direction,
        extent,
        crossAxisExtent,
      );
      isFirst = false;
      child = childAfter(child);
    }

    return total;
  }

  double _computeIntrinsicCrossAxisExtent(
    Axis direction,
    _IntrinsicExtent extent,
    double mainAxisExtent,
  ) {
    var maxExtent = 0.0;

    var child = firstChild;
    while (child != null) {
      maxExtent = math.max(
        maxExtent,
        _childIntrinsicCrossAxisExtent(
          child,
          direction,
          extent,
          mainAxisExtent,
        ),
      );
      child = childAfter(child);
    }

    return maxExtent;
  }

  double _childIntrinsicMainAxisExtent(
    RenderBox child,
    Axis direction,
    _IntrinsicExtent extent,
    double crossAxisExtent,
  ) {
    return switch ((direction, extent)) {
      (Axis.horizontal, _IntrinsicExtent.min) => child.getMinIntrinsicWidth(
        crossAxisExtent,
      ),
      (Axis.horizontal, _IntrinsicExtent.max) => child.getMaxIntrinsicWidth(
        crossAxisExtent,
      ),
      (Axis.vertical, _IntrinsicExtent.min) => child.getMinIntrinsicHeight(
        crossAxisExtent,
      ),
      (Axis.vertical, _IntrinsicExtent.max) => child.getMaxIntrinsicHeight(
        crossAxisExtent,
      ),
    };
  }

  double _childIntrinsicCrossAxisExtent(
    RenderBox child,
    Axis direction,
    _IntrinsicExtent extent,
    double mainAxisExtent,
  ) {
    return switch ((direction, extent)) {
      (Axis.horizontal, _IntrinsicExtent.min) => child.getMinIntrinsicHeight(
        mainAxisExtent,
      ),
      (Axis.horizontal, _IntrinsicExtent.max) => child.getMaxIntrinsicHeight(
        mainAxisExtent,
      ),
      (Axis.vertical, _IntrinsicExtent.min) => child.getMinIntrinsicWidth(
        mainAxisExtent,
      ),
      (Axis.vertical, _IntrinsicExtent.max) => child.getMaxIntrinsicWidth(
        mainAxisExtent,
      ),
    };
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return switch (_lastLaidOutDirection ?? _currentLayoutDirection) {
      Axis.vertical => defaultComputeDistanceToFirstActualBaseline(baseline),
      Axis.horizontal ||
      null => defaultComputeDistanceToHighestActualBaseline(baseline),
    };
  }

  @override
  double? computeDryBaseline(
    BoxConstraints constraints,
    TextBaseline baseline,
  ) {
    if (childCount == 0) {
      return null;
    }

    final metrics = _resolveDryMetrics(constraints, collectChildren: true);
    final containerSize = _computeContainerSize(metrics, constraints);

    double? result;
    for (final childLayout in _positionDryChildren(metrics, containerSize)) {
      final childBaseline = childLayout.child.getDryBaseline(
        childLayout.constraints,
        baseline,
      );
      if (childBaseline == null) {
        continue;
      }

      final baselineOffset = childLayout.offset.dy + childBaseline;
      if (metrics.direction == Axis.vertical) {
        return baselineOffset;
      }

      result = result == null
          ? baselineOffset
          : math.min(result, baselineOffset);
    }

    return result;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (childCount == 0) {
      return constraints.smallest;
    }

    final metrics = _resolveDryMetrics(constraints);
    return _computeContainerSize(metrics, constraints);
  }

  _LayoutMetrics _resolveDryMetrics(
    BoxConstraints constraints, {
    bool collectChildren = false,
  }) {
    // Dry layout must choose the same axis as real layout without mutating the
    // maintained direction or child parent data.
    if (maintainLayout && _currentLayoutDirection != null) {
      return _measureDry(
        _currentLayoutDirection!,
        constraints,
        collectChildren: collectChildren,
      );
    }

    if (_preferPrimaryForUnboundedConstraints(constraints)) {
      return _measureDry(
        primaryDirection,
        constraints,
        collectChildren: collectChildren,
      );
    }

    if (measurementStrategy == MeasurementStrategy.intrinsic) {
      final direction = _fitsUsingIntrinsics(primaryDirection, constraints)
          ? primaryDirection
          : _fallbackDirection;
      return _measureDry(
        direction,
        constraints,
        collectChildren: collectChildren,
      );
    }

    final primaryMetrics = _measureDry(
      primaryDirection,
      constraints,
      collectChildren: collectChildren,
    );
    if (_fitsInDirection(primaryMetrics, constraints)) {
      return primaryMetrics;
    }

    return _measureDry(
      _fallbackDirection,
      constraints,
      collectChildren: collectChildren,
    );
  }

  bool _fitsUsingIntrinsics(Axis direction, BoxConstraints constraints) {
    final maxMainAxisExtent = _maxMainAxisExtent(direction, constraints);
    if (!maxMainAxisExtent.isFinite) {
      return true;
    }

    final crossAxisExtent = direction == Axis.horizontal
        ? constraints.maxHeight
        : constraints.maxWidth;
    final requiredMainAxisExtent = _computeIntrinsicMainAxisExtent(
      direction,
      _IntrinsicExtent.max,
      crossAxisExtent,
    );

    return requiredMainAxisExtent <= maxMainAxisExtent;
  }

  _LayoutMetrics _measureDry(
    Axis direction,
    BoxConstraints constraints, {
    bool collectChildren = false,
  }) {
    // Dry metrics keep the child constraints used for each dry size so baseline
    // queries can later ask the child with the exact same inputs.
    final childConstraints = _childConstraintsFor(direction, constraints);
    final dryChildren = collectChildren ? <_DryChildLayout>[] : null;
    var childrenMainAxisExtent = 0.0;
    var maxCrossAxisExtent = 0.0;
    var measuredChildCount = 0;

    var child = firstChild;
    while (child != null) {
      final childSize = child.getDryLayout(childConstraints);
      dryChildren?.add(
        _DryChildLayout(
          child: child,
          constraints: childConstraints,
          size: childSize,
        ),
      );
      childrenMainAxisExtent += _mainAxisExtent(direction, childSize);
      maxCrossAxisExtent = math.max(
        maxCrossAxisExtent,
        _crossAxisExtent(direction, childSize),
      );
      measuredChildCount++;
      child = childAfter(child);
    }

    return _LayoutMetrics(
      direction: direction,
      childCount: measuredChildCount,
      childrenMainAxisExtent: childrenMainAxisExtent,
      maxCrossAxisExtent: maxCrossAxisExtent,
      spacing: _getSpacingForDirection(direction),
      dryChildren: dryChildren,
    );
  }

  bool _fitsInDirection(_LayoutMetrics metrics, BoxConstraints constraints) {
    final maxMainAxisExtent = _maxMainAxisExtent(
      metrics.direction,
      constraints,
    );
    return !maxMainAxisExtent.isFinite ||
        metrics.totalMainAxisExtent <= maxMainAxisExtent;
  }

  @override
  void performLayout() {
    if (childCount == 0) {
      size = constraints.smallest;
      _hasVisualOverflow = false;
      _lastLaidOutDirection = null;
      _directionNotificationGeneration++;
      return;
    }

    final lockedDirection = maintainLayout ? _currentLayoutDirection : null;
    final metrics = lockedDirection != null
        ? _measureWet(lockedDirection)
        : _layoutWithResolvedDirection();

    _commitLayout(metrics);
    _currentLayoutDirection = metrics.direction;
    _notifyDirectionChanged(metrics.direction);
  }

  _LayoutMetrics _layoutWithResolvedDirection() {
    // The default strategy intentionally performs a real primary layout first.
    // If it fits, those child sizes are reused and no second layout pass occurs.
    if (_preferPrimaryForUnboundedConstraints(constraints)) {
      return _measureWet(primaryDirection);
    }

    if (measurementStrategy == MeasurementStrategy.intrinsic) {
      final direction = _fitsUsingIntrinsics(primaryDirection, constraints)
          ? primaryDirection
          : _fallbackDirection;
      return _measureWet(direction);
    }

    final primaryMetrics = _measureWet(primaryDirection);
    if (_fitsInDirection(primaryMetrics, constraints)) {
      return primaryMetrics;
    }

    return _measureWet(_fallbackDirection);
  }

  _LayoutMetrics _measureWet(Axis direction) {
    final childConstraints = _childConstraintsFor(direction, constraints);
    var childrenMainAxisExtent = 0.0;
    var maxCrossAxisExtent = 0.0;
    var measuredChildCount = 0;

    var child = firstChild;
    while (child != null) {
      child.layout(childConstraints, parentUsesSize: true);
      childrenMainAxisExtent += _mainAxisExtent(direction, child.size);
      maxCrossAxisExtent = math.max(
        maxCrossAxisExtent,
        _crossAxisExtent(direction, child.size),
      );
      measuredChildCount++;
      child = childAfter(child);
    }

    return _LayoutMetrics(
      direction: direction,
      childCount: measuredChildCount,
      childrenMainAxisExtent: childrenMainAxisExtent,
      maxCrossAxisExtent: maxCrossAxisExtent,
      spacing: _getSpacingForDirection(direction),
    );
  }

  void _commitLayout(_LayoutMetrics metrics) {
    // Size and offsets are committed only after the final direction is known.
    // This keeps debug dry-layout checks from seeing the temporary primary
    // measurement when fallback is required.
    size = _computeContainerSize(metrics, constraints);
    _hasVisualOverflow = _computeVisualOverflow(metrics, size);
    _positionChildren(metrics, size);
  }

  Size _computeContainerSize(
    _LayoutMetrics metrics,
    BoxConstraints constraints,
  ) {
    final maxMainAxisExtent = _maxMainAxisExtent(
      metrics.direction,
      constraints,
    );
    final alignment = _getAlignmentForDirection(metrics.direction);
    final shouldExpandMainAxis =
        maxMainAxisExtent.isFinite && _alignmentExpandsMainAxis(alignment);

    final containerMainAxisExtent = shouldExpandMainAxis
        ? maxMainAxisExtent
        : _constrainMainAxisExtent(
            metrics.direction,
            constraints,
            metrics.totalMainAxisExtent,
          );
    final containerCrossAxisExtent = _constrainCrossAxisExtent(
      metrics.direction,
      constraints,
      metrics.maxCrossAxisExtent,
    );

    return _sizeForAxisExtents(
      metrics.direction,
      containerMainAxisExtent,
      containerCrossAxisExtent,
    );
  }

  bool _computeVisualOverflow(_LayoutMetrics metrics, Size containerSize) {
    return _mainAxisExtent(metrics.direction, containerSize) <
            metrics.totalMainAxisExtent ||
        _crossAxisExtent(metrics.direction, containerSize) <
            metrics.maxCrossAxisExtent;
  }

  void _notifyDirectionChanged(Axis newDirection) {
    final oldDirection = _lastLaidOutDirection;
    _lastLaidOutDirection = newDirection;

    if (oldDirection == null || oldDirection == newDirection) {
      return;
    }

    final generation = ++_directionNotificationGeneration;
    if (onLayoutDirectionChanged == null) {
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!attached || generation != _directionNotificationGeneration) {
        return;
      }

      onLayoutDirectionChanged?.call(newDirection);
    }, debugLabel: 'SingleAxisWrap.onLayoutDirectionChanged');
  }

  void _positionChildren(_LayoutMetrics metrics, Size containerSize) {
    // Offsets are calculated in logical main-axis order, then mirrored for RTL
    // or upward vertical layouts at the final physical offset step.
    final containerMainAxisExtent = _mainAxisExtent(
      metrics.direction,
      containerSize,
    );
    final containerCrossAxisExtent = _crossAxisExtent(
      metrics.direction,
      containerSize,
    );
    final freeMainAxisSpace = math.max(
      0.0,
      containerMainAxisExtent - metrics.totalMainAxisExtent,
    );
    final (leadingSpace, betweenSpace) = _distributeMainAxisSpace(
      _getAlignmentForDirection(metrics.direction),
      freeMainAxisSpace,
      metrics.spacing,
      metrics.childCount,
    );

    final reverseMainAxis = _mainAxisIsReversed(metrics.direction);
    var logicalMainAxisOffset = leadingSpace;

    var child = firstChild;
    while (child != null) {
      final childSize = child.size;
      final childMainAxisExtent = _mainAxisExtent(metrics.direction, childSize);
      final childCrossAxisExtent = _crossAxisExtent(
        metrics.direction,
        childSize,
      );
      final mainAxisOffset = reverseMainAxis
          ? containerMainAxisExtent -
                logicalMainAxisOffset -
                childMainAxisExtent
          : logicalMainAxisOffset;
      final crossAxisOffset = _getCrossAxisOffset(
        _getCrossAlignmentForDirection(metrics.direction),
        containerCrossAxisExtent,
        childCrossAxisExtent,
        metrics.direction,
      );

      final childParentData = child.parentData! as SingleAxisWrapParentData;
      childParentData.offset = metrics.direction == Axis.horizontal
          ? Offset(mainAxisOffset, crossAxisOffset)
          : Offset(crossAxisOffset, mainAxisOffset);

      logicalMainAxisOffset += childMainAxisExtent + betweenSpace;
      child = childAfter(child);
    }
  }

  Iterable<_PositionedDryChildLayout> _positionDryChildren(
    _LayoutMetrics metrics,
    Size containerSize,
  ) sync* {
    final dryChildren = metrics.dryChildren;
    if (dryChildren == null || dryChildren.isEmpty) {
      return;
    }

    final containerMainAxisExtent = _mainAxisExtent(
      metrics.direction,
      containerSize,
    );
    final containerCrossAxisExtent = _crossAxisExtent(
      metrics.direction,
      containerSize,
    );
    final freeMainAxisSpace = math.max(
      0.0,
      containerMainAxisExtent - metrics.totalMainAxisExtent,
    );
    final (leadingSpace, betweenSpace) = _distributeMainAxisSpace(
      _getAlignmentForDirection(metrics.direction),
      freeMainAxisSpace,
      metrics.spacing,
      metrics.childCount,
    );

    final reverseMainAxis = _mainAxisIsReversed(metrics.direction);
    var logicalMainAxisOffset = leadingSpace;

    for (final childLayout in dryChildren) {
      final childMainAxisExtent = _mainAxisExtent(
        metrics.direction,
        childLayout.size,
      );
      final childCrossAxisExtent = _crossAxisExtent(
        metrics.direction,
        childLayout.size,
      );
      final mainAxisOffset = reverseMainAxis
          ? containerMainAxisExtent -
                logicalMainAxisOffset -
                childMainAxisExtent
          : logicalMainAxisOffset;
      final crossAxisOffset = _getCrossAxisOffset(
        _getCrossAlignmentForDirection(metrics.direction),
        containerCrossAxisExtent,
        childCrossAxisExtent,
        metrics.direction,
      );
      final offset = metrics.direction == Axis.horizontal
          ? Offset(mainAxisOffset, crossAxisOffset)
          : Offset(crossAxisOffset, mainAxisOffset);

      yield _PositionedDryChildLayout(
        child: childLayout.child,
        constraints: childLayout.constraints,
        offset: offset,
      );

      logicalMainAxisOffset += childMainAxisExtent + betweenSpace;
    }
  }

  (double leadingSpace, double betweenSpace) _distributeMainAxisSpace(
    WrapAlignment alignment,
    double freeSpace,
    double spacing,
    int childCount,
  ) {
    assert(childCount > 0);

    // Match WrapAlignment semantics: with one child, spaceBetween has no
    // between-space to distribute, so it behaves like start.
    return switch (alignment) {
      WrapAlignment.start => (0.0, spacing),
      WrapAlignment.end => (freeSpace, spacing),
      WrapAlignment.center => (freeSpace / 2.0, spacing),
      WrapAlignment.spaceBetween when childCount < 2 => (0.0, spacing),
      WrapAlignment.spaceBetween => (
        0.0,
        spacing + freeSpace / (childCount - 1),
      ),
      WrapAlignment.spaceAround => (
        freeSpace / childCount / 2.0,
        spacing + freeSpace / childCount,
      ),
      WrapAlignment.spaceEvenly => (
        freeSpace / (childCount + 1),
        spacing + freeSpace / (childCount + 1),
      ),
    };
  }

  bool _mainAxisIsReversed(Axis direction) {
    return direction == Axis.horizontal
        ? textDirection == TextDirection.rtl
        : verticalDirection == VerticalDirection.up;
  }

  double _getCrossAxisOffset(
    WrapCrossAlignment alignment,
    double containerSize,
    double childSize,
    Axis direction,
  ) {
    final flipAlignment = direction == Axis.horizontal
        ? verticalDirection == VerticalDirection.up
        : textDirection == TextDirection.rtl;

    return switch (alignment) {
      WrapCrossAlignment.start =>
        flipAlignment ? containerSize - childSize : 0.0,
      WrapCrossAlignment.end => flipAlignment ? 0.0 : containerSize - childSize,
      WrapCrossAlignment.center => (containerSize - childSize) / 2.0,
    };
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_hasVisualOverflow && clipBehavior != Clip.none) {
      _clipRectLayer.layer = context.pushClipRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        defaultPaint,
        clipBehavior: clipBehavior,
        oldLayer: _clipRectLayer.layer,
      );
    } else {
      _clipRectLayer.layer = null;
      defaultPaint(context, offset);
    }
  }

  @override
  Rect? describeApproximatePaintClip(RenderObject child) {
    if (_hasVisualOverflow && clipBehavior != Clip.none) {
      return Offset.zero & size;
    }
    return null;
  }

  @override
  void detach() {
    _directionNotificationGeneration++;
    super.detach();
  }

  @override
  void dispose() {
    _clipRectLayer.layer = null;
    super.dispose();
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<Axis>('primaryDirection', primaryDirection))
      ..add(
        EnumProperty<Axis>('currentLayoutDirection', _currentLayoutDirection),
      )
      ..add(EnumProperty<Axis>('lastLaidOutDirection', _lastLaidOutDirection))
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
      ..add(EnumProperty<TextDirection>('textDirection', textDirection))
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
      )
      ..add(
        FlagProperty(
          'hasVisualOverflow',
          value: _hasVisualOverflow,
          ifTrue: 'overflow',
          ifFalse: 'contained',
        ),
      );
  }
}

enum _IntrinsicExtent { min, max }

// Shared measurement result used by dry layout, real layout, and positioning.
// Keeping this shape central prevents drift between Flutter's dry and wet
// layout protocols.
class _LayoutMetrics {
  const _LayoutMetrics({
    required this.direction,
    required this.childCount,
    required this.childrenMainAxisExtent,
    required this.maxCrossAxisExtent,
    required this.spacing,
    this.dryChildren,
  });

  final Axis direction;
  final int childCount;
  final double childrenMainAxisExtent;
  final double maxCrossAxisExtent;
  final double spacing;
  final List<_DryChildLayout>? dryChildren;

  double get spacingExtent {
    if (childCount <= 1) {
      return 0.0;
    }

    return spacing * (childCount - 1);
  }

  double get totalMainAxisExtent => childrenMainAxisExtent + spacingExtent;
}

// Captures a dry child measurement together with the constraints that produced
// it so dry baseline calculations do not accidentally use different inputs.
class _DryChildLayout {
  const _DryChildLayout({
    required this.child,
    required this.constraints,
    required this.size,
  });

  final RenderBox child;
  final BoxConstraints constraints;
  final Size size;
}

// A dry child with the offset it would receive during real layout.
class _PositionedDryChildLayout {
  const _PositionedDryChildLayout({
    required this.child,
    required this.constraints,
    required this.offset,
  });

  final RenderBox child;
  final BoxConstraints constraints;
  final Offset offset;
}
