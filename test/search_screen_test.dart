import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tuukatuu/presentation/screens/search_screen.dart';
import 'package:tuukatuu/state/providers/search_provider.dart';

void main() {
  group('SearchScreen Tests', () {
    testWidgets('Search screen shows search bar and recent searches', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => SearchProvider(),
            child: const SearchScreen(),
          ),
        ),
      );

      // Verify search bar is present
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search for groceries, snacks, beverages...'), findsOneWidget);

      // Verify filter button is present
      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
    });

    testWidgets('Search functionality works with text input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => SearchProvider(),
            child: const SearchScreen(),
          ),
        ),
      );

      // Enter search text
      await tester.enterText(find.byType(TextField), 'milk');
      await tester.pump();

      // Verify text is entered
      expect(find.text('milk'), findsOneWidget);
    });

    testWidgets('Clear button appears when text is entered', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => SearchProvider(),
            child: const SearchScreen(),
          ),
        ),
      );

      // Enter search text
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      // Verify clear button appears
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });
  });
} 