import 'package:flutter_test/flutter_test.dart';
import 'package:student_app/main.dart';

void main() {
  testWidgets('shows login screen on startup', (WidgetTester tester) async {
    await tester.pumpWidget(const StudentApp());
    await tester.pumpAndSettle();

    expect(find.text('Student Hub'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('Create a new account'), findsOneWidget);
  });
}
