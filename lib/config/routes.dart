import '../screens/isolate_demo.dart' as isolate_demo;
import '../screens/map_demo.dart' as map_demo;
import '../screens/show.dart' as show_page;
import '../screens/battery_demo.dart' as battery_demo;

var routes = {
  '/': (context) => show_page.ShowPage(),
  '/isolate_demo': (context) => isolate_demo.MyApp(),
  '/map_demo': (context) => map_demo.MyApp(),
  '/battery_demo': (context) => battery_demo.MyApp(),
};
