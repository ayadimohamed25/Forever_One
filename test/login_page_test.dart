import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foreverone/features/auth/presentation/pages/login_page.dart';

void main() {
  testWidgets('LoginPage affiche les champs email, mot de passe et le bouton',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: LoginPage()),
          ),
        );

        expect(find.text('Forever One — Login'), findsOneWidget);
        expect(find.byType(TextField), findsNWidgets(2));
        expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
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
}