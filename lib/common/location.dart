import 'dart:async';
import 'dart:io';

import 'package:bdmap_location_flutter_plugin/bdmap_location_flutter_plugin.dart';
import 'package:bdmap_location_flutter_plugin/flutter_baidu_location_android_option.dart';
import 'package:bdmap_location_flutter_plugin/flutter_baidu_location_ios_option.dart';

import 'toast.dart';

/// 初始化百度地图, 应该在 main() 函数中调用
initBaiduMap() {
  // 百度地图sdk初始化鉴权
  if (Platform.isIOS) {
    // TODO: 从百度地图中创建 IOS 应用, 获取 AK
    LocationFlutterPlugin.setApiKey("百度地图开放平台申请的ios端ak");
    // BMFMapSDK.setApiKeyAndCoordType('yFDD3IlfSk2xTdQ0G41MjRnzd5gUVG1C', BMF_COORD_TYPE.BD09LL);
  } else if (Platform.isAndroid) {
    // Android 目前不支持接口设置Apikey,
    // 请在主工程的Manifest文件里设置，详细配置方法请参考官网(https://lbsyun.baidu.com/)demo
    // BMFMapSDK.setCoordType(BMF_COORD_TYPE.BD09LL);
  }
}

// 定义类型
typedef LocationCallback = void Function(Map<String, Object>);

// 一个普通的回调函数示例
void myCallback(Map<String, Object> result) {
  print(result);
  var position = 'null';
  if (result != null) {
    position = '经度: ${result["longitude"]}, 纬度: ${result["latitude"]}';
    sendToast(position);
  }
  print(position);
}

/// 用于获取一次位置信息
class OneShotLocation {
  /// 位置流的监听器
  StreamSubscription<Map<String, Object>> _locationListener;

  /// 创建百度地图插件的实例
  LocationFlutterPlugin _locationPlugin = LocationFlutterPlugin();
  String position = '未知';

  // 构造函数
  OneShotLocation(LocationCallback callback) {
    // 创建百度地图插件的实例
    initListen(callback);
  }

  /// 开始获取位置
  getLocation() {
    // _locationPlugin.requestPermission();
    _setLocOption();
    _locationPlugin.startLocation();
    print('---------');
  }

  /// 停止位置流监听
  stopLocation() {
    _locationListener?.cancel(); // 停止定位
  }

  /// 初始化位置流监听器
  void initListen(LocationCallback callback) {
    // TODO: 没有找到方法在实例被删除(垃圾回收)之前停止定位
    var newCallback = (Map<String, Object> result) {
      callback(result);
      stopLocation(); // 手动停止定位
    };
    _locationListener = _locationPlugin.onResultCallback().listen(newCallback);
  }

  /// 设置android端和ios端定位参数
  void _setLocOption() {
    /// android 端设置定位参数
    BaiduLocationAndroidOption androidOption = new BaiduLocationAndroidOption();
    androidOption.setCoorType("bd09ll"); // 设置返回的位置坐标系类型
    androidOption.setIsNeedAltitude(true); // 设置是否需要返回海拔高度信息
    androidOption.setIsNeedAddres(true); // 设置是否需要返回地址信息
    androidOption.setIsNeedLocationPoiList(true); // 设置是否需要返回周边poi信息
    androidOption.setIsNeedNewVersionRgc(true); // 设置是否需要返回最新版本rgc信息
    androidOption.setIsNeedLocationDescribe(true); // 设置是否需要返回位置描述
    androidOption.setOpenGps(true); // 设置是否需要使用gps
    androidOption.setLocationMode(LocationMode.Hight_Accuracy); // 设置定位模式
    androidOption.setScanspan(0); // 设置发起定位请求时间间隔, 0 表示单次请求. 似乎不太有用, 可能需要明确调用 stopLocation

    Map androidMap = androidOption.getMap();

    /// ios 端设置定位参数
    BaiduLocationIOSOption iosOption = new BaiduLocationIOSOption();
    iosOption.setIsNeedNewVersionRgc(true); // 设置是否需要返回最新版本rgc信息
    iosOption.setBMKLocationCoordinateType("BMKLocationCoordinateTypeBMK09LL"); // 设置返回的位置坐标系类型
    iosOption.setActivityType("CLActivityTypeAutomotiveNavigation"); // 设置应用位置类型
    iosOption.setLocationTimeout(10); // 设置位置获取超时时间
    iosOption.setDesiredAccuracy("kCLLocationAccuracyBest"); // 设置预期精度参数
    iosOption.setReGeocodeTimeout(10); // 设置获取地址信息超时时间
    iosOption.setDistanceFilter(0.1); // 设置定位最小更新距离
    iosOption.setAllowsBackgroundLocationUpdates(true); // 是否允许后台定位
    iosOption.setPauseLocUpdateAutomatically(true); //  定位是否会被系统自动暂停

    Map iosMap = iosOption.getMap();

    _locationPlugin.prepareLoc(androidMap, iosMap);
  }
}
