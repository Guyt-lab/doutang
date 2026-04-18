import 'package:flutter_test/flutter_test.dart';

import 'package:doutang/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DoutangApp());
    expect(find.byType(DoutangApp), findsOneWidget);
  });
}
