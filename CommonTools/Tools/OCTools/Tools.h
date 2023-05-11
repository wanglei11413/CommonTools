#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Tools : NSObject

+(NSString *)getOnly;//获取ipfa

+ (NSString *)getUUID;//获取UUID

/// 获取当前页面
//+ (UIViewController *)getRootVC;

/// 判断目标文字是否为空
/// - Parameter str: 目标文字
+ (BOOL)isblankString:(NSString*)str;

/// 是否为全屏
+ (BOOL)isFullScreen;

/// 获取屏幕底部安全距离
+ (CGFloat)getSafeBottomMargin;

/// 获取tab栏高度
+ (CGFloat)getTabHeight;

/// 顶部状态栏高度
+ (CGFloat)getStatusBarHeight;

/// 获取屏幕顶部安全距离
+ (CGFloat)getSafeTopMargin;

/// 获取导航栏高度
+ (CGFloat)getNavHeight;

/// 是否连接了热点
+ (BOOL)isHotConnect;

@end

NS_ASSUME_NONNULL_END
