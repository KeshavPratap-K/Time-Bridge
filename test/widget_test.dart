import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dual_clock_app/main.dart';
import 'package:dual_clock_app/screens/dual_clock_screen.dart';
import 'package:dual_clock_app/screens/splash_screen.dart';
import 'package:dual_clock_app/widgets/app_logo.dart';
import 'package:dual_clock_app/widgets/clock_display_card.dart';
import 'package:dual_clock_app/widgets/format_toggle.dart';
import 'package:dual_clock_app/widgets/timezone_picker_sheet.dart';

void main() {
  testWidgets('SplashScreen displays logo, title, and transitions',
      (WidgetTester tester) async {
    await tester.pumpWidget(const DualClockApp(home: SplashScreen()));

    // Logo and title should be visible on splash screen
    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.text('Time Bridge'), findsOneWidget);
    expect(find.text('Real-time Global Time Synchronization'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Let animation and splash timer complete
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 1000));
  });

  testWidgets('DualClockScreen renders properly with all key components and help icon',
      (WidgetTester tester) async {
    await tester.pumpWidget(const DualClockApp(home: DualClockScreen()));
    await tester.pumpAndSettle();

    // 1. App bar title with AppLogo
    expect(find.text('Time Bridge'), findsOneWidget);
    expect(find.byType(AppLogo), findsOneWidget);

    // 2. Question mark icon button is present (and theme switcher is removed)
    expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);
    expect(find.byType(PopupMenuButton<ThemeMode>), findsNothing);

    // 3. Format toggle (12h and 24h)
    expect(find.byType(FormatToggle), findsOneWidget);
    expect(find.text('12h'), findsOneWidget);
    expect(find.text('24h'), findsOneWidget);

    // 4. Two clock cards of equal presence (top and bottom)
    expect(find.byType(ClockDisplayCard), findsNWidgets(2));

    // 5. Middle divider exists
    expect(find.byType(Divider), findsAtLeastNWidgets(2));

    // 6. System clock card has "SYSTEM LOCAL TIME"
    expect(find.text('SYSTEM LOCAL TIME'), findsOneWidget);

    // 7. Reset button is NOT displayed initially
    expect(find.text('Reset to System Time'), findsNothing);

    // 8. Toggle 24h format
    await tester.tap(find.text('24h'));
    await tester.pumpAndSettle();

    // In 24h mode, AM/PM should not be visible
    expect(find.text('AM'), findsNothing);
    expect(find.text('PM'), findsNothing);

    // Toggle back to 12h format
    await tester.tap(find.text('12h'));
    await tester.pumpAndSettle();
  });

  testWidgets('Clicking question mark icon opens "How Time Bridge Works" modal',
      (WidgetTester tester) async {
    await tester.pumpWidget(const DualClockApp(home: DualClockScreen()));
    await tester.pumpAndSettle();

    // Tap the question mark help icon button
    await tester.tap(find.byIcon(Icons.help_outline_rounded));
    await tester.pumpAndSettle();

    // Verify modal sheet is displayed with guide content
    expect(find.text('How Time Bridge Works'), findsOneWidget);
    expect(find.text('System Time (Top Clock)'), findsOneWidget);
    expect(find.text('12h / 24h Format Toggle'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);

    // Dismiss modal via close icon button
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // Modal sheet should now be closed
    expect(find.text('How Time Bridge Works'), findsNothing);
  });

  testWidgets('Clicking bottom clock opens Timezone modal sheet',
      (WidgetTester tester) async {
    await tester.pumpWidget(const DualClockApp(home: DualClockScreen()));
    await tester.pumpAndSettle();

    // Find the bottom ClockDisplayCard (the second one)
    final cards = find.byType(ClockDisplayCard);
    expect(cards, findsNWidgets(2));

    // Tap the bottom clock card
    await tester.tap(cards.last);
    await tester.pumpAndSettle();

    // Modal sheet should now be open
    expect(find.text('Select Timezone'), findsOneWidget);
    expect(find.byType(SearchBar), findsOneWidget);

    // Select a timezone from the sheet
    final tokyoFinder = find.descendant(
      of: find.byType(TimezonePickerSheet),
      matching: find.text('Tokyo'),
    );
    if (tokyoFinder.evaluate().isNotEmpty) {
      await tester.tap(tokyoFinder.first);
      await tester.pumpAndSettle();

      // Modal closed and bottom card updated
      expect(find.text('Select Timezone'), findsNothing);
      expect(find.text('TOKYO'), findsOneWidget);
    }
  });

  testWidgets('Top clock opens Material TimePicker and shows Reset button when set',
      (WidgetTester tester) async {
    await tester.pumpWidget(const DualClockApp(home: DualClockScreen()));
    await tester.pumpAndSettle();

    final cards = find.byType(ClockDisplayCard);
    expect(cards, findsNWidgets(2));

    // Tap the top clock card
    await tester.tap(cards.first);
    await tester.pumpAndSettle();

    // Material TimePicker should be visible
    expect(find.text('SET TIME'), findsOneWidget);

    // Tap "SET TIME" to confirm time selection
    await tester.tap(find.text('SET TIME'));
    await tester.pumpAndSettle();

    // Now it should be in custom time mode and "Reset to System Time" button appears
    expect(find.text('Reset to System Time'), findsOneWidget);
    expect(find.text('CUSTOM SYSTEM TIME'), findsOneWidget);

    // Tap "Reset to System Time"
    await tester.tap(find.text('Reset to System Time'));
    await tester.pumpAndSettle();

    // Reset button should disappear and revert to system time
    expect(find.text('Reset to System Time'), findsNothing);
    expect(find.text('SYSTEM LOCAL TIME'), findsOneWidget);
  });

  testWidgets('No RenderFlex overflow on narrow screens when custom time is set',
      (WidgetTester tester) async {
    // Set a compact screen size (e.g. 320px width)
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    FlutterErrorDetails? errorDetails;
    final oldHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      errorDetails = details;
    };

    try {
      await tester.pumpWidget(const DualClockApp(home: DualClockScreen()));
      await tester.pumpAndSettle();

      // Trigger custom time
      await tester.tap(find.byType(ClockDisplayCard).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('SET TIME'));
      await tester.pumpAndSettle();
    } finally {
      FlutterError.onError = oldHandler;
    }

    expect(errorDetails, isNull);
  });

  testWidgets('App follows system theme configuration by default',
      (WidgetTester tester) async {
    await tester.pumpWidget(const DualClockApp(home: DualClockScreen()));
    await tester.pumpAndSettle();

    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.themeMode, equals(ThemeMode.system));
  });

  testWidgets('Displays last 5 recent timezones and allows quick switching',
      (WidgetTester tester) async {
    await tester.pumpWidget(const DualClockApp(home: DualClockScreen()));
    await tester.pumpAndSettle();

    // Verify "Recent Timezones" header is visible
    expect(find.text('Recent Timezones'), findsOneWidget);
    expect(find.text('Tap to switch'), findsOneWidget);

    // Verify the old tip card text is gone
    expect(find.textContaining('Tap the top clock to test custom times'), findsNothing);

    // Tap a recent timezone in the list (e.g. Tokyo)
    final tokyoFinder = find.text('Tokyo');
    if (tokyoFinder.evaluate().isNotEmpty) {
      await tester.ensureVisible(tokyoFinder.first);
      await tester.pumpAndSettle();
      await tester.tap(tokyoFinder.first);
      await tester.pumpAndSettle();

      // Bottom clock should update to Tokyo
      expect(find.text('TOKYO'), findsOneWidget);
    }
  });

  testWidgets('Renders 2-column layout on desktop/tablet and 1-column on mobile',
      (WidgetTester tester) async {
    // 1. Desktop/Tablet view (1024x768)
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const DualClockApp(home: DualClockScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(ClockDisplayCard), findsNWidgets(2));
    final desktopRecentCard = find.widgetWithText(Card, 'Recent Timezones');
    expect(desktopRecentCard, findsOneWidget);

    // On desktop, the recent card is in the right column and sits near the top
    final desktopRecentTop = tester.getTopLeft(desktopRecentCard).dy;
    expect(desktopRecentTop, lessThan(200));

    // 2. Mobile view (400x900)
    tester.view.physicalSize = const Size(400, 900);
    await tester.pumpWidget(const DualClockApp(home: DualClockScreen()));
    await tester.pumpAndSettle();

    // In mobile single-column mode, recent card is placed below the bottom clock card
    final bottomClockFinder = find.byType(ClockDisplayCard).last;
    final bottomClockBottom = tester.getBottomLeft(bottomClockFinder).dy;
    final mobileRecentTop = tester.getTopLeft(find.widgetWithText(Card, 'Recent Timezones')).dy;
    expect(mobileRecentTop, greaterThan(bottomClockBottom));
  });

  testWidgets('Searches timezones with abbreviations like IST and EST',
      (WidgetTester tester) async {
    await tester.pumpWidget(const DualClockApp(home: DualClockScreen()));
    await tester.pumpAndSettle();

    // Open timezone picker by tapping bottom clock card
    await tester.tap(find.byType(ClockDisplayCard).last);
    await tester.pumpAndSettle();

    final searchBar = find.byType(SearchBar);
    expect(searchBar, findsOneWidget);

    // 1. Search for "IST"
    await tester.enterText(searchBar, 'IST');
    await tester.pumpAndSettle();

    // Kolkata should be visible and have IST badge inside the picker sheet
    expect(
      find.descendant(
        of: find.byType(TimezonePickerSheet),
        matching: find.text('Kolkata'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(TimezonePickerSheet),
        matching: find.text('IST'),
      ),
      findsWidgets,
    );

    // 2. Search for "EST"
    await tester.enterText(searchBar, 'EST');
    await tester.pumpAndSettle();

    // New York should be visible inside the picker sheet
    expect(
      find.descendant(
        of: find.byType(TimezonePickerSheet),
        matching: find.text('New York'),
      ),
      findsOneWidget,
    );

    // Tap New York to select it
    final newYorkFinder = find.descendant(
      of: find.byType(TimezonePickerSheet),
      matching: find.text('New York'),
    );
    await tester.tap(newYorkFinder.first);
    await tester.pumpAndSettle();

    // Bottom clock should now display NEW YORK
    expect(find.text('NEW YORK'), findsOneWidget);
  });
}
