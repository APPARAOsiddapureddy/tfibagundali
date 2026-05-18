import 'package:flutter_test/flutter_test.dart';
import 'package:tfi_bagundali/widgets/tfi_widgets.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Trust badge smoke test', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TrustBadge(status: 'verified')));
    expect(find.text('VERIFIED'), findsOneWidget);
  });
}
