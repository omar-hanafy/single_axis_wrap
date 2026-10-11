import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:single_axis_wrap/single_axis_wrap.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SingleAxisWrap Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const DebugScreen(),
    );
  }
}

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  static const _boxWidth = 120.0;
  static const _boxHeight = 64.0;
  final _counters = [0, 0];
  final _switchValues = [false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SingleAxisWrap Demo')),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          key: const ValueKey('demo-scroll'),
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: math.max(0, constraints.maxHeight - 32),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'One row. One column.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Resize the window: when the row no longer fits, '
                    'all four controls move into a column.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 600,
                    padding: const EdgeInsets.all(16),
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final boxWidth = math.min(
                          _boxWidth,
                          constraints.maxWidth,
                        );
                        return SingleAxisWrap(
                          verticalCrossAxisAlignment: WrapCrossAlignment.center,
                          horizontalAlignment: WrapAlignment.center,
                          spacing: 8,
                          children: [
                            _buildBox(0, Colors.red.shade700, boxWidth),
                            _buildBox(1, Colors.green.shade700, boxWidth),
                            _buildBox(2, Colors.blue.shade700, boxWidth),
                            _buildBox(3, Colors.purple.shade700, boxWidth),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBox(int index, Color color, double width) {
    final controlIndex = index ~/ 2;
    return Container(
      key: ValueKey('box-$index'),
      width: width,
      height: _boxHeight,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: _boxWidth,
          height: _boxHeight,
          child: index.isEven
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      key: ValueKey('decrement-$controlIndex'),
                      tooltip: 'Decrease counter ${controlIndex + 1}',
                      icon: const Icon(Icons.remove, color: Colors.white),
                      onPressed: () => setState(() {
                        _counters[controlIndex] = math.max(
                          0,
                          _counters[controlIndex] - 1,
                        );
                      }),
                    ),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${_counters[controlIndex]}',
                          key: ValueKey('counter-$controlIndex'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      key: ValueKey('increment-$controlIndex'),
                      tooltip: 'Increase counter ${controlIndex + 1}',
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () => setState(() {
                        _counters[controlIndex]++;
                      }),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Switch(
                      key: ValueKey('switch-$controlIndex'),
                      value: _switchValues[controlIndex],
                      onChanged: (value) => setState(() {
                        _switchValues[controlIndex] = value;
                      }),
                      activeThumbColor: Colors.white,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
