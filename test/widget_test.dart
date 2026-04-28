import 'package:flutter_test/flutter_test.dart';
import 'package:loopz/main.dart';

void main() {
  testWidgets('App launches with login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const LoopzApp());
    expect(find.text('Loopz'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });
}
