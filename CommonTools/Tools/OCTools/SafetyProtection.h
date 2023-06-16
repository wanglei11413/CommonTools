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

/// 检测Mach-O文件是否被篡改
+ (BOOL)getIsMachO;

/// 检测签名文件是否被篡改
+ (BOOL)getIsSignature;

/// 检测是否越狱
+ (BOOL)getIsJailBreak;

/// 关闭ptrace调试，阻止调试器依附
+ (void)disable_gdb;

/// 检测sysctl状态
+ (BOOL)getIsSysctl;

/// 捕捉SIGSTOP信号
+ (BOOL)getIsSIGSTOP;

/// 开启反调试
+ (void)AntiDebugASM;

@end

NS_ASSUME_NONNULL_END
