import 'package:cyberuday/core/cyber_design_system.dart';
import 'package:cyberuday/screens/home/pages/threat_scanner_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('threat scanner exposes APK and general file upload actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: CyberTheme.lightTheme,
        home: const Scaffold(body: ThreatScannerPage()),
      ),
    );

    expect(find.text('Choose content from this device'), findsOneWidget);
    expect(find.text('Upload APK'), findsOneWidget);
    expect(find.text('Upload file'), findsOneWidget);
  });
}
