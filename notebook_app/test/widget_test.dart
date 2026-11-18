import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notebook_app/main.dart';
import 'package:notebook_app/theme.dart';
import 'package:notebook_app/screens/splash_screen.dart';
import 'package:notebook_app/widgets/journal_security.dart';
import 'package:notebook_app/widgets/companion_system.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App launches with splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const Essays1743NotebookApp());
    await tester.pump();
    expect(find.byType(SplashScreen), findsOneWidget);
  });

  testWidgets('Main navigation shell renders all tabs correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.getThemeData(AppThemeMode.light),
        home: const MainNavigationShell(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Agenda'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));
  });

  test('JournalSecurityService roundtrip encryption, authentication, and lock/unlock', () async {
    final sec = JournalSecurityService.instance;
    await sec.setPassword('SuperSecret123!');

    expect(sec.isLockEnabled, isTrue);
    expect(sec.isUnlocked, isTrue);

    const plaintext = 'My personal confidential thoughts for 1734 Notebook.';
    final ciphertext = sec.encryptString(plaintext);
    expect(ciphertext, isNotNull);
    expect(ciphertext!.startsWith('ENC:v1:'), isTrue);

    // Decrypt with active unlocked session
    final decrypted = sec.decryptString(ciphertext);
    expect(decrypted, equals(plaintext));

    // Tampered ciphertext fails authentication
    final tampered = ciphertext.replaceRange(ciphertext.length - 4, ciphertext.length, 'ffff');
    expect(sec.decryptString(tampered), isNull);

    // Plaintext strings return as-is
    expect(sec.decryptString('Regular note'), equals('Regular note'));

    // Lock and unlock verification
    sec.lock();
    expect(sec.isUnlocked, isFalse);
    expect(sec.decryptString(ciphertext), isNull);

    final unlockWrong = await sec.unlock('WrongPassword');
    expect(unlockWrong, isFalse);
    expect(sec.isUnlocked, isFalse);

    final unlockRight = await sec.unlock('SuperSecret123!');
    expect(unlockRight, isTrue);
    expect(sec.isUnlocked, isTrue);
    expect(sec.decryptString(ciphertext), equals(plaintext));

    // Disable lock
    final disabled = await sec.disableLock('SuperSecret123!');
    expect(disabled, isTrue);
    expect(sec.isLockEnabled, isFalse);
  });

  test('CompanionManager switching and persistence', () async {
    final companion = CompanionManager.instance;

    await companion.setCompanion(CompanionType.deer);
    expect(companion.selected, equals(CompanionType.deer));
    expect(companion.isDeer, isTrue);
    expect(companion.isRabbit, isFalse);

    await companion.setCompanion(CompanionType.rabbit);
    expect(companion.selected, equals(CompanionType.rabbit));
    expect(companion.isRabbit, isTrue);
    expect(companion.isDeer, isFalse);
  });
}
