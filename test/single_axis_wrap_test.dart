import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:single_axis_wrap/single_axis_wrap.dart';

void main() {
  group('SingleAxisWrap - Creation and rendering', () {
    testWidgets('creates without error', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleAxisWrap(children: [SizedBox(width: 100, height: 50)]),
          ),
        ),
      );

      expect(find.byType(SingleAxisWrap), findsOneWidget);
    });

    testWidgets('renders with multiple children', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleAxisWrap(
              children: List.generate(
                3,
                (index) => SizedBox(
                  width: 100,
                  height: 50,
                  child: Text('Child $index'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Child 0'), findsOneWidget);
      expect(find.text('Child 1'), findsOneWidget);
      expect(find.text('Child 2'), findsOneWidget);
    });

    testWidgets('renders with zero children', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SingleAxisWrap(children: [])),
        ),
      );

      expect(find.byType(SingleAxisWrap), findsOneWidget);
    });
  });

  group('SingleAxisWrap - Layout direction selection', () {
    testWidgets('uses horizontal layout when items fit', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 350, // Enough for 3 items of width 100 plus spacing
              child: SingleAxisWrap(
                primaryDirection: Axis.horizontal,
                spacing: 10,
                children: List.generate(
                  3,
                  (index) =>
                      Container(width: 100, height: 50, color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
      );

      // In horizontal layout, the first and second children should have different X positions
      final firstChild = find.byType(Container).at(0);
      final secondChild = find.byType(Container).at(1);

      final firstChildPos = tester.getTopLeft(firstChild);
      final secondChildPos = tester.getTopLeft(secondChild);

      expect(firstChildPos.dx, lessThan(secondChildPos.dx));
      expect(
        firstChildPos.dy,
        equals(secondChildPos.dy),
      ); // Same Y position in row
    });

    testWidgets(
      'switches to vertical layout when items do not fit horizontally',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 250,
                // Not enough for 3 items of width 100 plus spacing
                child: SingleAxisWrap(
                  primaryDirection: Axis.horizontal,
                  spacing: 10,
                  children: List.generate(
                    3,
                    (index) =>
                        Container(width: 100, height: 50, color: Colors.blue),
                  ),
                ),
              ),
            ),
          ),
        );

        // In vertical layout, the first and second children should have different Y positions
        final firstChild = find.byType(Container).at(0);
        final secondChild = find.byType(Container).at(1);

        final firstChildPos = tester.getTopLeft(firstChild);
        final secondChildPos = tester.getTopLeft(secondChild);

        expect(
          firstChildPos.dx,
          equals(secondChildPos.dx),
        ); // Same X position in column
        expect(
          firstChildPos.dy,
          lessThan(secondChildPos.dy),
        ); // Different Y positions
      },
    );

    testWidgets(
      'uses vertical layout when primaryDirection is vertical and items fit',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 180, // Enough for 3 items of height 50 plus spacing
                child: SingleAxisWrap(
                  primaryDirection: Axis.vertical,
                  spacing: 10,
                  children: List.generate(
                    3,
                    (index) =>
                        Container(width: 100, height: 50, color: Colors.blue),
                  ),
                ),
              ),
            ),
          ),
        );

        // In vertical layout, children should be stacked vertically
        final firstChild = find.byType(Container).at(0);
        final secondChild = find.byType(Container).at(1);

        final firstChildPos = tester.getTopLeft(firstChild);
        final secondChildPos = tester.getTopLeft(secondChild);

        expect(firstChildPos.dx, equals(secondChildPos.dx)); // Same X position
        expect(
          firstChildPos.dy,
          lessThan(secondChildPos.dy),
        ); // Different Y positions
      },
    );

    testWidgets(
      'switches to horizontal layout when items do not fit vertically',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 120,
                // Not enough for 3 items of height 50 plus spacing
                child: SingleAxisWrap(
                  primaryDirection: Axis.vertical,
                  spacing: 10,
                  children: List.generate(
                    3,
                    (index) =>
                        Container(width: 100, height: 50, color: Colors.blue),
                  ),
                ),
              ),
            ),
          ),
        );

        // Should switch to horizontal layout
        final firstChild = find.byType(Container).at(0);
        final secondChild = find.byType(Container).at(1);

        final firstChildPos = tester.getTopLeft(firstChild);
        final secondChildPos = tester.getTopLeft(secondChild);

        expect(
          firstChildPos.dx,
          lessThan(secondChildPos.dx),
        ); // Different X positions
        expect(
          firstChildPos.dy,
          equals(secondChildPos.dy),
        ); // Same Y position in row
      },
    );
  });

  group('SingleAxisWrap - MaintainLayout feature', () {
    testWidgets('maintains horizontal layout when container shrinks', (
      WidgetTester tester,
    ) async {
      // Key to get the state
      final key = GlobalKey();

      // First build with sufficient width for horizontal layout
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 350, // Enough for 3 items of width 100 plus spacing
              child: SingleAxisWrap(
                key: key,
                primaryDirection: Axis.horizontal,
                spacing: 10,
                maintainLayout: true,
                children: List.generate(
                  3,
                  (index) =>
                      Container(width: 100, height: 50, color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
      );

      // Verify initial horizontal layout
      final firstChild = find.byType(Container).at(0);
      final secondChild = find.byType(Container).at(1);

      final firstChildPos = tester.getTopLeft(firstChild);
      final secondChildPos = tester.getTopLeft(secondChild);

      expect(
        firstChildPos.dx,
        lessThan(secondChildPos.dx),
      ); // Different X positions

      // Now shrink the container so items wouldn't normally fit horizontally
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width:
                  250, // Not enough for 3 items, but should maintain horizontal
              child: SingleAxisWrap(
                key: key,
                primaryDirection: Axis.horizontal,
                spacing: 10,
                maintainLayout: true,
                children: List.generate(
                  3,
                  (index) =>
                      Container(width: 100, height: 50, color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
      );

      // Even after resizing, layout should still be horizontal
      final firstChildAfter = find.byType(Container).at(0);
      final secondChildAfter = find.byType(Container).at(1);

      final firstChildPosAfter = tester.getTopLeft(firstChildAfter);
      final secondChildPosAfter = tester.getTopLeft(secondChildAfter);

      // Still different X positions (horizontal layout maintained)
      expect(firstChildPosAfter.dx, lessThan(secondChildPosAfter.dx));
    });

    testWidgets('updates layout when maintainLayout is false', (
      WidgetTester tester,
    ) async {
      // First build with sufficient width for horizontal layout
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 350, // Enough for 3 items of width 100 plus spacing
              child: SingleAxisWrap(
                primaryDirection: Axis.horizontal,
                spacing: 10,
                maintainLayout: false, // Will not maintain layout
                children: List.generate(
                  3,
                  (index) =>
                      Container(width: 100, height: 50, color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
      );

      // Now shrink the container so items wouldn't fit horizontally
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 250, // Not enough for 3 items
              child: SingleAxisWrap(
                primaryDirection: Axis.horizontal,
                spacing: 10,
                maintainLayout: false,
                children: List.generate(
                  3,
                  (index) =>
                      Container(width: 100, height: 50, color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
      );

      // Should switch to vertical layout
      final firstChild = find.byType(Container).at(0);
      final secondChild = find.byType(Container).at(1);

      final firstChildPos = tester.getTopLeft(firstChild);
      final secondChildPos = tester.getTopLeft(secondChild);

      expect(firstChildPos.dx, equals(secondChildPos.dx)); // Same X in column
      expect(
        firstChildPos.dy,
        lessThan(secondChildPos.dy),
      ); // Different Y positions
    });

    testWidgets('keeps maintained direction across temporary empty children', (
      WidgetTester tester,
    ) async {
      const key = ValueKey<String>('maintained-wrap');

      await _pumpConstrainedWrap(
        tester,
        key: key,
        maxWidth: 400,
        maxHeight: 300,
        maintainLayout: true,
        childCount: 2,
      );

      await _pumpConstrainedWrap(
        tester,
        key: key,
        maxWidth: 90,
        maxHeight: 300,
        maintainLayout: true,
        childCount: 0,
      );

      await _pumpConstrainedWrap(
        tester,
        key: key,
        maxWidth: 90,
        maxHeight: 300,
        maintainLayout: true,
        childCount: 2,
      );

      final first = tester.getTopLeft(
        find.byKey(const ValueKey<String>('box-0')),
      );
      final second = tester.getTopLeft(
        find.byKey(const ValueKey<String>('box-1')),
      );

      expect(first.dx, lessThan(second.dx));
      expect(first.dy, second.dy);
    });
  });

  group('SingleAxisWrap - Spacing', () {
    test('rejects non-finite spacing values', () {
      expect(
        () => SingleAxisWrap(spacing: double.infinity, children: const []),
        throwsAssertionError,
      );
      expect(
        () => SingleAxisWrap(
          horizontalSpacing: double.infinity,
          children: const [],
        ),
        throwsAssertionError,
      );
      expect(
        () => SingleAxisWrap(verticalSpacing: double.nan, children: const []),
        throwsAssertionError,
      );
    });

    testWidgets('applies horizontal spacing correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500,
              child: SingleAxisWrap(
                primaryDirection: Axis.horizontal,
                spacing: 20, // 20px spacing
                children: List.generate(
                  3,
                  (index) =>
                      Container(width: 100, height: 50, color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
      );

      final firstChild = find.byType(Container).at(0);
      final secondChild = find.byType(Container).at(1);

      final firstChildRect = tester.getRect(firstChild);
      final secondChildRect = tester.getRect(secondChild);

      // Gap between items should be 20px
      expect(secondChildRect.left - firstChildRect.right, equals(20.0));
    });

    testWidgets('applies vertical spacing correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 90,
              // Force vertical layout (less than container width)
              child: SingleAxisWrap(
                primaryDirection: Axis.horizontal,
                spacing: 15, // 15px spacing
                children: List.generate(
                  3,
                  (index) =>
                      Container(width: 100, height: 50, color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
      );

      final firstChild = find.byType(Container).at(0);
      final secondChild = find.byType(Container).at(1);

      final firstChildRect = tester.getRect(firstChild);
      final secondChildRect = tester.getRect(secondChild);

      // Gap between items should be 15px
      expect(secondChildRect.top - firstChildRect.bottom, equals(15.0));
    });

    testWidgets('uses direction-specific spacing when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500,
              child: SingleAxisWrap(
                primaryDirection: Axis.horizontal,
                spacing: 10,
                horizontalSpacing: 25, // This should override spacing
                children: List.generate(
                  3,
                  (index) =>
                      Container(width: 100, height: 50, color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
      );

      final firstChild = find.byType(Container).at(0);
      final secondChild = find.byType(Container).at(1);

      final firstChildRect = tester.getRect(firstChild);
      final secondChildRect = tester.getRect(secondChild);

      // Gap between items should be 25px (horizontalSpacing)
      expect(secondChildRect.left - firstChildRect.right, equals(25.0));
    });

    testWidgets('uses verticalSpacing override in vertical layout', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 500,
              child: SingleAxisWrap(
                primaryDirection: Axis.vertical,
                spacing: 4,
                verticalSpacing: 18,
                children: List.generate(
                  2,
                  (index) => SizedBox(
                    key: ValueKey<String>('spacing-box-$index'),
                    width: 100,
                    height: 50,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final first = tester.getRect(
        find.byKey(const ValueKey<String>('spacing-box-0')),
      );
      final second = tester.getRect(
        find.byKey(const ValueKey<String>('spacing-box-1')),
      );

      expect(second.top - first.bottom, 18);
    });
  });

  group('SingleAxisWrap - Alignment', () {
    testWidgets('aligns horizontally with start alignment', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500, // Wider than needed
              child: SingleAxisWrap(
                primaryDirection: Axis.horizontal,
                horizontalAlignment: WrapAlignment.start,
                children: List.generate(
                  2,
                  (index) =>
                      Container(width: 100, height: 50, color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
      );

      final firstChild = find.byType(Container).first;
      final firstChildPos = tester.getTopLeft(firstChild);

      // First child should be at the start (left edge)
      expect(firstChildPos.dx, equals(0.0));
    });

    testWidgets('aligns horizontally with center alignment', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500, // Wider than needed
              child: SingleAxisWrap(
                primaryDirection: Axis.horizontal,
                horizontalAlignment: WrapAlignment.center,
                spacing: 0,
                children: List.generate(
                  2,
                  (index) =>
                      Container(width: 100, height: 50, color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
      );

      final firstChild = find.byType(Container).first;
      final firstChildPos = tester.getTopLeft(firstChild);

      // First child should be centered (500 - (2 * 100)) / 2 = 150px from left
      expect(firstChildPos.dx, closeTo(150.0, 1.0));
    });

    testWidgets('aligns horizontally with end alignment', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500, // Wider than needed
              child: SingleAxisWrap(
                primaryDirection: Axis.horizontal,
                horizontalAlignment: WrapAlignment.end,
                spacing: 0,
                children: List.generate(
                  2,
                  (index) =>
                      Container(width: 100, height: 50, color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
      );

      final firstChild = find.byType(Container).first;
      final firstChildPos = tester.getTopLeft(firstChild);

      // First child should be at 500 - (2 * 100) = 300px from left
      expect(firstChildPos.dx, closeTo(300.0, 1.0));
    });

    testWidgets('cross-axis alignment works in horizontal layout', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500,
              height: 200,
              child: SingleAxisWrap(
                primaryDirection: Axis.horizontal,
                horizontalCrossAxisAlignment: WrapCrossAlignment.center,
                children: List.generate(
                  2,
                  (index) =>
                      Container(width: 100, height: 50, color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
      );

      final firstChild = find.byType(Container).first;
      final firstChildPos = tester.getTopLeft(firstChild);

      // Child should be centered vertically (200 - 50) / 2 = 75px from top
      expect(firstChildPos.dy, closeTo(75.0, 1.0));
    });
  });

  group('SingleAxisWrap - Callbacks', () {
    testWidgets('fires onLayoutDirectionChanged when layout changes', (
      WidgetTester tester,
    ) async {
      Axis? lastDirection;
      var callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 350, // Enough for 3 items
              child: SingleAxisWrap(
                primaryDirection: Axis.horizontal,
                spacing: 10,
                onLayoutDirectionChanged: (direction) {
                  lastDirection = direction;
                  callCount++;
                },
                children: List.generate(
                  3,
                  (index) =>
                      Container(width: 100, height: 50, color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
      );

      // Initial layout shouldn't trigger callback since it matches primary direction
      expect(callCount, equals(0));

      // Shrink the container to force vertical layout
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 250, // Not enough for 3 items
              child: SingleAxisWrap(
                primaryDirection: Axis.horizontal,
                spacing: 10,
                onLayoutDirectionChanged: (direction) {
                  lastDirection = direction;
                  callCount++;
                },
                children: List.generate(
                  3,
                  (index) =>
                      Container(width: 100, height: 50, color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
      );

      // Callback should be fired once with vertical direction
      expect(callCount, equals(1));
      expect(lastDirection, equals(Axis.vertical));

      // Expand the container again to allow horizontal layout
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 350, // Enough for 3 items
              child: SingleAxisWrap(
                primaryDirection: Axis.horizontal,
                spacing: 10,
                onLayoutDirectionChanged: (direction) {
                  lastDirection = direction;
                  callCount++;
                },
                children: List.generate(
                  3,
                  (index) =>
                      Container(width: 100, height: 50, color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
      );

      // Callback should be fired again with horizontal direction
      expect(callCount, equals(2));
      expect(lastDirection, equals(Axis.horizontal));
    });
  });

  group('SingleAxisWrap - Edge cases', () {
    testWidgets('handles single child correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: SingleAxisWrap(
                primaryDirection: Axis.horizontal,
                children: [
                  Container(width: 100, height: 50, color: Colors.blue),
                ],
              ),
            ),
          ),
        ),
      );

      // Should render without errors
      expect(find.byType(Container), findsOneWidget);

      // Child should be positioned at the start
      final child = find.byType(Container);
      final childPos = tester.getTopLeft(child);
      expect(childPos.dx, equals(0.0));
      expect(childPos.dy, equals(0.0));
    });

    testWidgets('handles RTL text direction', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: SizedBox(
                width: 500,
                child: SingleAxisWrap(
                  primaryDirection: Axis.horizontal,
                  horizontalAlignment: WrapAlignment.start,
                  children: List.generate(
                    3,
                    (index) => Container(
                      width: 100,
                      height: 50,
                      color: Colors.blue,
                      child: Text('Item $index'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // In RTL, items should be laid out from right to left
      final firstChild = find.text('Item 0');
      final secondChild = find.text('Item 1');

      final firstChildRect = tester.getRect(firstChild);
      final secondChildRect = tester.getRect(secondChild);

      // First item should be to the right of the second
      expect(firstChildRect.left, greaterThan(secondChildRect.left));
    });

    testWidgets('handles clipping when overflow occurs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 250, // Not enough for items
              height: 100,
              child: SingleAxisWrap(
                primaryDirection: Axis.horizontal,
                clipBehavior: Clip.hardEdge,
                children: List.generate(
                  5, // Many items to ensure overflow
                  (index) =>
                      Container(width: 100, height: 50, color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
      );

      // Should render without errors
      expect(find.byType(SingleAxisWrap), findsOneWidget);
      // Should find Container widgets
      expect(find.byType(Container), findsWidgets);
    });
  });

  group('SingleAxisWrap - Render contract', () {
    testWidgets('dry layout matches horizontal layout when primary fits', (
      WidgetTester tester,
    ) async {
      await _pumpConstrainedWrap(tester, maxWidth: 400, maxHeight: 300);

      _expectDryLayoutMatchesActual(tester);
    });

    testWidgets('dry layout matches vertical fallback', (
      WidgetTester tester,
    ) async {
      await _pumpConstrainedWrap(tester, maxWidth: 250, maxHeight: 300);

      _expectDryLayoutMatchesActual(tester);
    });

    testWidgets('dry layout matches vertical layout when primary fits', (
      WidgetTester tester,
    ) async {
      await _pumpConstrainedWrap(
        tester,
        maxWidth: 400,
        maxHeight: 300,
        primaryDirection: Axis.vertical,
      );

      _expectDryLayoutMatchesActual(tester);
    });

    testWidgets('dry layout matches horizontal fallback', (
      WidgetTester tester,
    ) async {
      await _pumpConstrainedWrap(
        tester,
        maxWidth: 400,
        maxHeight: 120,
        primaryDirection: Axis.vertical,
      );

      _expectDryLayoutMatchesActual(tester);
    });

    testWidgets('intrinsics do not depend on the last layout direction', (
      WidgetTester tester,
    ) async {
      final previousDebugCheckIntrinsicSizes = debugCheckIntrinsicSizes;
      debugCheckIntrinsicSizes = true;

      try {
        await _pumpConstrainedWrap(
          tester,
          maxWidth: 400,
          maxHeight: 300,
          key: const ValueKey<String>('stable-wrap'),
        );

        final wideRender = tester.renderObject<RenderBox>(
          find.byType(SingleAxisWrap),
        );
        final wideIntrinsicWidth = wideRender.getMinIntrinsicWidth(
          double.infinity,
        );

        await _pumpConstrainedWrap(
          tester,
          maxWidth: 250,
          maxHeight: 300,
          key: const ValueKey<String>('stable-wrap'),
        );

        final narrowRender = tester.renderObject<RenderBox>(
          find.byType(SingleAxisWrap),
        );
        final narrowIntrinsicWidth = narrowRender.getMinIntrinsicWidth(
          double.infinity,
        );

        expect(narrowIntrinsicWidth, wideIntrinsicWidth);
      } finally {
        debugCheckIntrinsicSizes = previousDebugCheckIntrinsicSizes;
      }
    });

    testWidgets(
      'intrinsic height falls back when horizontal primary is narrow',
      (WidgetTester tester) async {
        final previousDebugCheckIntrinsicSizes = debugCheckIntrinsicSizes;
        debugCheckIntrinsicSizes = true;

        try {
          await _pumpConstrainedWrap(
            tester,
            maxWidth: 400,
            maxHeight: 300,
            childCount: 2,
          );

          final render = tester.renderObject<RenderBox>(
            find.byType(SingleAxisWrap),
          );

          expect(render.getMinIntrinsicHeight(150), 110);
          expect(render.getMaxIntrinsicHeight(150), 110);
        } finally {
          debugCheckIntrinsicSizes = previousDebugCheckIntrinsicSizes;
        }
      },
    );

    testWidgets('horizontal primary intrinsic width exposes compact fallback', (
      WidgetTester tester,
    ) async {
      await _pumpConstrainedWrap(
        tester,
        maxWidth: 400,
        maxHeight: 300,
        childCount: 2,
      );

      final render = tester.renderObject<RenderBox>(
        find.byType(SingleAxisWrap),
      );

      expect(render.getMinIntrinsicWidth(double.infinity), 100);
      expect(render.getMinIntrinsicWidth(110), 100);
      expect(render.getMinIntrinsicWidth(50), 210);
      expect(render.getMaxIntrinsicWidth(double.infinity), 210);
    });

    testWidgets('intrinsic width falls back when vertical primary is short', (
      WidgetTester tester,
    ) async {
      final previousDebugCheckIntrinsicSizes = debugCheckIntrinsicSizes;
      debugCheckIntrinsicSizes = true;

      try {
        await _pumpConstrainedWrap(
          tester,
          maxWidth: 400,
          maxHeight: 300,
          primaryDirection: Axis.vertical,
          childCount: 2,
        );

        final render = tester.renderObject<RenderBox>(
          find.byType(SingleAxisWrap),
        );

        expect(render.getMinIntrinsicWidth(90), 210);
        expect(render.getMaxIntrinsicWidth(90), 210);
      } finally {
        debugCheckIntrinsicSizes = previousDebugCheckIntrinsicSizes;
      }
    });

    testWidgets('vertical primary intrinsic height exposes compact fallback', (
      WidgetTester tester,
    ) async {
      await _pumpConstrainedWrap(
        tester,
        maxWidth: 400,
        maxHeight: 300,
        primaryDirection: Axis.vertical,
        childCount: 2,
      );

      final render = tester.renderObject<RenderBox>(
        find.byType(SingleAxisWrap),
      );

      expect(render.getMinIntrinsicHeight(double.infinity), 50);
      expect(render.getMinIntrinsicHeight(210), 50);
      expect(render.getMinIntrinsicHeight(100), 110);
      expect(render.getMaxIntrinsicHeight(double.infinity), 110);
    });

    testWidgets('dry baseline uses child baseline for horizontal layout', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SingleAxisWrap(children: [Text('Baseline')]),
            ),
          ),
        ),
      );

      final render = tester.renderObject<RenderBox>(
        find.byType(SingleAxisWrap),
      );

      final dryBaseline = render.getDryBaseline(
        render.constraints,
        TextBaseline.alphabetic,
      );
      final child = tester.renderObject<RenderBox>(find.text('Baseline'));
      final childBaseline = child.getDryBaseline(
        child.constraints,
        TextBaseline.alphabetic,
      );

      expect(dryBaseline, isNotNull);
      expect(childBaseline, isNotNull);
      expect(dryBaseline!, moreOrLessEquals(childBaseline!));
    });

    testWidgets('vertical dry baseline uses the first child baseline', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SingleAxisWrap(
                primaryDirection: Axis.vertical,
                verticalDirection: VerticalDirection.up,
                spacing: 8,
                children: [Text('First'), Text('Second')],
              ),
            ),
          ),
        ),
      );

      final render = tester.renderObject<RenderBox>(
        find.byType(SingleAxisWrap),
      );
      final renderTop = tester.getTopLeft(find.byType(SingleAxisWrap));

      final dryBaseline = render.getDryBaseline(
        render.constraints,
        TextBaseline.alphabetic,
      );
      final child = tester.renderObject<RenderBox>(find.text('First'));
      final childTop = tester.getTopLeft(find.text('First'));
      final childBaseline = child.getDryBaseline(
        child.constraints,
        TextBaseline.alphabetic,
      );
      expect(childBaseline, isNotNull);

      final firstChildBaselineOffset =
          childTop.dy - renderTop.dy + childBaseline!;

      expect(dryBaseline, isNotNull);
      expect(dryBaseline!, moreOrLessEquals(firstChildBaselineOffset));
    });

    testWidgets('describes paint clip when overflowing children are clipped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 90, maxHeight: 80),
                child: SingleAxisWrap(
                  clipBehavior: Clip.hardEdge,
                  children: _boxes(count: 3),
                ),
              ),
            ),
          ),
        ),
      );

      final render = tester.renderObject<RenderBox>(
        find.byType(SingleAxisWrap),
      );
      final child = tester.renderObject<RenderBox>(
        find.byKey(const ValueKey<String>('box-0')),
      );

      expect(
        render.describeApproximatePaintClip(child),
        Offset.zero & render.size,
      );
    });
  });

  group('SingleAxisWrap - Directionality semantics', () {
    testWidgets('horizontal RTL start places first child at the right edge', (
      WidgetTester tester,
    ) async {
      await _pumpConstrainedWrap(
        tester,
        minWidth: 500,
        maxWidth: 500,
        maxHeight: 100,
        textDirection: TextDirection.rtl,
        childCount: 2,
      );

      final first = tester.getRect(find.byKey(const ValueKey<String>('box-0')));
      final second = tester.getRect(
        find.byKey(const ValueKey<String>('box-1')),
      );

      expect(first.left, 400);
      expect(second.left, 290);
    });

    testWidgets(
      'horizontal RTL end places first child at the left group edge',
      (WidgetTester tester) async {
        await _pumpConstrainedWrap(
          tester,
          minWidth: 500,
          maxWidth: 500,
          maxHeight: 100,
          textDirection: TextDirection.rtl,
          horizontalAlignment: WrapAlignment.end,
          childCount: 2,
        );

        final first = tester.getRect(
          find.byKey(const ValueKey<String>('box-0')),
        );
        final second = tester.getRect(
          find.byKey(const ValueKey<String>('box-1')),
        );

        expect(first.left, 110);
        expect(second.left, 0);
      },
    );

    testWidgets('verticalDirection up places the first child at the bottom', (
      WidgetTester tester,
    ) async {
      await _pumpConstrainedWrap(
        tester,
        minHeight: 200,
        maxWidth: 120,
        maxHeight: 200,
        primaryDirection: Axis.vertical,
        verticalDirection: VerticalDirection.up,
        childCount: 2,
      );

      final first = tester.getRect(find.byKey(const ValueKey<String>('box-0')));
      final second = tester.getRect(
        find.byKey(const ValueKey<String>('box-1')),
      );

      expect(first.top, 150);
      expect(second.top, 90);
    });
  });

  group('SingleAxisWrap - Alignment edge cases', () {
    testWidgets('spaceBetween with one child behaves like start', (
      WidgetTester tester,
    ) async {
      await _pumpConstrainedWrap(
        tester,
        minWidth: 300,
        maxWidth: 300,
        maxHeight: 100,
        horizontalAlignment: WrapAlignment.spaceBetween,
        childCount: 1,
      );

      final child = tester.getRect(find.byKey(const ValueKey<String>('box-0')));

      expect(child.left, 0);
    });

    testWidgets('spaceAround with one child centers the child', (
      WidgetTester tester,
    ) async {
      await _pumpConstrainedWrap(
        tester,
        minWidth: 300,
        maxWidth: 300,
        maxHeight: 100,
        horizontalAlignment: WrapAlignment.spaceAround,
        childCount: 1,
      );

      final child = tester.getRect(find.byKey(const ValueKey<String>('box-0')));

      expect(child.left, 100);
    });

    testWidgets('spaceEvenly with one child centers the child', (
      WidgetTester tester,
    ) async {
      await _pumpConstrainedWrap(
        tester,
        minWidth: 300,
        maxWidth: 300,
        maxHeight: 100,
        horizontalAlignment: WrapAlignment.spaceEvenly,
        childCount: 1,
      );

      final child = tester.getRect(find.byKey(const ValueKey<String>('box-0')));

      expect(child.left, 100);
    });
  });

  group('SingleAxisWrap - Unbounded constraints', () {
    testWidgets('unbounded primary axis keeps primary direction', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                height: 80,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleAxisWrap(
                    spacing: 10,
                    children: _boxes(count: 3),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final first = tester.getTopLeft(
        find.byKey(const ValueKey<String>('box-0')),
      );
      final second = tester.getTopLeft(
        find.byKey(const ValueKey<String>('box-1')),
      );
      final render = tester.renderObject<RenderBox>(
        find.byType(SingleAxisWrap),
      );

      expect(first.dx, lessThan(second.dx));
      expect(first.dy, second.dy);
      expect(render.size.width.isFinite, isTrue);
    });

    testWidgets('space alignment shrink-wraps in unbounded main axis', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                height: 80,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleAxisWrap(
                    horizontalAlignment: WrapAlignment.spaceEvenly,
                    spacing: 10,
                    children: _boxes(count: 3),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final render = tester.renderObject<RenderBox>(
        find.byType(SingleAxisWrap),
      );

      expect(render.size.width, 320);
      expect(render.size.width.isFinite, isTrue);
    });
  });

  group('SingleAxisWrap - Callback behavior', () {
    testWidgets('fires when primaryDirection changes the visible axis', (
      WidgetTester tester,
    ) async {
      final directions = <Axis>[];

      await _pumpConstrainedWrap(
        tester,
        maxWidth: 400,
        maxHeight: 300,
        onLayoutDirectionChanged: directions.add,
      );

      expect(directions, isEmpty);

      await _pumpConstrainedWrap(
        tester,
        maxWidth: 400,
        maxHeight: 300,
        primaryDirection: Axis.vertical,
        onLayoutDirectionChanged: directions.add,
      );

      expect(directions, [Axis.vertical]);
    });

    testWidgets('does not crash when callback is removed', (
      WidgetTester tester,
    ) async {
      final directions = <Axis>[];

      await _pumpConstrainedWrap(
        tester,
        maxWidth: 400,
        maxHeight: 300,
        onLayoutDirectionChanged: directions.add,
      );

      await _pumpConstrainedWrap(tester, maxWidth: 250, maxHeight: 300);

      expect(tester.takeException(), isNull);
      expect(directions, isEmpty);
    });
  });
}

Future<void> _pumpConstrainedWrap(
  WidgetTester tester, {
  Key? key,
  double minWidth = 0,
  double maxWidth = double.infinity,
  double minHeight = 0,
  double maxHeight = double.infinity,
  Axis primaryDirection = Axis.horizontal,
  TextDirection textDirection = TextDirection.ltr,
  VerticalDirection verticalDirection = VerticalDirection.down,
  WrapAlignment horizontalAlignment = WrapAlignment.start,
  MeasurementStrategy measurementStrategy = MeasurementStrategy.layout,
  LayoutDirectionCallback? onLayoutDirectionChanged,
  bool maintainLayout = false,
  int childCount = 3,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Directionality(
          textDirection: textDirection,
          child: Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: minWidth,
                maxWidth: maxWidth,
                minHeight: minHeight,
                maxHeight: maxHeight,
              ),
              child: SingleAxisWrap(
                key: key,
                primaryDirection: primaryDirection,
                verticalDirection: verticalDirection,
                horizontalAlignment: horizontalAlignment,
                measurementStrategy: measurementStrategy,
                onLayoutDirectionChanged: onLayoutDirectionChanged,
                maintainLayout: maintainLayout,
                spacing: 10,
                children: _boxes(count: childCount),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

List<Widget> _boxes({required int count}) {
  return List<Widget>.generate(
    count,
    (index) =>
        SizedBox(key: ValueKey<String>('box-$index'), width: 100, height: 50),
  );
}

void _expectDryLayoutMatchesActual(WidgetTester tester) {
  final render = tester.renderObject<RenderBox>(find.byType(SingleAxisWrap));

  expect(render.getDryLayout(render.constraints), render.size);
}
