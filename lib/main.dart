import 'package:flutter/material.dart';

import 'config/routes.dart';
import 'config/theme.dart';

main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RunMan',
      theme: theme,
      initialRoute: '/isolate_demo',
      routes: routes,
    );
  }
}
