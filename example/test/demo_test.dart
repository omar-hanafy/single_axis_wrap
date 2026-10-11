import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'demo_flow.dart';

void main() {
  testWidgets(
    'controls survive axis changes and scroll on short screens',
    verifyDemoFlow,
  );

  testWidgets('a narrow initial window lays out without overflow', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(120, 300));
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expectAxis(tester, Axis.vertical);
    final box = tester.getRect(control('box-0'));
    expect(box.left, greaterThanOrEqualTo(0));
    expect(box.right, lessThanOrEqualTo(120));
  });
}
