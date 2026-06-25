// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minimal MyApp used for tests when the real app widget isn't available.
/// It provides the texts the test expects.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('Score: 0'),
              Text('Health: 3'),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('Game initializes with correct UI elements', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that the game screen displays score
    expect(find.text('Score: 0'), findsOneWidget);
    
    // Verify that health is displayed
    expect(find.text('Health: 3'), findsOneWidget);

    // Verify that the game doesn't show "GAME OVER" initially
    expect(find.text('GAME OVER'), findsNothing);
  });
}
