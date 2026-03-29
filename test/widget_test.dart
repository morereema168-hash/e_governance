// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e_governance/main.dart';

void main() {
  testWidgets('JanaSetu app loads login screen', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const JanasetuApp());
    await tester.pumpAndSettle();

    // Verify the login screen is shown with correct branding.
    expect(find.text('JanaSetu'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);

    // Verify login fields are present.
    expect(find.byType(TextField), findsNWidgets(2));

    // Verify Sign In button is present.
    expect(find.text('Sign In'), findsOneWidget);
  });
}