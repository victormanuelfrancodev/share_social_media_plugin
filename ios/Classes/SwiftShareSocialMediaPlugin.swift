import Flutter
import UIKit
import OAuthSwift
import SafariServices
import Foundation


public class SwiftShareSocialMediaPlugin: NSObject, FlutterPlugin {

    var oauthswift: OAuthSwift?
    var registrar: FlutterPluginRegistrar? = nil
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "share_social_media_plugin", binaryMessenger: registrar.messenger())
    let instance = SwiftShareSocialMediaPlugin()
    registrar.addApplicationDelegate(instance)
    instance.registrar = registrar
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    self.initializeTwitterInstance(call: call)
    if(call.method == "shareLine"){
        let arguments = call.arguments as! [String:Any]
        guard let urlT = arguments["urlTemp"] as? String else{
           result(FlutterError.init(code: "ArgumentError", message: "Required argument does not exist.", details: nil));
                               return
        }
        open(scheme: "https://social-plugins.line.me/lineit/share?url=\(urlT)")
        result("Ok")
     }else if ("getCurrentSessionIOS" == call.method) {
        let arguments = call.arguments as! [String:Any]
              guard let consumerKey = arguments["consumerKey"] as? String, let consumerKeySecrect = arguments["consumerSecret"] as? String else{
                 result(FlutterError.init(code: "ArgumentError", message: "Some problem with yours keys.", details: nil));
                                     return
              }
       self.getCurrentSession(result, consumerKey: consumerKey, consumerKeySecrect: consumerKeySecrect)
    }else if("shareInstagram" == call.method){
        let arguments = call.arguments as! [String:Any]
        guard let text = arguments["text"] as? String, let assetName = arguments["assetFile"] as? String else{
            result(FlutterError.init(code: "ArgumentError", message: "Some problem with yours keys.", details: nil));
            return
        }
        self.instagram(text: text, image: assetName)
    }else {
       result(FlutterMethodNotImplemented)
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


        //Twitter

    func getCurrentSession(_ resulta:@escaping FlutterResult, consumerKey:String, consumerKeySecrect:String) {
        
        let oauth1swift: OAuth1Swift = OAuth1Swift(
                          consumerKey: consumerKey,
                          consumerSecret: consumerKeySecrect,
                          requestTokenUrl: "https://api.twitter.com/oauth/request_token",
                          authorizeUrl:    "https://api.twitter.com/oauth/authorize",
                          accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
                      )
                oauthswift = oauth1swift
       
            DispatchQueue.main.async {
                             oauth1swift.authorizeURLHandler = self.getURLHandler()
                            
                         }
                                 oauth1swift.authorize(withCallbackURL: URL(string: "TwitterLoginSampleOAuth://")!,
                                                      completionHandler:
                                     { result in
                                         switch result {
                                         case .success(let (credential, _, _)):
                                      
                                            resulta(["outhToken":credential.oauthToken,
                                                     "oauthTokenSecret":credential.oauthTokenSecret,
                                                     "consumerKey" : consumerKey,
                                                     "consumerSecrect": consumerKeySecrect
                                            ])
                                           
                                             print("success")
                                         case .failure(let error):
                                             print(error.localizedDescription)
                                             print("failure")
                                         }
                                 }
                                 )
        
        
      }
    
    func initializeTwitterInstance(call:FlutterMethodCall!) {
      
    }

     func getURLHandler() -> OAuthSwiftURLHandlerType {
 
            if #available(iOS 9.0, *) {
                if let vc = UIApplication.shared.keyWindow?.rootViewController as? FlutterViewController {
                    let handler = SafariURLHandler(viewController: vc, oauthSwift: oauthswift!)
                                   handler.presentCompletion = {
                                       print("Safari presentedo")
                                   }
                                   handler.dismissCompletion = {
                                       print("Safari dismissed")
                                   }
                                    handler.factory = { url in
                                        let controller = SFSafariViewController(url: url)
                                        if #available(iOS 10.0, *) {
                                      //nanaisss
                                    }
                                        return controller
                                    }
                                   return handler
                }
            }
      
            return OAuthSwiftOpenURLExternally.sharedInstance
        }
    
    func authorize(result:FlutterResult) {

    }
    
    
    //Instagram
    func instagram(text:String,image:String){
        let key = registrar?.lookupKey(forAsset: image)
        let topPath = Bundle.main.path(forResource: key, ofType: nil)!
        var topUmage: UIImage = UIImage(contentsOfFile: topPath)!
        
        topUmage = textToImage(drawText: text, inImage: topUmage, atPoint: CGPoint(x: 20, y: 20))
        
        guard let instagramUrl = URL(string: "instagram-stories://share") else {
                  return
              }

              if UIApplication.shared.canOpenURL(instagramUrl) {
                  let pasterboardItems = [["com.instagram.sharedSticker.backgroundImage": topUmage as Any]]
                  UIPasteboard.general.setItems(pasterboardItems)
                  UIApplication.shared.open(instagramUrl)
              } else {
                  // Instagram app is not installed or can't be opened, pop up an alert
              }
    }
    
    func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        let textColor = UIColor.black
        let textFont = UIFont(name: "Helvetica Bold", size: 22)!

        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)

        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            ] as [NSAttributedString.Key : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))

        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}


