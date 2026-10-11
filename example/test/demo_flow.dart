import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Finder control(String name) => find.byKey(ValueKey(name));

void expectAxis(WidgetTester tester, Axis axis) {
  final boxes = List.generate(
    4,
    (index) => tester.getRect(control('box-$index')),
  );
  for (var index = 1; index < boxes.length; index++) {
    if (axis == Axis.horizontal) {
      expect(boxes[index].top, closeTo(boxes[0].top, 0.01));
      expect(boxes[index].left, greaterThan(boxes[index - 1].right));
    } else {
      expect(boxes[index].left, closeTo(boxes[0].left, 0.01));
      expect(boxes[index].top, greaterThan(boxes[index - 1].bottom));
    }
  }
  expect(tester.takeException(), isNull);
}

Future<void> verifyDemoFlow(WidgetTester tester) async {
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(const Size(800, 600));
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
  expectAxis(tester, Axis.horizontal);
  expect(find.byType(Switch), findsNWidgets(2));
  expect(find.byIcon(Icons.add), findsNWidgets(2));

  await tester.tap(control('decrement-0'));
  await tester.pumpAndSettle();
  expect(tester.widget<Text>(control('counter-0')).data, '0');
  for (var count = 0; count < 3; count++) {
    await tester.tap(control('increment-0'));
    await tester.pumpAndSettle();
  }
  await tester.tap(control('increment-1'));
  await tester.pumpAndSettle();
  await tester.tap(control('switch-0'));
  await tester.pumpAndSettle();

  await tester.binding.setSurfaceSize(const Size(320, 700));
  await tester.pumpAndSettle();
  expectAxis(tester, Axis.vertical);
  expect(tester.widget<Text>(control('counter-0')).data, '3');
  expect(tester.widget<Text>(control('counter-1')).data, '1');
  expect(tester.widget<Switch>(control('switch-0')).value, isTrue);
  expect(tester.widget<Switch>(control('switch-1')).value, isFalse);

  await tester.binding.setSurfaceSize(const Size(280, 240));
  await tester.pumpAndSettle();
  expectAxis(tester, Axis.vertical);
  expect(control('switch-1').hitTestable(), findsNothing);
  await tester.drag(control('demo-scroll'), const Offset(0, -500));
  await tester.pumpAndSettle();
  expect(control('switch-1').hitTestable(), findsOneWidget);
  await tester.tap(control('switch-1'));
  await tester.pumpAndSettle();
  expect(tester.widget<Switch>(control('switch-1')).value, isTrue);

  await tester.binding.setSurfaceSize(const Size(800, 600));
  await tester.pumpAndSettle();
  expectAxis(tester, Axis.horizontal);
  expect(tester.widget<Text>(control('counter-0')).data, '3');
  expect(tester.widget<Text>(control('counter-1')).data, '1');
  expect(tester.widget<Switch>(control('switch-0')).value, isTrue);
  expect(tester.widget<Switch>(control('switch-1')).value, isTrue);
}
