import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:foreverone/features/auth/domain/entities/user_entity.dart';
import 'package:foreverone/features/auth/domain/repositories/auth_repository.dart';
import 'package:foreverone/features/auth/domain/usecases/login_usecase.dart';
import 'package:foreverone/features/auth/presentation/providers/auth_provider.dart';
import 'package:foreverone/core/theme/app_colors.dart';
import 'package:foreverone/l10n/app_localizations.dart';
import 'package:foreverone/shared/widgets/app_drawer.dart';
import 'package:foreverone/shared/widgets/app_page_header.dart';
import 'package:foreverone/shared/widgets/app_shell.dart';

class _MockRepo extends Mock implements AuthRepository {}

/// A signed-in admin, without touching the network or secure storage.
class _SignedIn extends AuthNotifier {
  _SignedIn(AuthRepository repo) : super(LoginUsecase(repo), repo) {
    state = const AuthState(
      status: AuthStatus.authenticated,
      user: UserEntity(
        id: 'u1',
        email: 'admin@demo.com',
        fullName: 'Amira Admin',
        role: 'admin',
        tenantId: 't1',
        permissions: ['view_dashboard', 'view_products', 'manage_users'],
      ),
    );
  }
}

Future<void> _pumpShell(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final repo = _MockRepo();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith((ref) => _SignedIn(repo)),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: AppShell(
          location: '/products',
          child: Scaffold(
            appBar: const AppPageHeader(
              title: 'Products',
              icon: Icons.inventory_2_outlined,
              color: AppColors.stock,
            ),
            body: const SizedBox.expand(),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('phones get a menu button and a drawer, no sidebar',
      (tester) async {
    await _pumpShell(tester, 400);
    expect(find.byType(AppSidebar), findsNothing);
    expect(find.byTooltip('Open menu'), findsOneWidget);

    await tester.tap(find.byTooltip('Open menu'));
    await tester.pumpAndSettle();
    expect(find.byType(AppDrawer), findsOneWidget);
    // Only permitted items are listed.
    expect(find.text('Products'), findsWidgets);
    expect(find.text('Users'), findsOneWidget);
    expect(find.text('Audit log'), findsNothing);
  });

  testWidgets('from 840px the sidebar is permanent and the menu button goes',
      (tester) async {
    await _pumpShell(tester, 1000);
    expect(find.byType(AppSidebar), findsOneWidget);
    expect(find.byTooltip('Open menu'), findsNothing);
    expect(tester.getSize(find.byType(AppSidebar)).width, 248);
  });

  testWidgets('from 1200px the sidebar is a little wider', (tester) async {
    await _pumpShell(tester, 1300);
    expect(tester.getSize(find.byType(AppSidebar)).width, 264);
  });

  testWidgets('the sidebar collapses to a 72px rail and back', (tester) async {
    await _pumpShell(tester, 1000);
    await tester.tap(find.byTooltip('Collapse sidebar'));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(AppSidebar)).width, 72);

    await tester.tap(find.byTooltip('Expand sidebar'));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(AppSidebar)).width, 248);
  });
}
