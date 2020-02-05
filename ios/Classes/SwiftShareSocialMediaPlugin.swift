import Flutter
import UIKit

public class SwiftShareSocialMediaPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "share_social_media_plugin", binaryMessenger: registrar.messenger())
    let instance = SwiftShareSocialMediaPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if(call.method == "shareLine"){
        let arguments = call.arguments as! [String:Any]
        guard let urlT = arguments["urlTemp"] as? String else{
           result(FlutterError.init(code: "ArgumentError", message: "Required argument does not exist.", details: nil));
                               return
        }
        open(scheme: "https://social-plugins.line.me/lineit/share?url=\(urlT)")
        result("Ok")
     }
  }


   func open(scheme: String) {
          if let url = URL(string: scheme) {
            if #available(iOS 10, *) {
                let options = [UIApplication.OpenExternalURLOptionsKey.universalLinksOnly : false]
              UIApplication.shared.open(url, options: options,
                completionHandler: {
                  success in
                    print("Open \(scheme): \(success.description)")
               })
            } else {
              let success = UIApplication.shared.openURL(url)
              print("Open \(scheme): \(success)")
            }
          }
        }
}
