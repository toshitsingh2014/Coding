import 'package:flutter_test/flutter_test.dart';

import 'package:student_app/main.dart';

void main() {
  testWidgets('shows login screen on startup', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('Student App'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
  });
}
