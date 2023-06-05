//
//  SafetyProtection.h
//  CommonTools
//  安全防护工具类
//  Created by admin on 2023/5/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SafetyProtection : NSObject

/// 检测是否使用了代理
+ (BOOL)getisUseProxy;

/// 检测是否二次打包，如果是，直接退出app
+ (void)getIsUseSignature;

/// 检测是否越狱
+ (BOOL)getIsJailBreak;

@end

NS_ASSUME_NONNULL_END
