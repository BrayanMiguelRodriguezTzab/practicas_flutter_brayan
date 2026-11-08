import 'package:flutter_test/flutter_test.dart';
import 'package:practicas_flutter_brayan/main.dart';

void main() {
  testWidgets('Prueba de humo para renderizado del evaluativo de Práctica 08',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MiAppEvaluativo());
    expect(find.text('Puntos de Interés & GPS'), findsOneWidget);
  });
}