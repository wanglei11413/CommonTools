//
//  SharedWebView.h
//  YiCaiTong
//
//  Created by wang on 2019/11/15.
//  Copyright © 2019 wang. All rights reserved.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SharedWebViewDelegate <NSObject>

/// 开始加载
- (void)wlWebViewLoadBeginWebView:(WKWebView *)webView;

/// 加载失败
/// @param webView 网页
/// @param error 错误
- (void)wlWebViewLoadFailWebView:(WKWebView *)webView WithError:(NSError *)error;

/// 加载完成
/// @param webView 网页
/// @param webHeight 网页高度
- (void)wlWebViewLoadFinishWebView:(WKWebView *)webView webHeight:(CGFloat)webHeight;

@end

@interface SharedWebView : WKWebView

/// 初始请求地址
@property (nonatomic, strong) NSString *webUrl;

+ (instancetype)shared;

/// 代理
@property (nonatomic, assign) id<SharedWebViewDelegate> __nullable delegate;

/// 清除网页内容
- (void)clearWebContent;

/// 是否是空白网页
- (BOOL)isWhiteWeb;

@end

NS_ASSUME_NONNULL_END
