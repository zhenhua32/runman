import 'dart:async';

import 'package:bdmap_location_flutter_plugin/bdmap_location_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:isolate_handler/isolate_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/location.dart';
import '../common/toast.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initBaiduMap();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // 创建一个 IsolateHandler, 用于派生 isolate
  final isolates = IsolateHandler();
  LocationFlutterPlugin _locationPlugin = new LocationFlutterPlugin();

  // 保存消息
  List<String> messages = [];
  Timer timer;
  String seconds = '5';

  @override
  void initState() {
    super.initState();
    // 用来在一打开的时候就申请权限, 不申请感觉不太行
    _locationPlugin.requestPermission();

    // Start the isolate at the `entryPoint` function. We will be dealing with
    // string types here, so we will restrict communication to that type. If no type
    // is given, the type will be dynamic instead.
    isolates.spawn<String>(entryPoint,
        // Here we give a name to the isolate, by which we can access is later,
        // for example when sending it data and when disposing of it.
        name: 'path',
        // onReceive is executed every time data is received from the spawned
        // isolate. We will let the saveMessage function deal with any incoming
        // data.
        onReceive: saveMessage,
        // Executed once when spawned isolate is ready for communication. We will
        // send the isolate a request to perform its task right away.
        onInitialized: () => isolates.send('hello', to: 'path'));

    _loadMessages();
    _loadSeconds();
  }

  @override
  void dispose() {
    _saveMessages();
    _saveSeconds();
    super.dispose();
  }

  saveMessage(String msg) {
    // 收到消息时的回调函数
    setState(() {
      if (messages.length == 0 || messages[messages.length - 1] != msg) {
        messages.add(msg);
      }
    });

    print('time: ${DateTime.now()}');

    // We will no longer be needing the isolate, let's dispose of it.
    // isolates.kill('path');
  }

  sendMessage() {
    // 通过建立一个重复的计时器, 每次按特定的时间间隔发送消息
    print('start timer');
    if (null == timer || !timer.isActive) {
      var oneSec = Duration(seconds: int.parse(seconds));
      timer = new Timer.periodic(oneSec, (Timer t) => isolates.send('hello', to: 'path'));
    } else {
      print('already start');
    }
  }

  stopMesssage() {
    print('cancel timer');
    if (null != timer) {
      timer.cancel();
    }
  }

  clearMesssage() {
    setState(() {
      messages = [];
    });
  }

  _loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      messages = (prefs.getStringList('messages') ?? []);
    });
  }

  _saveMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('messages', messages);
  }

  _loadSeconds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      seconds = (prefs.getString('seconds') ?? '5');
    });
  }

  _saveSeconds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('seconds', seconds);
  }

  Widget _buildRow(var position) {
    return Container(
      child: Text(position.toString()),
    );
  }

  Container _createPositionListView() {
    return Container(
      child: Expanded(
        child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, i) {
            if (i >= messages.length) {
              return null;
            }
            return _buildRow(messages[i]);
          },
        ),
      ),
    );
  }

  Container _createInputView() {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: '输入间隔时间',
        ),
        controller: TextEditingController(text: seconds),
        onSubmitted: (text) {
          setState(() {
            seconds = text;
            _saveSeconds();
          });
        },
      ),
    );
  }

  Container _createButtonView() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          RaisedButton(
            onPressed: sendMessage,
            child: new Text('启动'),
          ),
          RaisedButton(
            onPressed: stopMesssage,
            child: new Text('停止'),
          ),
          RaisedButton(
            onPressed: clearMesssage,
            child: new Text('清空'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('定位'),
      ),
      body: Center(
          child: Column(
        children: <Widget>[
          Text('当前设定为每 $seconds 秒获取一次位置'),
          _createPositionListView(),
          _createButtonView(),
          _createInputView(),
        ],
      )),
    );
  }
}

// 我需要一个返回回调函数的函数, 把消息传递者放进去, 就可以把消息传回来
LocationCallback hiCallback(HandledIsolateMessenger<dynamic> messenger) {
  return (Map<String, Object> result) {
    print(result);
    var position = 'null';
    if (result != null) {
      position = '${DateTime.now()}: 经度: ${result["longitude"]}, 纬度: ${result["latitude"]}';
      sendToast(position);
    }
    print(position);
    messenger.send(position);
  };
}

// This function happens in the isolate.
void entryPoint(Map<String, dynamic> context) {
  // Calling initialize from the entry point with the context is
  // required if communication is desired. It returns a messenger which
  // allows listening and sending information to the main isolate.
  final messenger = HandledIsolate.initialize(context);

  // Triggered every time data is received from the main isolate.
  messenger.listen((msg) async {
    // 每次有消息到来时, 获取一次位置
    var location = OneShotLocation(hiCallback(messenger));
    location.getLocation();

    // Use a plugin to get some new value to send back to the main isolate.
    // final dir = await getApplicationDocumentsDirectory();
    // messenger.send(msg + dir.path);
  });
}
