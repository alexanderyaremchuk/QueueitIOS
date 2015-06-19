#import <UIKit/UIKit.h>
#import "IOSUtils.h"

@implementation IOSUtils

+(NSString*)getUserId{
    UIDevice* device = [[UIDevice alloc]init];
    NSUUID* deviceid = [device identifierForVendor];
    NSString* uuid = [deviceid UUIDString];
    return uuid;
}

+(NSString*)getUserAgent{
    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString* secretAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    return secretAgent;
}

@end
