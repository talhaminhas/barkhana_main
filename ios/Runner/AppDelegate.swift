// import UIKit
// import Flutter

// @UIApplicationMain
// @objc class AppDelegate: FlutterAppDelegate {
//   override func application(
//     _ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//   ) -> Bool {
//     GeneratedPluginRegistrant.register(with: self)
//     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//   }
// }

import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
      NSLog("%@", "before firebase")
    //if FirebaseApp.app() == nil {
        FirebaseApp.configure()
      NSLog("%@", "after firebase")
    //}
      GeneratedPluginRegistrant.register(with: self)
      NSLog("%@", "after plugin register")
    //BTAppContextSwitcher.setReturnURLScheme("com.panaceasoft.flutterrestaurant.braintree")
       
    if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
      NSLog("%@", "before return")
    //return true;
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

//  override
//  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
////    if url.scheme?.localizedCaseInsensitiveCompare("com.panaceasoft.flutterrestaurant.braintree") == .orderedSame {
////        return BTAppContextSwitcher.handleOpenURL(url)
////    }
//    return false
//  }

// If you support iOS 8, add the following method.
//override
//func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//    if url.scheme?.localizedCaseInsensitiveCompare("com.panaceasoft.flutterrestaurant.braintree") == .orderedSame {
//        return BTAppContextSwitcher.handleOpenURL(url)
//    }
//    return false
//}
}

// import UIKit
// import Firebase

// @UIApplicationMain
// class AppDelegate: UIResponder, UIApplicationDelegate {

//   var window: UIWindow?

//   func application(_ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions:
//       [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//     FirebaseApp.configure()
//     return true
//   }
// }
