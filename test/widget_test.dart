import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daily_news/main.dart';

void main() {
  testWidgets('Daily News app loads and shows title', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(DailyNewsApp());

    // Verify the app title is shown
    expect(find.text('Daily News'), findsOneWidget);

    // Check that category buttons or search bar are visible
    expect(find.byIcon(Icons.search), findsOneWidget);

    // Simulate a refresh button tap
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();

    // Verify that a loading indicator appears
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
