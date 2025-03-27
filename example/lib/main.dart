import 'dart:math';

import 'package:flutter/material.dart';
import 'package:single_axis_wrap/single_axis_wrap.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SingleAxisWrap Debug',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
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
  Axis direction = Axis.horizontal;
  List<int> counters = [0, 0, 0, 0]; // Counters for each box
  List<bool> switchValues = [false, false, false, false]; // Switch values

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('SingleAxisWrap Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Direction is ${direction.name.toUpperCase()}',
              style: theme.textTheme.headlineLarge,
            ),
            const SizedBox(height: 40),
            const Text(
              'Resize to make it switch to Vertical View Automatic',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Container(
              width: 500,
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade200,
              child: SingleAxisWrap(
                verticalCrossAxisAlignment: WrapCrossAlignment.center,
                horizontalAlignment: WrapAlignment.center,
                onLayoutDirectionChanged: (Axis direction) {
                  setState(() {
                    this.direction = direction;
                  });
                },
                spacing: 8,
                children: [
                  _buildBox(Colors.red, '1', 0),
                  _buildBox(Colors.green, '2', 1),
                  _buildBox(Colors.blue, '3', 2),
                  _buildBox(Colors.amber, '4', 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBox(Color color, String text, int index) {
    final random = Random();
    final showSwitch = random.nextBool();

    return Container(
      width: 100,
      height: 60,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child:
            showSwitch
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Switch(
                      value: switchValues[index],
                      onChanged: (value) {
                        setState(() {
                          switchValues[index] = value;
                        });
                      },
                      activeColor:
                          Colors.white, // Set the active color to white.
                      thumbColor: WidgetStateProperty.resolveWith<Color>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return Colors
                              .white; // Set thumb color to white when active
                        }
                        return Colors
                            .grey; // Use the default color for other states
                      }),
                    ),
                  ],
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          counters[index] = max(0, counters[index] - 1);
                        });
                      },
                      constraints: const BoxConstraints(),
                      // Remove extra padding
                      padding: EdgeInsets.zero,
                      splashRadius: 20, // Reduce splash radius if needed.
                    ),
                    Text(
                      '${counters[index]}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          counters[index]++;
                        });
                      },
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      splashRadius: 20,
                    ),
                  ],
                ),
      ),
    );
  }
}
