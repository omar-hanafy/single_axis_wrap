import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:single_axis_wrap/single_axis_wrap.dart';

void main() {
  group('SingleAxisWrap - Creation and rendering', () {
    testWidgets('creates without error', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleAxisWrap(
              children: [
                SizedBox(width: 100, height: 50),
              ],
            ),
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
          home: Scaffold(
            body: SingleAxisWrap(
              children: [],
            ),
          ),
        ),
      );

      expect(find.byType(SingleAxisWrap), findsOneWidget);
    });
  });

  group('SingleAxisWrap - Layout direction selection', () {
    testWidgets('uses horizontal layout when items fit',
        (WidgetTester tester) async {
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
                  (index) => Container(
                    width: 100,
                    height: 50,
                    color: Colors.blue,
                  ),
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
      expect(firstChildPos.dy,
          equals(secondChildPos.dy)); // Same Y position in row
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
                  (index) => Container(
                    width: 100,
                    height: 50,
                    color: Colors.blue,
                  ),
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

      expect(firstChildPos.dx,
          equals(secondChildPos.dx)); // Same X position in column
      expect(firstChildPos.dy,
          lessThan(secondChildPos.dy)); // Different Y positions
    });

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
                  (index) => Container(
                    width: 100,
                    height: 50,
                    color: Colors.blue,
                  ),
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
      expect(firstChildPos.dy,
          lessThan(secondChildPos.dy)); // Different Y positions
    });

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
                  (index) => Container(
                    width: 100,
                    height: 50,
                    color: Colors.blue,
                  ),
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

      expect(firstChildPos.dx,
          lessThan(secondChildPos.dx)); // Different X positions
      expect(firstChildPos.dy,
          equals(secondChildPos.dy)); // Same Y position in row
    });
  });

  group('SingleAxisWrap - MaintainLayout feature', () {
    testWidgets('maintains horizontal layout when container shrinks',
        (WidgetTester tester) async {
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
                  (index) => Container(
                    width: 100,
                    height: 50,
                    color: Colors.blue,
                  ),
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

      expect(firstChildPos.dx,
          lessThan(secondChildPos.dx)); // Different X positions

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
                  (index) => Container(
                    width: 100,
                    height: 50,
                    color: Colors.blue,
                  ),
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

    testWidgets('updates layout when maintainLayout is false',
        (WidgetTester tester) async {
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
                  (index) => Container(
                    width: 100,
                    height: 50,
                    color: Colors.blue,
                  ),
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
                  (index) => Container(
                    width: 100,
                    height: 50,
                    color: Colors.blue,
                  ),
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
      expect(firstChildPos.dy,
          lessThan(secondChildPos.dy)); // Different Y positions
    });
  });

  group('SingleAxisWrap - Spacing', () {
    testWidgets('applies horizontal spacing correctly',
        (WidgetTester tester) async {
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
                  (index) => Container(
                    width: 100,
                    height: 50,
                    color: Colors.blue,
                  ),
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

    testWidgets('applies vertical spacing correctly',
        (WidgetTester tester) async {
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
                  (index) => Container(
                    width: 100,
                    height: 50,
                    color: Colors.blue,
                  ),
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

    testWidgets('uses direction-specific spacing when provided',
        (WidgetTester tester) async {
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
                  (index) => Container(
                    width: 100,
                    height: 50,
                    color: Colors.blue,
                  ),
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
  });

  group('SingleAxisWrap - Alignment', () {
    testWidgets('aligns horizontally with start alignment',
        (WidgetTester tester) async {
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
                  (index) => Container(
                    width: 100,
                    height: 50,
                    color: Colors.blue,
                  ),
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

    testWidgets('aligns horizontally with center alignment',
        (WidgetTester tester) async {
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
                  (index) => Container(
                    width: 100,
                    height: 50,
                    color: Colors.blue,
                  ),
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

    testWidgets('aligns horizontally with end alignment',
        (WidgetTester tester) async {
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
                  (index) => Container(
                    width: 100,
                    height: 50,
                    color: Colors.blue,
                  ),
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

    testWidgets('cross-axis alignment works in horizontal layout',
        (WidgetTester tester) async {
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
                  (index) => Container(
                    width: 100,
                    height: 50,
                    color: Colors.blue,
                  ),
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
    testWidgets('fires onLayoutDirectionChanged when layout changes',
        (WidgetTester tester) async {
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
                  (index) => Container(
                    width: 100,
                    height: 50,
                    color: Colors.blue,
                  ),
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
                  (index) => Container(
                    width: 100,
                    height: 50,
                    color: Colors.blue,
                  ),
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
                  (index) => Container(
                    width: 100,
                    height: 50,
                    color: Colors.blue,
                  ),
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
                  Container(
                    width: 100,
                    height: 50,
                    color: Colors.blue,
                  ),
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

    testWidgets('handles clipping when overflow occurs',
        (WidgetTester tester) async {
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
                  (index) => Container(
                    width: 100,
                    height: 50,
                    color: Colors.blue,
                  ),
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
}
