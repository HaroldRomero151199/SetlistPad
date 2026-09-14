import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:setlist_pad/main.dart';

void main() {
  testWidgets('SetlistPadApp initialization smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SetlistPadApp(),
      ),
    );

    expect(find.text('SetlistPad'), findsWidgets);
    expect(find.text('SetlistPad Core Initialized'), findsOneWidget);
  });
}
