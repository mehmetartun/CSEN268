import 'package:csen268/pages/list_view_page.dart';
import 'package:csen268/pages/page_with_double_scrollview.dart';
import 'package:csen268/theme/theme_util.dart';
import 'package:flutter/material.dart';

import 'pages/column_page.dart';
import 'pages/my_home_page.dart';
import 'theme/theme.dart';
import 'widgets/counter_widget.dart';
import 'widgets/labeled_text_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    MaterialTheme materialTheme = MaterialTheme(
      createTextTheme(context, 'Roboto', 'Playfair Display'),
    );

    return MaterialApp(
      title: 'Flutter Demo',
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      // ),
      theme: materialTheme.light(),

      // home: const MyHomePage(title: 'CSEN268 Demo Home Page'),
      home: const ListViewPage(),
    );
  }
}
