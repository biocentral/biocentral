import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BiocentralTooltip Widget Tests', () {
    testWidgets('BiocentralTooltip displays child widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BiocentralTooltip(
            message: 'Test Message',
            child: Text('Child Widget'),
          ),
        ),
      );

      expect(find.text('Child Widget'), findsOneWidget);
    });

    testWidgets('BiocentralTooltip shows message on long press', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BiocentralTooltip(
            message: 'Test Message',
            child: Text('Child Widget'),
          ),
        ),
      );

      final gesture = await tester.startGesture(tester.getCenter(find.text('Child Widget')));
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 10));
      await gesture.up();
      await tester.pump();

      expect(find.text('Test Message'), findsOneWidget);
    });

    testWidgets('BiocentralTooltip uses default color when not specified', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BiocentralTooltip(
            message: 'Test Message',
            child: Text('Child Widget'),
          ),
        ),
      );

      await tester.longPress(find.text('Child Widget'));
      await tester.pumpAndSettle();

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect((tooltip.decoration as BoxDecoration).color, Colors.black);
    });

    testWidgets('BiocentralTooltip uses custom color when specified', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BiocentralTooltip(
            message: 'Test Message',
            child: Text('Child Widget'),
            color: Colors.blue,
          ),
        ),
      );

      await tester.longPress(find.text('Child Widget'));
      await tester.pumpAndSettle();

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect((tooltip.decoration as BoxDecoration).color, Colors.blue);
    });
  });
}
