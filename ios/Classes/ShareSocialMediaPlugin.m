#import "ShareSocialMediaPlugin.h"
#if __has_include(<share_social_media_plugin/share_social_media_plugin-Swift.h>)
#import <share_social_media_plugin/share_social_media_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "share_social_media_plugin-Swift.h"
#endif

@implementation ShareSocialMediaPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftShareSocialMediaPlugin registerWithRegistrar:registrar];
}
@end
