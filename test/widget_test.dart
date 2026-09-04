import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zener_regulator_lab/main.dart';

void main() {
  testWidgets('App starts and renders main workbench title', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ZenerRegulatorLabApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Zener Diode Voltage Regulator'), findsOneWidget);
  });
}
