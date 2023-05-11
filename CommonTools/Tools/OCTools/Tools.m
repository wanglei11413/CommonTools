#import "Tools.h"
#import <AdSupport/ASIdentifierManager.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>

NSString * const KEY_UDID_INSTEAD = @"com.myapp.udid.test";

@implementation Tools


//判断是否存在唯一标识
+(NSString *)getOnly
{
    NSString * onlyKey = @"";
//    NSString *onlyKey = [[NSUserDefaults standardUserDefaults]objectForKey:ONLY_KEY];
//
//    if([onlyKey isEqualToString:@""]||![onlyKey isKindOfClass:[NSString class]])
//    {
//        onlyKey =  [Tools returnVarOnlyKey];
//
//    }else
//    {
//        if(![onlyKey isEqualToString:[Tools getIpfa]]&&![onlyKey isEqualToString:[Tools getUUID]])
//        {
//            onlyKey =  [Tools returnVarOnlyKey];
//
//        }
//
//    }
//    [[NSUserDefaults standardUserDefaults] setObject:onlyKey forKey:ONLY_KEY];
//********以上方法也可以下方更简洁*******//
    NSString *IpfaStr = [Tools getIpfa];//
    NSString *keychainStr = [Tools getDeviceIDInKeychain];//
    NSString *UUIDStr = [Tools getUUID];//
    //实时获取ipfa 当用户开始关闭权限时为空 获取的keychainStr 当用户再次打开权限时相当于换了不同设别 此时唯一标识换成了IpfaStr 需要发送随机码
    onlyKey = IpfaStr;
    if([IpfaStr isEqualToString:@""]||![IpfaStr isKindOfClass:[NSString class]])
    {
        onlyKey = keychainStr;
        
    }else if([keychainStr isEqualToString:@""]||![keychainStr isKindOfClass:[NSString class]])
    {
        onlyKey = UUIDStr;

    }
 //-I为了区分设备
    return [NSString stringWithFormat:@"%@_I",onlyKey];
}
//封装获取唯一标识外加存储方法 好几个地方使用
+(NSString *)returnVarOnlyKey
{
    //先获取idfa 如果没有在获取UUID 不可能会同时存在两个都没有的情况
        if([[Tools getIpfa] isEqualToString:@""]||![[Tools getIpfa]isKindOfClass:[NSString class]])
        {
            return  [Tools getUUID];

        }else
        {
            return [Tools getIpfa];

        }
    return @"";
}
/**
 本方法是得到 UUID 后存入系统中的 keychain 的方法
 不用添加 plist 文件
 程序删除后重装,仍可以得到相同的唯一标示
 但是当系统升级或者刷机后,系统中的钥匙串会被清空,此时本方法失效
 */
+(NSString *)getDeviceIDInKeychain {
    NSString *getUDIDInKeychain = (NSString *)[Tools load:KEY_UDID_INSTEAD];
    NSLog(@"从keychain中获取到的 UDID_INSTEAD %@",getUDIDInKeychain);
    if (!getUDIDInKeychain ||[getUDIDInKeychain isEqualToString:@""]||[getUDIDInKeychain isKindOfClass:[NSNull class]]) {
        CFUUIDRef puuid = CFUUIDCreate( nil );
        CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
        NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
        CFRelease(puuid);
        CFRelease(uuidString);
        NSLog(@"\n \n \n _____重新存储 UUID _____\n \n \n  %@",result);
        [Tools save:KEY_UDID_INSTEAD data:result];
        getUDIDInKeychain = (NSString *)[Tools load:KEY_UDID_INSTEAD];
    }
    NSLog(@"最终 ———— UDID_INSTEAD %@",getUDIDInKeychain);
    return getUDIDInKeychain;
}
+ (void)save:(NSString *)service data:(id)data {
    //Get search dictionary
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Delete old item before add new item
    SecItemDelete((CFDictionaryRef)keychainQuery);
    //Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    //Add item to keychain with the search dictionary
    SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
}
+ (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Configure the search setting
    //Since in our simple case we are expecting only a single attribute to be returned (the password) we can set the attribute kSecReturnData to kCFBooleanTrue
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    }
    if (keyData)
        CFRelease(keyData);
    return ret;
}

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service
{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (id)kSecClassGenericPassword,(id)kSecClass,
            service, (id)kSecAttrService,
            service, (id)kSecAttrAccount,
            (id)kSecAttrAccessibleAfterFirstUnlock,(id)kSecAttrAccessible,
            nil];
}

+ (NSString *)getIpfa
{
   __block  NSString * idfa = @"";
    if (@available(iOS 14, *)) {
        
        __block BOOL isPerformNextStep = NO;

        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0/*延迟执行时间*/ * NSEC_PER_SEC));
            
            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                
                // iOS14及以上版本需要先请求权限
                [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                    // 获取到权限后，依然使用老方法获取idfa
                    if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                        idfa = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
                        NSLog(@"%@",idfa);
                        isPerformNextStep = YES;

                    } else {
                             NSLog(@"请在设置-隐私-跟踪中允许App请求跟踪");
                        isPerformNextStep = YES;
                    }
                }];

            });
        
        while (!isPerformNextStep) {
              [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
          }

        } else {
        // iOS14以下版本依然使用老方法
        // 判断在设置-隐私里用户是否打开了广告跟踪
        if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
            idfa = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
            NSLog(@"%@",idfa);
        } else {
            NSLog(@"请在设置-隐私-广告中打开广告跟踪功能");
        }
    }
    return idfa;
}

+ (NSString *)getUUID{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *UUID = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);

    return UUID;
}

//+ (UIViewController *)getRootVC
//{
//    UIWindow *window = UIApplication.sharedApplication.delegate.window;
//    UIViewController *rootVC = window.rootViewController;
//
//    if (rootVC.presentedViewController != nil) {
//        rootVC = (UIViewController *)rootVC.presentedViewController;
//
//    } else if ([rootVC isKindOfClass:[UISplitViewController class]]) {
//        UISplitViewController *svc = (UISplitViewController *)rootVC;
//        if (svc.viewControllers.count > 0) {
//            rootVC = svc.viewControllers.lastObject;
//        }
//
//    } else if ([rootVC isKindOfClass:[UINavigationController class]]) {
//        UINavigationController *nvc = (UINavigationController *)rootVC;
//        if (nvc.viewControllers.count > 0) {
//            rootVC = nvc.topViewController;
//        }
//
//    } else if ([rootVC isKindOfClass:[UITabBarController class]]) {
//        UITabBarController *tvc = (UITabBarController *)rootVC;
//        if (tvc.viewControllers.count > 0) {
//            rootVC = tvc.selectedViewController;
//        }
//    }
//
//    return rootVC;
//}

+ (BOOL)isblankString:(NSString*)str
{
    if (!str) {
        return YES;
    }
    if ([str isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([str isEqual:[NSNull null]]) {
        return YES;
    }
    if ([str isEqualToString:@"(null)"]) {
        return YES;
    }
    if ([str isEqualToString:@"<null>"]) {
        return YES;
    }
    if([str isEqualToString:@""]) {
        return YES;
    }
    if (!str.length) {
        return YES;
    }
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedstr = [str stringByTrimmingCharactersInSet:set];
    if (!trimmedstr.length) {
        return YES;
    }
    return NO;
}

+ (BOOL)isFullScreen
{
    if ([self getSafeBottomMargin] > 0 ||
        [self getSafeTopMargin] > 30) {
        return YES;
    } else {
        return NO;
    }
}

+ (CGFloat)getSafeBottomMargin
{
    CGFloat safeBottom = 0.0;
    if (@available(iOS 13.0, *)) {
        NSSet *set = UIApplication.sharedApplication.connectedScenes;
        UIWindowScene *scene = [set anyObject];
        safeBottom = scene.windows.firstObject.safeAreaInsets.bottom;
    } else if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeArea = UIApplication.sharedApplication.keyWindow.safeAreaInsets;
        safeBottom = safeArea.bottom;
    } else {
        // Fallback on earlier versions
    }
    return safeBottom;
}

+ (CGFloat)getTabHeight
{
    return 49 + [self getSafeBottomMargin];
}

+ (CGFloat)getStatusBarHeight
{
    if (@available(iOS 13.0, *)) {
        NSSet *set = [UIApplication sharedApplication].connectedScenes;
        UIWindowScene *windowScene = [set anyObject];
        UIStatusBarManager *statusBarManager = windowScene.statusBarManager;
        return statusBarManager.statusBarFrame.size.height;
    } else {
        return [UIApplication sharedApplication].statusBarFrame.size.height;
    }
}

+ (CGFloat)getSafeTopMargin
{
    CGFloat safeTop = 0.0;
    if (@available(iOS 13.0, *)) {
        NSSet *set = UIApplication.sharedApplication.connectedScenes;
        UIWindowScene *scene = [set anyObject];
        safeTop = scene.windows.firstObject.safeAreaInsets.top;
    } else if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeArea = UIApplication.sharedApplication.keyWindow.safeAreaInsets;
        safeTop = safeArea.top;
    } else {
        // Fallback on earlier versions
    }
    return safeTop;
}

+ (CGFloat)getNavHeight
{
    return 44 + [self getSafeTopMargin];
}

+ (BOOL)isHotConnect
{
    if ([self getStatusBarHeight] == 40) {
        return YES;
    } else {
        return NO;
    }
}

@end
