import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tfi_bagundali/widgets/tfi_widgets.dart';

void main() {
  testWidgets('TrustBadge shows Official for official status', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: TrustBadge(status: 'official'))));
    expect(find.text('OFFICIAL'), findsOneWidget);
  });

  testWidgets('TrustBadge shows Buzz for unknown status', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: TrustBadge(status: 'buzz'))));
    expect(find.text('BUZZ'), findsOneWidget);
  });
}
