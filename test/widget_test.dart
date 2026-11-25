import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_stockage_local/main.dart';

void main() {
  testWidgets('ajoute une tâche à la liste', (tester) async {
    // Simule une mémoire locale vide pour le test
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Aucune tâche pour le moment'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Réviser Flutter');
    await tester.tap(find.text('Ajouter'));
    await tester.pumpAndSettle();

    expect(find.text('Réviser Flutter'), findsOneWidget);
  });
}