//
//  SharedWebView.m
//  YiCaiTong
//
//  Created by wang on 2019/11/15.
//  Copyright © 2019 wang. All rights reserved.
//

#import "SharedWebView.h"

static SharedWebView *_instance;

@interface SharedWebView () <WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, assign) BOOL isClearContent;

@end

@implementation SharedWebView

+ (instancetype)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        WKWebViewConfiguration *configuration             = [[WKWebViewConfiguration alloc] init];
         // 实例化对象
        configuration.userContentController               = [WKUserContentController new];
        // 进行偏好设置
        WKPreferences *preferences                        = [WKPreferences new];
        preferences.javaScriptEnabled                     = YES;
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        preferences.minimumFontSize                       = 10;
        // 自适应屏幕宽度js
        NSString *jSString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width,initial-scale=1,minimum-scale=1,maximum-scale=1,user-scalable=no'); document.getElementsByTagName('head')[0].appendChild(meta);";
        
        WKUserScript *wkUserScript = [[WKUserScript alloc] initWithSource:jSString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        
        // 添加自适应屏幕宽度js调用的方法
        [configuration.userContentController addUserScript:wkUserScript];
        configuration.preferences = preferences;

        _instance                    = [[SharedWebView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) configuration:configuration];
        _instance.opaque             = NO;
        _instance.backgroundColor    = [UIColor whiteColor];
        _instance.UIDelegate         = _instance;
        _instance.navigationDelegate = _instance;

        if (@available(ios 11.0,*)) {
            _instance.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    });
    return _instance;
}

//- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration
//{
//    //设置代理
//    if (self = [super initWithFrame:frame configuration:configuration]) {
//        self.navigationDelegate = self;
//    }
//    return self;
//}

// 页面开始加载时调用
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
//    _instance.isClearContent = YES;
    //DLog(@"页面开始加载时调用");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if (_instance.delegate && [_instance.delegate respondsToSelector:@selector(wlWebViewLoadBeginWebView:)]) {
        [_instance.delegate wlWebViewLoadBeginWebView:webView];
    }
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    //DLog(@"当内容开始返回时调用");
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    //DLog(@"页面加载完成之后调用");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [webView evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(id _Nullable result,NSError * _Nullable error) {

        CGFloat height = [result floatValue] + 15.00;
        if (height > 50) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getCellHeightNotification" object:nil userInfo:@{@"height":[NSNumber numberWithFloat:height]}];
        }
        if (_instance.delegate && [_instance.delegate respondsToSelector:@selector(wlWebViewLoadFinishWebView:webHeight:)]) {
            [_instance.delegate wlWebViewLoadFinishWebView:webView webHeight:height];
        }
    }];
    
    //注入图片适配
    NSString *width = [NSString stringWithFormat:@"%.0lf", SCREEN_WIDTH];
    NSString *js = [NSString stringWithFormat:@"function imgAutoFit() {var maxwidth = %@;var imgs = document.getElementsByTagName('img'); for (var i = 0; i < imgs.length; ++i) {var img = imgs[i]; if(img.width > maxwidth){img.height = img.height * (maxwidth/img.width); img.width = maxwidth;}}}", width];
    js = [NSString stringWithFormat:js, SCREEN_WIDTH];
    [webView evaluateJavaScript:js completionHandler:nil];
    [webView evaluateJavaScript:@"imgAutoFit();"completionHandler:nil];
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    //DLog(@"加载失败");
    if (_instance.delegate && [_instance.delegate respondsToSelector:@selector(wlWebViewLoadFailWebView:WithError:)]) {
        [_instance.delegate wlWebViewLoadFailWebView:webView WithError:error];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    // 获取新页面的URL
    NSString *url = navigationAction.request.URL.absoluteString;
    if (![url isEqualToString:_instance.webUrl]) {
        _isClearContent = NO;
    } else {
        _isClearContent = YES;
    }
    if ([url hasPrefix:@"tel:"]) {
        NSString *resourceSpecifier = [navigationAction.request.URL resourceSpecifier];
        NSString *callPhone = [NSString stringWithFormat:@"telprompt://%@", resourceSpecifier];
        /// 防止iOS 10及其之后，拨打电话系统弹出框延迟出现
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callPhone] options:@{} completionHandler:^(BOOL success) {
            if (!success) {
                [MBProgressHUD showMessage:@"拨打电话失败"];
            }
        }];
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)clearWebContent
{
    _isClearContent    = YES;
    _instance.delegate = nil;
    [_instance loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]]];
    
    if (@available(iOS 9.0, *)) {
        
        NSSet *websiteDataTypes = [NSSet setWithArray:@[
                                WKWebsiteDataTypeDiskCache,
                                WKWebsiteDataTypeOfflineWebApplicationCache,
                                WKWebsiteDataTypeMemoryCache,
                                WKWebsiteDataTypeLocalStorage,
                                WKWebsiteDataTypeCookies,
                                WKWebsiteDataTypeSessionStorage,
                                WKWebsiteDataTypeIndexedDBDatabases,
                                WKWebsiteDataTypeWebSQLDatabases
                            ]];
        //你可以选择性的删除一些你需要删除的文件 or 也可以直接全部删除所有缓存的type
        //NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
               // code
        }];
        
    } else {
        // Fallback on earlier versions

        NSString *libraryDir = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
        NSUserDomainMask, YES)[0];
        NSString *bundleId  =  [[[NSBundle mainBundle] infoDictionary]
        objectForKey:@"CFBundleIdentifier"];
        NSString *webkitFolderInLib = [NSString stringWithFormat:@"%@/WebKit",libraryDir];
        NSString *webKitFolderInCaches = [NSString
        stringWithFormat:@"%@/Caches/%@/WebKit",libraryDir,bundleId];
         NSString *webKitFolderInCachesfs = [NSString
         stringWithFormat:@"%@/Caches/%@/fsCachedData",libraryDir,bundleId];

        NSError *error;
        /* iOS8.0 WebView Cache的存放路径 */
        [[NSFileManager defaultManager] removeItemAtPath:webKitFolderInCaches error:&error];
        [[NSFileManager defaultManager] removeItemAtPath:webkitFolderInLib error:nil];

        /* iOS7.0 WebView Cache的存放路径 */
        [[NSFileManager defaultManager] removeItemAtPath:webKitFolderInCachesfs error:&error];
    }
}

- (BOOL)isWhiteWeb
{
    return _isClearContent;
}

@end
