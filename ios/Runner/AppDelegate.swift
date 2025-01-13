import Flutter
import UIKit
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    flutter_local_notificationsPlugin.setPluginRegistrantCallBack{(registry)in GeneratedPluginRegistrant.register(with: registry)}
    
    GeneratedPluginRegistrant.register(with: self)
    if #available(iOS 10.0,*){
      UNUserNotificationCentre.current().delegate=self as? UNUserNotificationCentre
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
