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

            // Container with plenty of width (should be horizontal)
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
                  _buildBox(Colors.red, '1'),
                  _buildBox(Colors.green, '2'),
                  _buildBox(Colors.blue, '3'),
                  _buildBox(Colors.amber, '4'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBox(Color color, String text) {
    return Container(
      width: 100,
      height: 60,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
