import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foreverone/features/auth/presentation/pages/login_page.dart';

void main() {
  testWidgets('LoginPage affiche la marque, les champs et le bouton',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: LoginPage()),
          ),
        );

        expect(find.text('Forever One'), findsOneWidget);
        expect(find.text('Connexion'), findsOneWidget);
        expect(find.byType(TextField), findsNWidgets(2));
        expect(find.widgetWithText(FilledButton, 'Se connecter'), findsOneWidget);
      });

  testWidgets('LoginPage pré-remplit les identifiants de démonstration',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: LoginPage()),
          ),
        );

        expect(find.text('admin@demo.com'), findsOneWidget);
      });

  testWidgets('Le bouton oeil bascule la visibilité du mot de passe',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: LoginPage()),
          ),
        );

        expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

        await tester.tap(find.byIcon(Icons.visibility_outlined));
        await tester.pump();

        expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      });
}