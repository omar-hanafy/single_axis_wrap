// ignore_for_file: no_leading_underscores_for_local_identifiers, unnecessary_getters_setters

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import '../single_axis_wrap.dart';

/// Parent data for [RenderSingleAxisWrap].
class SingleAxisWrapParentData extends ContainerBoxParentData<RenderBox> {
  @override
  String toString() => 'offset=$offset';
}

/// Render object for [SingleAxisWrap] that performs the "all or nothing" layout.
///
/// It first attempts to lay out the children in the [primaryDirection]. If that
/// exceeds the available space, it switches to the perpendicular direction.
class RenderSingleAxisWrap extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, SingleAxisWrapParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, SingleAxisWrapParentData> {
  /// Creates a [RenderSingleAxisWrap] render object.
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
  })  : _primaryDirection = primaryDirection,
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

  /// The primary layout direction to attempt first.
  Axis get primaryDirection => _primaryDirection;
  Axis _primaryDirection;

  set primaryDirection(Axis value) {
    if (_primaryDirection == value) return;
    _primaryDirection = value;
    // Reset the chosen layout when primary direction changes
    _currentLayoutDirection = null;
    markNeedsLayout();
  }

  /// The default spacing between children in both layouts.
  double get spacing => _spacing;
  double _spacing;

  set spacing(double value) {
    assert(value >= 0.0, 'Spacing must be non-negative');
    if (_spacing == value) return;
    _spacing = value;
    markNeedsLayout();
  }

  /// Spacing between children when in horizontal (row) layout.
  double? get horizontalSpacing => _horizontalSpacing;
  double? _horizontalSpacing;

  set horizontalSpacing(double? value) {
    assert(value == null || value >= 0.0,
        'Horizontal spacing must be non-negative');
    if (_horizontalSpacing == value) return;
    _horizontalSpacing = value;
    markNeedsLayout();
  }

  /// Spacing between children when in vertical (column) layout.
  double? get verticalSpacing => _verticalSpacing;
  double? _verticalSpacing;

  set verticalSpacing(double? value) {
    assert(
        value == null || value >= 0.0, 'Vertical spacing must be non-negative');
    if (_verticalSpacing == value) return;
    _verticalSpacing = value;
    markNeedsLayout();
  }

  /// Alignment of children along the main axis when in horizontal (row) layout.
  WrapAlignment get horizontalAlignment => _horizontalAlignment;
  WrapAlignment _horizontalAlignment;

  set horizontalAlignment(WrapAlignment value) {
    if (_horizontalAlignment == value) return;
    _horizontalAlignment = value;
    markNeedsLayout();
  }

  /// Alignment of children along the main axis when in vertical (column) layout.
  WrapAlignment get verticalAlignment => _verticalAlignment;
  WrapAlignment _verticalAlignment;

  set verticalAlignment(WrapAlignment value) {
    if (_verticalAlignment == value) return;
    _verticalAlignment = value;
    markNeedsLayout();
  }

  /// Alignment of children along the cross axis when in horizontal (row) layout.
  WrapCrossAlignment get horizontalCrossAxisAlignment =>
      _horizontalCrossAxisAlignment;
  WrapCrossAlignment _horizontalCrossAxisAlignment;

  set horizontalCrossAxisAlignment(WrapCrossAlignment value) {
    if (_horizontalCrossAxisAlignment == value) return;
    _horizontalCrossAxisAlignment = value;
    markNeedsLayout();
  }

  /// Alignment of children along the cross axis when in vertical (column) layout.
  WrapCrossAlignment get verticalCrossAxisAlignment =>
      _verticalCrossAxisAlignment;
  WrapCrossAlignment _verticalCrossAxisAlignment;

  set verticalCrossAxisAlignment(WrapCrossAlignment value) {
    if (_verticalCrossAxisAlignment == value) return;
    _verticalCrossAxisAlignment = value;
    markNeedsLayout();
  }

  /// Text direction for horizontal layouts.
  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;

  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  /// Vertical direction for vertical layouts.
  VerticalDirection get verticalDirection => _verticalDirection;
  VerticalDirection _verticalDirection;

  set verticalDirection(VerticalDirection value) {
    if (_verticalDirection == value) return;
    _verticalDirection = value;
    markNeedsLayout();
  }

  /// Clip behavior for children that exceed the container bounds.
  Clip get clipBehavior => _clipBehavior;
  Clip _clipBehavior;

  set clipBehavior(Clip value) {
    if (_clipBehavior == value) return;
    _clipBehavior = value;
    markNeedsPaint();
  }

  /// Callback for when layout direction changes.
  LayoutDirectionCallback? get onLayoutDirectionChanged =>
      _onLayoutDirectionChanged;
  LayoutDirectionCallback? _onLayoutDirectionChanged;

  set onLayoutDirectionChanged(LayoutDirectionCallback? value) {
    _onLayoutDirectionChanged = value;
  }

  /// Whether to maintain the current layout once chosen.
  bool get maintainLayout => _maintainLayout;
  bool _maintainLayout;

  set maintainLayout(bool value) {
    if (_maintainLayout == value) return;
    _maintainLayout = value;
    if (!value) {
      // Reset the chosen layout when maintainLayout is disabled
      _currentLayoutDirection = null;
    }
    markNeedsLayout();
  }

  /// Strategy for measuring children during layout decisions.
  MeasurementStrategy get measurementStrategy => _measurementStrategy;
  MeasurementStrategy _measurementStrategy;

  set measurementStrategy(MeasurementStrategy value) {
    if (_measurementStrategy == value) return;
    _measurementStrategy = value;
    markNeedsLayout();
  }

  // The currently chosen layout direction
  Axis? _currentLayoutDirection;

  // Layer handle for clipping
  final LayerHandle<ClipRectLayer> _clipRectLayer =
      LayerHandle<ClipRectLayer>();
  bool _hasVisualOverflow = false;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! SingleAxisWrapParentData) {
      child.parentData = SingleAxisWrapParentData();
    }
  }

  /// Gets the appropriate spacing based on the layout direction.
  double _getSpacingForDirection(Axis direction) {
    return direction == Axis.horizontal
        ? horizontalSpacing ?? spacing
        : verticalSpacing ?? spacing;
  }

  /// Gets the appropriate alignment based on the layout direction.
  WrapAlignment _getAlignmentForDirection(Axis direction) {
    return direction == Axis.horizontal
        ? horizontalAlignment
        : verticalAlignment;
  }

  /// Gets the appropriate cross-axis alignment based on the layout direction.
  WrapCrossAlignment _getCrossAlignmentForDirection(Axis direction) {
    return direction == Axis.horizontal
        ? horizontalCrossAxisAlignment
        : verticalCrossAxisAlignment;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    if (childCount == 0) {
      return 0.0;
    }

    // In horizontal layout, it's the width of the widest child
    // In vertical layout, it's the sum of all children's min widths
    if (_currentLayoutDirection == Axis.vertical) {
      var maxWidth = 0.0;
      var child = firstChild;
      while (child != null) {
        maxWidth =
            math.max(maxWidth, child.getMinIntrinsicWidth(double.infinity));
        child = childAfter(child);
      }
      return maxWidth;
    } else {
      // Default to horizontal layout or calculate based on primary direction if unset
      if (_currentLayoutDirection == null &&
          primaryDirection == Axis.vertical) {
        // For primary vertical, calculate as if vertical
        var maxWidth = 0.0;
        var child = firstChild;
        while (child != null) {
          maxWidth =
              math.max(maxWidth, child.getMinIntrinsicWidth(double.infinity));
          child = childAfter(child);
        }
        return maxWidth;
      } else {
        // Calculate as if horizontal
        var totalWidth = 0.0;
        var child = firstChild;
        final horizontalSpace = _getSpacingForDirection(Axis.horizontal);
        var isFirst = true;

        while (child != null) {
          if (!isFirst) totalWidth += horizontalSpace;
          totalWidth += child.getMinIntrinsicWidth(double.infinity);
          isFirst = false;
          child = childAfter(child);
        }
        return totalWidth;
      }
    }
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (childCount == 0) {
      return 0.0;
    }

    // Similar logic to min intrinsic width but use max intrinsic width of children
    if (_currentLayoutDirection == Axis.vertical) {
      var maxWidth = 0.0;
      var child = firstChild;
      while (child != null) {
        maxWidth =
            math.max(maxWidth, child.getMaxIntrinsicWidth(double.infinity));
        child = childAfter(child);
      }
      return maxWidth;
    } else {
      // Default to horizontal layout or calculate based on primary direction if unset
      if (_currentLayoutDirection == null &&
          primaryDirection == Axis.vertical) {
        // For primary vertical, calculate as if vertical
        var maxWidth = 0.0;
        var child = firstChild;
        while (child != null) {
          maxWidth =
              math.max(maxWidth, child.getMaxIntrinsicWidth(double.infinity));
          child = childAfter(child);
        }
        return maxWidth;
      } else {
        // Calculate as if horizontal
        var totalWidth = 0.0;
        var child = firstChild;
        final horizontalSpace = _getSpacingForDirection(Axis.horizontal);
        var isFirst = true;

        while (child != null) {
          if (!isFirst) totalWidth += horizontalSpace;
          totalWidth += child.getMaxIntrinsicWidth(double.infinity);
          isFirst = false;
          child = childAfter(child);
        }
        return totalWidth;
      }
    }
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    if (childCount == 0) {
      return 0.0;
    }

    // In vertical layout, it's the height of the tallest child
    // In horizontal layout, it's the sum of all children's min heights
    if (_currentLayoutDirection == Axis.horizontal) {
      var maxHeight = 0.0;
      var child = firstChild;
      while (child != null) {
        maxHeight =
            math.max(maxHeight, child.getMinIntrinsicHeight(double.infinity));
        child = childAfter(child);
      }
      return maxHeight;
    } else {
      // Default to vertical layout or calculate based on primary direction if unset
      if (_currentLayoutDirection == null &&
          primaryDirection == Axis.horizontal) {
        // For primary horizontal, calculate as if horizontal
        var maxHeight = 0.0;
        var child = firstChild;
        while (child != null) {
          maxHeight =
              math.max(maxHeight, child.getMinIntrinsicHeight(double.infinity));
          child = childAfter(child);
        }
        return maxHeight;
      } else {
        // Calculate as if vertical
        var totalHeight = 0.0;
        var child = firstChild;
        final verticalSpace = _getSpacingForDirection(Axis.vertical);
        var isFirst = true;

        while (child != null) {
          if (!isFirst) totalHeight += verticalSpace;
          totalHeight += child.getMinIntrinsicHeight(double.infinity);
          isFirst = false;
          child = childAfter(child);
        }
        return totalHeight;
      }
    }
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    if (childCount == 0) {
      return 0.0;
    }

    // Similar logic to min intrinsic height but use max intrinsic height of children
    if (_currentLayoutDirection == Axis.horizontal) {
      var maxHeight = 0.0;
      var child = firstChild;
      while (child != null) {
        maxHeight =
            math.max(maxHeight, child.getMaxIntrinsicHeight(double.infinity));
        child = childAfter(child);
      }
      return maxHeight;
    } else {
      // Default to vertical layout or calculate based on primary direction if unset
      if (_currentLayoutDirection == null &&
          primaryDirection == Axis.horizontal) {
        // For primary horizontal, calculate as if horizontal
        var maxHeight = 0.0;
        var child = firstChild;
        while (child != null) {
          maxHeight =
              math.max(maxHeight, child.getMaxIntrinsicHeight(double.infinity));
          child = childAfter(child);
        }
        return maxHeight;
      } else {
        // Calculate as if vertical
        var totalHeight = 0.0;
        var child = firstChild;
        final verticalSpace = _getSpacingForDirection(Axis.vertical);
        var isFirst = true;

        while (child != null) {
          if (!isFirst) totalHeight += verticalSpace;
          totalHeight += child.getMaxIntrinsicHeight(double.infinity);
          isFirst = false;
          child = childAfter(child);
        }
        return totalHeight;
      }
    }
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToHighestActualBaseline(baseline);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (childCount == 0) {
      return constraints.smallest;
    }

    // For dry layout, use the logic from determineLayoutDirection to estimate
    // which direction we'd use, but don't update _currentLayoutDirection
    final directionToUse = _estimateLayoutDirection(constraints);

    // Simplified calculation based on estimated direction
    if (directionToUse == Axis.horizontal) {
      var maxHeight = 0.0;
      var totalWidth = 0.0;
      var isFirst = true;
      final spacing = _getSpacingForDirection(Axis.horizontal);

      var child = firstChild;
      while (child != null) {
        final childSize = child
            .getDryLayout(BoxConstraints(maxHeight: constraints.maxHeight));
        if (!isFirst) totalWidth += spacing;
        totalWidth += childSize.width;
        maxHeight = math.max(maxHeight, childSize.height);
        isFirst = false;
        child = childAfter(child);
      }

      return Size(constraints.constrainWidth(totalWidth),
          constraints.constrainHeight(maxHeight));
    } else {
      var maxWidth = 0.0;
      var totalHeight = 0.0;
      var isFirst = true;
      final spacing = _getSpacingForDirection(Axis.vertical);

      var child = firstChild;
      while (child != null) {
        final childSize =
            child.getDryLayout(BoxConstraints(maxWidth: constraints.maxWidth));
        if (!isFirst) totalHeight += spacing;
        totalHeight += childSize.height;
        maxWidth = math.max(maxWidth, childSize.width);
        isFirst = false;
        child = childAfter(child);
      }

      return Size(constraints.constrainWidth(maxWidth),
          constraints.constrainHeight(totalHeight));
    }
  }

  Axis _estimateLayoutDirection(BoxConstraints constraints) {
    final hasBoundedWidth = constraints.maxWidth.isFinite;
    final hasBoundedHeight = constraints.maxHeight.isFinite;

    if (measurementStrategy == MeasurementStrategy.preferPrimary) {
      return primaryDirection;
    }

    if (!hasBoundedWidth && !hasBoundedHeight) {
      return primaryDirection;
    }

    // If only one dimension is bounded, prefer that direction
    if (hasBoundedWidth && !hasBoundedHeight) {
      return Axis.horizontal;
    }

    if (!hasBoundedWidth && hasBoundedHeight) {
      return Axis.vertical;
    }

    // Otherwise use primary direction as an estimate
    return primaryDirection;
  }

  @override
  void performLayout() {
    if (childCount == 0) {
      size = constraints.smallest;
      _hasVisualOverflow = false;
      return;
    }

    // If we're maintaining the current layout and already have one, use it
    if (maintainLayout && _currentLayoutDirection != null) {
      _layoutWithDirection(_currentLayoutDirection!);
      return;
    }

    // Determine the layout direction using the improved method
    final directionToUse = _determineLayoutDirection();

    // Notify if direction changes
    if (_currentLayoutDirection != directionToUse) {
      final oldDirection = _currentLayoutDirection;
      final newDirection = directionToUse;
      _currentLayoutDirection = directionToUse;

      if (oldDirection != null && onLayoutDirectionChanged != null) {
        // Use post-frame callback to avoid "build scheduled during frame" errors
        SchedulerBinding.instance.addPostFrameCallback((_) {
          onLayoutDirectionChanged!(newDirection);
        });
      }
    }

    // Perform the actual layout with the chosen direction
    _layoutWithDirection(directionToUse);
  }

  Axis _determineLayoutDirection() {
    final hasBoundedWidth = constraints.maxWidth.isFinite;
    final hasBoundedHeight = constraints.maxHeight.isFinite;

    // Handle cases based on measurement strategy
    if (measurementStrategy == MeasurementStrategy.preferPrimary) {
      return primaryDirection;
    }

    // Handle cases when both directions are unbounded
    if (!hasBoundedWidth && !hasBoundedHeight) {
      return primaryDirection;
    }

    // Handle cases based on primary direction and constraints
    if (primaryDirection == Axis.horizontal) {
      if (hasBoundedWidth) {
        // Check if all children fit horizontally
        final fitsHorizontally = _tryLayoutInDirection(Axis.horizontal);
        return fitsHorizontally ? Axis.horizontal : Axis.vertical;
      } else if (hasBoundedHeight) {
        // Width is unbounded, height is bounded: prefer vertical
        return Axis.vertical;
      } else {
        // Both unbounded: default to primary direction
        return primaryDirection;
      }
    } else {
      // Primary direction is vertical
      if (hasBoundedHeight) {
        // Check if all children fit vertically
        final fitsVertically = _tryLayoutInDirection(Axis.vertical);
        return fitsVertically ? Axis.vertical : Axis.horizontal;
      } else if (hasBoundedWidth) {
        // Height is unbounded, width is bounded: prefer horizontal
        return Axis.horizontal;
      } else {
        // Both unbounded: default to primary direction
        return primaryDirection;
      }
    }
  }

  bool _tryLayoutInDirection(Axis direction) {
    final mainConstraint = direction == Axis.horizontal
        ? constraints.maxWidth
        : constraints.maxHeight;

    // If the main constraint is infinite, we can't reliably determine fit
    if (!mainConstraint.isFinite) {
      return false; // Assume it doesn't fit to force a direction switch
    }

    // For finite constraints, measure if children fit
    if (measurementStrategy == MeasurementStrategy.intrinsic) {
      return _tryLayoutUsingIntrinsicSize(direction, mainConstraint);
    } else {
      return _tryLayoutUsingDryLayout(direction, mainConstraint);
    }
  }

  // Try layout using intrinsic size measurements
  bool _tryLayoutUsingIntrinsicSize(Axis direction, double mainConstraint) {
    double totalMainAxisSize = 0;
    final spacing = _getSpacingForDirection(direction);
    var isFirstChild = true;

    // Measure children using intrinsic sizes
    var child = firstChild;
    while (child != null) {
      double childMainAxisSize;
      if (direction == Axis.horizontal) {
        childMainAxisSize = child.getMaxIntrinsicWidth(constraints.maxHeight);
      } else {
        childMainAxisSize = child.getMaxIntrinsicHeight(constraints.maxWidth);
      }

      totalMainAxisSize += childMainAxisSize;

      // Add spacing except for the first child
      if (!isFirstChild) {
        totalMainAxisSize += spacing;
      }
      isFirstChild = false;

      // Early exit if we exceed the constraint
      if (totalMainAxisSize > mainConstraint) {
        return false;
      }

      child = childAfter(child);
    }

    return totalMainAxisSize <= mainConstraint;
  }

  // Try layout using dry layout for more accurate measurements
  bool _tryLayoutUsingDryLayout(Axis direction, double mainConstraint) {
    // Measure total size needed in the main axis
    double totalMainAxisSize = 0;
    final spacing = _getSpacingForDirection(direction);

    var child = firstChild;
    var isFirstChild = true;

    // Create appropriate constraints for measuring children
    final childConstraints = direction == Axis.horizontal
        ? BoxConstraints(maxHeight: constraints.maxHeight)
        : BoxConstraints(maxWidth: constraints.maxWidth);

    while (child != null) {
      // Get the child's size using dry layout
      final childSize = child.getDryLayout(childConstraints);

      // Get size in main axis
      final childMainAxisSize =
          direction == Axis.horizontal ? childSize.width : childSize.height;

      totalMainAxisSize += childMainAxisSize;

      // Add spacing except for the first child
      if (!isFirstChild) {
        totalMainAxisSize += spacing;
      }
      isFirstChild = false;

      // Early exit if we exceed the constraint
      if (totalMainAxisSize > mainConstraint) {
        return false;
      }

      // Move to next child
      child = childAfter(child);
    }

    // Check if it fits
    return totalMainAxisSize <= mainConstraint;
  }

  // Performs the actual layout in the given direction
  void _layoutWithDirection(Axis direction) {
    final isHorizontal = direction == Axis.horizontal;
    final directionSpacing = _getSpacingForDirection(direction);
    final alignment = _getAlignmentForDirection(direction);
    final crossAlignment = _getCrossAlignmentForDirection(direction);

    // Track the maximum cross-axis size and total main-axis size
    double maxCrossAxisSize = 0;
    double totalMainAxisSize = 0;

    // First pass: Layout all children and measure sizes
    final childrenList = <RenderBox>[];
    final mainSizes = <double>[];
    final crossSizes = <double>[];

    var child = firstChild;

    while (child != null) {
      // Create constraints for the child based on the layout direction
      final childConstraints = isHorizontal
          ? BoxConstraints(maxHeight: constraints.maxHeight)
          : BoxConstraints(maxWidth: constraints.maxWidth);

      child.layout(childConstraints, parentUsesSize: true);

      // Get the child's main and cross axis sizes
      final childMainAxisSize =
          isHorizontal ? child.size.width : child.size.height;
      final childCrossAxisSize =
          isHorizontal ? child.size.height : child.size.width;

      // Update tracking variables
      childrenList.add(child);
      mainSizes.add(childMainAxisSize);
      crossSizes.add(childCrossAxisSize);

      // Add the child's size to the total
      totalMainAxisSize += childMainAxisSize;
      maxCrossAxisSize = math.max(maxCrossAxisSize, childCrossAxisSize);

      // Move to next child
      child = childAfter(child);
    }

    // Calculate the space needed for spacing between children
    final spacingSize = directionSpacing * math.max(0, childrenList.length - 1);

    // Calculate the container size
    double containerMainAxisSize;

    // Check if we need to expand to fill available space for certain alignment modes
    final shouldExpandMainAxis = alignment == WrapAlignment.spaceBetween ||
        alignment == WrapAlignment.spaceAround ||
        alignment == WrapAlignment.spaceEvenly;

    if (shouldExpandMainAxis) {
      // Use maximum available space for these alignment modes
      containerMainAxisSize =
          isHorizontal ? constraints.maxWidth : constraints.maxHeight;
    } else {
      // Otherwise, use only as much space as needed
      containerMainAxisSize = isHorizontal
          ? constraints.constrainWidth(totalMainAxisSize + spacingSize)
          : constraints.constrainHeight(totalMainAxisSize + spacingSize);
    }

    final containerCrossAxisSize = isHorizontal
        ? constraints.constrainHeight(maxCrossAxisSize)
        : constraints.constrainWidth(maxCrossAxisSize);

    // Set the size of this render object
    size = isHorizontal
        ? Size(containerMainAxisSize, containerCrossAxisSize)
        : Size(containerCrossAxisSize, containerMainAxisSize);

    // Check for overflow
    _hasVisualOverflow =
        containerMainAxisSize < totalMainAxisSize + spacingSize ||
            containerCrossAxisSize < maxCrossAxisSize;

    // Calculate free space for alignment
    // THIS IS THE KEY FIX: properly calculate free space without including spacing
    final double freeMainAxisSpace =
        math.max(0, containerMainAxisSize - totalMainAxisSize - spacingSize);

    // Handle RTL text direction for horizontal layout
    final isRtl = isHorizontal && textDirection == TextDirection.rtl;

    if (isHorizontal && isRtl) {
      // RTL horizontal layout (right-to-left)
      _positionChildrenRtl(
          childrenList,
          mainSizes,
          crossSizes,
          containerMainAxisSize,
          containerCrossAxisSize,
          freeMainAxisSpace,
          directionSpacing,
          alignment,
          crossAlignment);
    } else {
      // LTR horizontal layout or vertical layout
      _positionChildrenLtr(
          childrenList,
          mainSizes,
          crossSizes,
          containerCrossAxisSize,
          freeMainAxisSpace,
          directionSpacing,
          alignment,
          crossAlignment,
          isHorizontal);
    }
  }

  void _positionChildrenLtr(
      List<RenderBox> children,
      List<double> mainSizes,
      List<double> crossSizes,
      double containerCrossAxisSize,
      double freeMainAxisSpace,
      double spacing,
      WrapAlignment alignment,
      WrapCrossAlignment crossAlignment,
      bool isHorizontal) {
    // No children to position
    if (children.isEmpty) {
      return;
    }

    // Calculate the leading space and space between children based on alignment
    double leadingSpace;
    double betweenSpace;

    switch (alignment) {
      case WrapAlignment.start:
        leadingSpace = 0.0;
        betweenSpace = spacing;
      case WrapAlignment.end:
        leadingSpace = freeMainAxisSpace;
        betweenSpace = spacing;
      case WrapAlignment.center:
        leadingSpace = freeMainAxisSpace / 2.0;
        betweenSpace = spacing;
      case WrapAlignment.spaceBetween:
        if (children.length > 1) {
          leadingSpace = 0.0;
          betweenSpace = spacing + freeMainAxisSpace / (children.length - 1);
        } else {
          // For single child, center it
          leadingSpace = freeMainAxisSpace / 2.0;
          betweenSpace = spacing;
        }
      case WrapAlignment.spaceAround:
        if (children.isNotEmpty) {
          final spacePerChild = freeMainAxisSpace / children.length;
          leadingSpace = spacePerChild / 2.0;
          betweenSpace = spacing + spacePerChild;
        } else {
          leadingSpace = 0.0;
          betweenSpace = spacing;
        }
      case WrapAlignment.spaceEvenly:
        if (children.isNotEmpty) {
          final spacePerGap = freeMainAxisSpace / (children.length + 1);
          leadingSpace = spacePerGap;
          betweenSpace = spacing + spacePerGap;
        } else {
          leadingSpace = 0.0;
          betweenSpace = spacing;
        }
    }

    // Start positioning from the leading edge plus the computed offset
    var currentOffset = leadingSpace;

    // Position each child
    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      final childMainAxisSize = mainSizes[i];
      final childCrossAxisSize = crossSizes[i];

      // Calculate cross axis offset based on alignment
      final childCrossAxisOffset = _getCrossAxisOffset(
          crossAlignment,
          containerCrossAxisSize,
          childCrossAxisSize,
          isHorizontal ? Axis.horizontal : Axis.vertical);

      // Position the child
      (child.parentData as SingleAxisWrapParentData?)?.offset = isHorizontal
          ? Offset(currentOffset, childCrossAxisOffset)
          : Offset(childCrossAxisOffset, currentOffset);

      // Move to the next position
      currentOffset += childMainAxisSize;

      // Add spacing only between children, not after the last one
      if (i < children.length - 1) {
        // Add the calculated spacing between items
        currentOffset += betweenSpace;
      }
    }
  }

  void _positionChildrenRtl(
      List<RenderBox> children,
      List<double> mainSizes,
      List<double> crossSizes,
      double containerMainAxisSize,
      double containerCrossAxisSize,
      double freeMainAxisSpace,
      double spacing,
      WrapAlignment alignment,
      WrapCrossAlignment crossAlignment) {
    // No children to position
    if (children.isEmpty) {
      return;
    }

    // Calculate the leading space and space between children based on alignment
    double leadingSpace;
    double betweenSpace;

    // For RTL, we need to flip start/end alignments
    final effectiveAlignment = alignment == WrapAlignment.start
        ? WrapAlignment.end
        : alignment == WrapAlignment.end
            ? WrapAlignment.start
            : alignment;

    switch (effectiveAlignment) {
      case WrapAlignment.start:
        leadingSpace = 0.0;
        betweenSpace = spacing;
      case WrapAlignment.end:
        leadingSpace = freeMainAxisSpace;
        betweenSpace = spacing;
      case WrapAlignment.center:
        leadingSpace = freeMainAxisSpace / 2.0;
        betweenSpace = spacing;
      case WrapAlignment.spaceBetween:
        if (children.length > 1) {
          leadingSpace = 0.0;
          betweenSpace = spacing + freeMainAxisSpace / (children.length - 1);
        } else {
          // For single child, center it
          leadingSpace = freeMainAxisSpace / 2.0;
          betweenSpace = spacing;
        }
      case WrapAlignment.spaceAround:
        if (children.isNotEmpty) {
          final spacePerChild = freeMainAxisSpace / children.length;
          leadingSpace = spacePerChild / 2.0;
          betweenSpace = spacing + spacePerChild;
        } else {
          leadingSpace = 0.0;
          betweenSpace = spacing;
        }
      case WrapAlignment.spaceEvenly:
        if (children.isNotEmpty) {
          final spacePerGap = freeMainAxisSpace / (children.length + 1);
          leadingSpace = spacePerGap;
          betweenSpace = spacing + spacePerGap;
        } else {
          leadingSpace = 0.0;
          betweenSpace = spacing;
        }
    }

    // Start positioning from the trailing edge
    var currentOffset = containerMainAxisSize - leadingSpace;

    // Position each child from right-to-left
    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      final childMainAxisSize = mainSizes[i];
      final childCrossAxisSize = crossSizes[i];

      // Calculate cross axis offset based on alignment
      final childCrossAxisOffset = _getCrossAxisOffset(crossAlignment,
          containerCrossAxisSize, childCrossAxisSize, Axis.horizontal);

      // Move offset by child width first (RTL layout)
      currentOffset -= childMainAxisSize;

      // Set the child position
      (child.parentData as SingleAxisWrapParentData?)?.offset =
          Offset(currentOffset, childCrossAxisOffset);

      // Subtract spacing only between children, not after the last one
      if (i < children.length - 1) {
        // Subtract the calculated spacing between items
        currentOffset -= betweenSpace;
      }
    }
  }

// Calculates the offset in the cross axis based on alignment
  double _getCrossAxisOffset(
    WrapCrossAlignment alignment,
    double containerSize,
    double childSize,
    Axis direction,
  ) {
    // Determine if alignment should be flipped based on text/vertical direction
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
          EnumProperty<Axis>('currentLayoutDirection', _currentLayoutDirection))
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
      ..add(EnumProperty<TextDirection>('textDirection', textDirection))
      ..add(EnumProperty<VerticalDirection>(
          'verticalDirection', verticalDirection))
      ..add(EnumProperty<Clip>('clipBehavior', clipBehavior))
      ..add(EnumProperty<MeasurementStrategy>(
          'measurementStrategy', measurementStrategy))
      ..add(FlagProperty('maintainLayout',
          value: maintainLayout, ifTrue: 'enabled', ifFalse: 'disabled'))
      ..add(FlagProperty('hasVisualOverflow',
          value: _hasVisualOverflow, ifTrue: 'overflow', ifFalse: 'contained'));
  }
}
