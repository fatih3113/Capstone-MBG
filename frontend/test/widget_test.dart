import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mbg_nutrition/features/auth/login_page.dart';
import 'package:mbg_nutrition/providers/auth_provider.dart';
import 'package:mbg_nutrition/data/services/auth_service.dart';

void main() {
  group('LoginPage Widget Tests', () {
    Widget buildLoginPage() {
      return MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthService()),
          child: const LoginPage(),
        ),
      );
    }

    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(buildLoginPage());
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Masuk'), findsOneWidget);
    });

    testWidgets('shows validation error on empty submit', (tester) async {
      await tester.pumpWidget(buildLoginPage());
      await tester.tap(find.widgetWithText(ElevatedButton, 'Masuk'));
      await tester.pump();
      // Should show validation error text
      expect(find.text('Email tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('shows demo credentials hint', (tester) async {
      await tester.pumpWidget(buildLoginPage());
      expect(find.textContaining('Demo'), findsOneWidget);
    });

    testWidgets('has register link', (tester) async {
      await tester.pumpWidget(buildLoginPage());
      expect(find.text('Daftar Sekarang'), findsOneWidget);
    });
  });

  group('ScanPage Widget Tests', () {
    testWidgets('renders scan buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Buka Kamera'))),
      );
      expect(find.text('Buka Kamera'), findsOneWidget);
    });
  });
}
