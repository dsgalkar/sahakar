import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sahakar/core/theme/app_theme.dart';
import 'package:sahakar/presentation/shell/app_shell.dart';
import 'package:sahakar/presentation/auth/login_screen.dart';

void main() {
  testWidgets('Sahakar login screen renders 3 role tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Verify brand header
    expect(find.text('SAHAKAR'), findsOneWidget);

    // Verify 3 tabs requested by user
    expect(find.text('User'), findsOneWidget);
    expect(find.text('Gig Worker'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
  });

  testWidgets('Sahakar app shell renders with cooperative branding', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const AppShell(),
        ),
      ),
    );

    // Verify brand title and services section
    expect(find.text('SAHAKAR'), findsOneWidget);
    expect(find.text('Available Cooperative Gigs (6)'), findsOneWidget);
  });
}
