import 'package:flutter_test/flutter_test.dart';
import 'package:fixflow/main.dart';

void main() {
  testWidgets('renders the minimal FixFlow starter screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FixFlowApp());
    await tester.pumpAndSettle();

    expect(find.text('FixFlow'), findsOneWidget);
    expect(find.text('Project foundation is ready.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
