import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_dash/main.dart';

void main() {
  testWidgets('Dashboard renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: InvestDashApp()));

    // Verify that our title is present.
    expect(find.text('투자 대시보드'), findsOneWidget);

    // Verify that we have an 'Add' icon
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
