import 'package:flutter_test/flutter_test.dart';

import 'package:chatbot/main.dart';

void main() {
  testWidgets('app loads splash screen with chatbot title', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Chatbot'), findsOneWidget);
  });
}
