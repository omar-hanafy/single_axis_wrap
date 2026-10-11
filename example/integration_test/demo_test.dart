import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:single_axis_wrap/single_axis_wrap.dart';

import '../test/demo_flow.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'running demo preserves controls across resizes and scrolling',
    verifyDemoFlow,
  );

  testWidgets('a maintained column reports its size after layout and resize', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(150, 300));
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: IntrinsicWidth(
            child: SingleAxisWrap(
              maintainLayout: true,
              spacing: 10,
              children: [
                SizedBox(width: 100, height: 50),
                SizedBox(width: 100, height: 50),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final wrap = find.byType(SingleAxisWrap);
    final render = tester.renderObject<RenderBox>(wrap);
    expect(tester.getSize(wrap), const Size(100, 110));
    expect(render.getMaxIntrinsicWidth(double.infinity), 100);
    expect(
      render.getDryLayout(const BoxConstraints(maxWidth: 400)),
      const Size(100, 110),
    );

    await tester.binding.setSurfaceSize(const Size(400, 300));
    await tester.pumpAndSettle();
    expect(tester.renderObject<RenderBox>(wrap), same(render));
    expect(tester.getSize(wrap), const Size(100, 110));
    expect(render.getMaxIntrinsicWidth(double.infinity), 100);
    expect(tester.takeException(), isNull);
  });
}
