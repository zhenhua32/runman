import '../screens/isolate_demo.dart' as isolate_demo;
import '../screens/map_demo.dart' as map_demo;
import '../screens/show.dart' as show_page;

var routes = {
  '/': (context) => show_page.ShowPage(),
  '/isolate_demo': (context) => isolate_demo.MyApp(),
  '/map_demo': (context) => map_demo.MyApp(),
};
