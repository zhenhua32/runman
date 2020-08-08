import 'package:flutter/material.dart';

import 'config/routes.dart';
import 'config/theme.dart';
import 'common/location.dart';

main() {
  WidgetsFlutterBinding.ensureInitialized();
  initBaiduMap();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RunMan',
      theme: theme,
      initialRoute: '/',
      routes: routes,
    );
  }
}
