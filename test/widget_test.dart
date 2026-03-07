import 'package:flutter_test/flutter_test.dart';

import 'package:pacman_game/main.dart';

void main() {
  testWidgets('Smoke test: la app se carga sin errores', (WidgetTester tester) async {
    await tester.pumpWidget(const PacmanApp());

    // Verify the menu screen loads with key elements
    expect(find.text('PAC-MAN'), findsOneWidget);
    expect(find.text('TOCA PARA JUGAR'), findsOneWidget);
    expect(find.text('DESLIZA PARA MOVER'), findsOneWidget);
  });
}