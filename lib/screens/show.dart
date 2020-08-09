import 'package:flutter/material.dart';

class ShowPage extends StatelessWidget {
  const ShowPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('展示'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RaisedButton(
              onPressed: () => Navigator.pushNamed(context, '/isolate_demo'),
              child: Text('定位'),
            ),
            RaisedButton(
              onPressed: () => Navigator.pushNamed(context, '/map_demo'),
              child: Text('地图'),
            ),
            RaisedButton(
              onPressed: () => Navigator.pushNamed(context, '/battery_demo'),
              child: Text('电池'),
            )
          ],
        ),
      ),
    );
  }
}
