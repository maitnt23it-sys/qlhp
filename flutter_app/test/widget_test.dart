
import 'package:flutter_test/flutter_test.dart';
import 'package:qlhocphan_admin/main.dart';

void main() {
  testWidgets('MyApp builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(loggedIn: false));

    expect(find.byType(MyApp), findsOneWidget);
  });
}
