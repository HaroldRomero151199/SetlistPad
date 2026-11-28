import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setlist_pad/core/theme/app_theme.dart';
import 'package:setlist_pad/features/playlists/playlists.dart';
import 'package:setlist_pad/l10n/app_localizations.dart';

void main() {
  Widget buildApp({
    required Locale locale,
    required void Function(bool result) onResult,
    String? customConfirmLabel,
    String? customCancelLabel,
  }) {
    return MaterialApp(
      locale: locale,
      theme: AppTheme.darkTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                final confirmed = await ConfirmDeleteDialog.show(
                  context: context,
                  title: 'Confirm Title',
                  message: 'Confirm Message',
                  confirmLabel: customConfirmLabel,
                  cancelLabel: customCancelLabel,
                );
                onResult(confirmed);
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );
  }

  group('ConfirmDeleteDialog Widget Tests', () {
    testWidgets('displays localized Spanish labels and destructive styling', (
      tester,
    ) async {
      bool? dialogResult;
      await tester.pumpWidget(
        buildApp(
          locale: const Locale('es'),
          onResult: (result) => dialogResult = result,
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Confirm Title'), findsOneWidget);
      expect(find.text('Confirm Message'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Eliminar'), findsOneWidget);

      final confirmButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Eliminar'),
      );
      expect(
        confirmButton.style?.backgroundColor?.resolve({}),
        AppTheme.errorColor,
      );

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(dialogResult, isFalse);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('returns true when confirm action is tapped in English locale', (
      tester,
    ) async {
      bool? dialogResult;
      await tester.pumpWidget(
        buildApp(
          locale: const Locale('en'),
          onResult: (result) => dialogResult = result,
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(dialogResult, isTrue);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('returns false when dismissed by tapping barrier', (
      tester,
    ) async {
      bool? dialogResult;
      await tester.pumpWidget(
        buildApp(
          locale: const Locale('es'),
          onResult: (result) => dialogResult = result,
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Tap outside the dialog barrier
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(dialogResult, isFalse);
    });
  });
}
