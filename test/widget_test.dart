// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:csen268/main.dart';
import 'package:csen268/model/user.dart';
import 'package:csen268/widgets/user_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  Widget createUserList() {
    return ListView(
      children: List.generate(20, (index) {
        return UserListTile(
          user: User(
            firstName: "First$index",
            lastName: "Last$index",
            imageUrl: "https://placehold.co/400x400",
            email: "first$index@last$index.com",
            uid: "$index",
          ),
        );
      }),
    );
  }

  group('Testing MyApp', () {
    testWidgets('ListView', (tester) async {
      await tester.pumpWidget(createWidget(createUserList()));
      await tester.pumpAndSettle();
      expect(find.byType(ListView), findsOne);
      expect(find.text("First0 Last0"), findsOne);
      await tester.fling(find.byType(ListView), Offset(0, -200), 400);
      await tester.pumpAndSettle();
      expect(find.text("First0 Last0"), findsNothing);
      await tester.fling(find.byType(ListView), Offset(0, 200), 400);
      await tester.pumpAndSettle();
      expect(find.text("First0 Last0"), findsOne);
      await tester.tap(find.byType(UserListTile).first);
      await tester.pumpAndSettle();
      expect(find.text('First0 Last0 added.'), findsOne);
    });
  });
}
