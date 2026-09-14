import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foreverone/features/auth/presentation/pages/login_page.dart';
import 'package:foreverone/l10n/app_localizations.dart';

/// Wraps the page under test with the localization setup the real app provides.
Widget _wrap(Widget child, {Locale locale = const Locale('en')}) {
  return ProviderScope(
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

void main() {
  testWidgets('LoginPage shows the brand, fields and button in English',
          (WidgetTester tester) async {
        await tester.pumpWidget(_wrap(const LoginPage()));
        await tester.pumpAndSettle();

        expect(find.text('Forever One'), findsOneWidget);
        expect(find.text('Login'), findsOneWidget);
        expect(find.byType(TextField), findsNWidgets(2));
        expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
      });

  testWidgets('LoginPage shows French labels when locale is fr',
          (WidgetTester tester) async {
        await tester.pumpWidget(_wrap(const LoginPage(), locale: const Locale('fr')));
        await tester.pumpAndSettle();

        expect(find.text('Connexion'), findsOneWidget);
        expect(find.widgetWithText(FilledButton, 'Se connecter'), findsOneWidget);
      });

  testWidgets('LoginPage prefills the demo credentials',
          (WidgetTester tester) async {
        await tester.pumpWidget(_wrap(const LoginPage()));
        await tester.pumpAndSettle();

        expect(find.text('admin@demo.com'), findsOneWidget);
      });

  testWidgets('The eye button toggles password visibility',
          (WidgetTester tester) async {
        await tester.pumpWidget(_wrap(const LoginPage()));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

        await tester.tap(find.byIcon(Icons.visibility_outlined));
        await tester.pump();

        expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      });
}