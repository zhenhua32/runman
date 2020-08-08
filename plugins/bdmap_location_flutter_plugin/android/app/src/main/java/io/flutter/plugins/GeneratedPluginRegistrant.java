package io.flutter.plugins;

import io.flutter.plugin.common.PluginRegistry;
import com.baseflow.permissionhandler.PermissionHandlerPlugin;
import com.baidu.bdmap_location_flutter_plugin.LocationFlutterPlugin;

/**
 * Generated file. Do not edit.
 */
public final class GeneratedPluginRegistrant {
  public static void registerWith(PluginRegistry registry) {
    if (alreadyRegisteredWith(registry)) {
      return;
    }
    PermissionHandlerPlugin.registerWith(registry.registrarFor("com.baseflow.permissionhandler.PermissionHandlerPlugin"));
    LocationFlutterPlugin.registerWith(registry.registrarFor("com.baidu.bdmap_location_flutter_plugin.LocationFlutterPlugin"));
  }

  private static boolean alreadyRegisteredWith(PluginRegistry registry) {
    final String key = GeneratedPluginRegistrant.class.getCanonicalName();
    if (registry.hasPlugin(key)) {
      return true;
    }
    registry.registrarFor(key);
    return false;
  }
}
