//
//  SafetyProtection.m
//  CommonTools
//
//  Created by admin on 2023/5/4.
//

#import "SafetyProtection.h"
#import <UIKit/UIKit.h>

#include <stdlib.h>
#include <assert.h>
#include <stdbool.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/sysctl.h>
#import <dlfcn.h>
#import <sys/types.h>

/// 签名文件哈希值--可以从上一次打包时获取
#define PROVISION_HASH @"OP8uAdrs3Y4tVvub3HsmooVigqU="
static NSDictionary * rootDic=nil;

typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);
#if !defined(PT_DENY_ATTACH)
#define PT_DENY_ATTACH 31
#endif  // !defined(PT_DENY_ATTACH)


@implementation SafetyProtection

/**
 /// 关闭键盘纠错
 let view = UITextField(frame: kScreenFrame)
 view.autocorrectionType = .no
 */

/**
 /// 禁止粘贴功能
 -(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
 UIMenuController *menuController = [UIMenuController sharedMenuController];
 if (menuController) {
 menuController.menuVisible = NO;
 }
 return NO;
 }
 */

+ (BOOL)getisUseProxy
{
#ifdef DEBUG
    return NO;
#else
    NSDictionary *proxySettings = (__bridge NSDictionary *)(CFNetworkCopySystemProxySettings());
    
    NSArray *proxies = (__bridge NSArray *)(CFNetworkCopyProxiesForURL((__bridge CFURLRef _Nonnull)([NSURL URLWithString:@"https://www.baidu.com"]), (__bridge CFDictionaryRef _Nonnull)(proxySettings)));
    
    NSDictionary *settings = proxies[0];
    
    if ([[settings objectForKey:(NSString *)kCFProxyTypeKey] isEqualToString:@"kCFProxyTypeNone"]) {
        // 未使用代理
        return NO;
    } else {
        // 使用了代理
        DLog(@"使用了代理")
        return YES;
    }
#endif
}

+ (BOOL)getIsMachO
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *info = [bundle infoDictionary];
    if ([info objectForKey:@"SignerIdentity"] != nil){
        //存在这个key，则说明被二次打包了
        DLog(@"Mach-O被篡改，进行了二次打包")
        return YES;
    }
    return NO;
}

+ (BOOL)getIsSignature
{
    //9HBKR82YF5
    if ([self checkCodeSignWithProvisionID:@"9HBKR82YF5"]) {
        return YES;
    }
    
    NSString *newPath = [[NSBundle mainBundle] resourcePath];

    if (!rootDic) {
        rootDic = [[NSDictionary alloc] initWithContentsOfFile:[newPath stringByAppendingString:@"/_CodeSignature/CodeResources"]];
    }

    NSDictionary *fileDic = [rootDic objectForKey:@"files2"];
    
    if ([fileDic objectForKey:@"embedded.mobileprovision"] != nil) {
        //
        NSDictionary *infoDic = [fileDic objectForKey:@"embedded.mobileprovision"];
        NSData *tempData = [infoDic objectForKey:@"hash"];
        NSString *hashStr = [tempData base64EncodedStringWithOptions:0];
        if (hashStr != nil &&
            ![PROVISION_HASH isEqualToString:hashStr]) {
            DLog(@"签名文件被篡改，进行了二次打包")
            return YES;
        }
    }
    return NO;
}

/// 检测是否进行了二次签名
/// - Parameter provisionID: 传入teamID
+ (BOOL)checkCodeSignWithProvisionID:(NSString *)provisionID
{
     // 描述文件路径
    NSString *embeddedPath = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:embeddedPath]) {
        // 读取application-identifier
        NSString *embeddedProvisioning = [NSString stringWithContentsOfFile:embeddedPath encoding:NSASCIIStringEncoding error:nil];
        NSArray *embeddedProvisioningLines = [embeddedProvisioning componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        for (int i = 0; i < [embeddedProvisioningLines count]; i++) {
            if ([[embeddedProvisioningLines objectAtIndex:i] rangeOfString:@"application-identifier"].location != NSNotFound) {
                
                NSInteger fromPosition = [[embeddedProvisioningLines objectAtIndex:i+1] rangeOfString:@"<string>"].location+8;
                
                NSInteger toPosition = [[embeddedProvisioningLines objectAtIndex:i+1] rangeOfString:@"</string>"].location;
                
                NSRange range;
                range.location = fromPosition;
                range.length = toPosition - fromPosition;
                
                NSString *fullIdentifier = [[embeddedProvisioningLines objectAtIndex:i+1] substringWithRange:range];
                NSArray *identifierComponents = [fullIdentifier componentsSeparatedByString:@"."];
                // 得到最终的签名ID
                NSString *appIdentifier = [identifierComponents firstObject];
                // 对比签名ID
                if (![appIdentifier isEqual:provisionID])
                {
                    DLog(@"teamID比对不一致，进行了二次签名")
                    return YES;
                }
            }
        }
    }
    return NO;
}

+ (BOOL)getIsJailBreak
{
    // 如果可以打开cydia，代表越狱了
    if ([UIApplication.sharedApplication canOpenURL:[NSURL URLWithString:@"cydia://"]]) {
        DLog(@"为越狱设备")
        return YES;
    }
    
    // 如果可以打开常用的越狱文件，代表越狱了
    NSArray *pathArr = @[@"/Applications/Cydia.app",
                         @"/Library/MobileSubstrate/MobileSubstrate.dylib",
                         @"/usr/sbin/sshd",
                         @"/etc/apt"];
    for (int i = 0 ; i < pathArr.count ; i ++) {
        NSString *path = pathArr[i];
        if ([NSFileManager.defaultManager fileExistsAtPath:path]) {
            DLog(@"为越狱设备")
            return YES;
        }
    }
    // 是否有完全访问权限，有就代表越狱了
    NSString *appPath = @"/Applications/";
    if ([NSFileManager.defaultManager fileExistsAtPath:appPath]) {
        NSArray *appList = [NSFileManager.defaultManager contentsOfDirectoryAtPath:appPath error:nil];
        if (appList.count > 0) {
            DLog(@"为越狱设备")
            return YES;
        }
    }
    // 未越狱
    return NO;
}

+ (void)disable_gdb
{
#if !(DEBUG)
    void *handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
    ptrace_ptr_t ptrace_ptr = dlsym(handle, "ptrace");
    ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0);
    dlclose(handle);
#endif
}

+ (BOOL)getIsSysctl
{
    int name[4];
    struct kinfo_proc info;
    size_t info_size = sizeof(info);
    info.kp_proc.p_flag = 0;
    name[0] = CTL_KERN;
    name[1] = KERN_PROC;
    name[2] = KERN_PROC_PID;
    name[3] = getpid();
    if (sysctl(name, 4, &info, &info_size, NULL, 0) == -1) {
        perror("sysctl");
        DLog(@"开启了sysctl--报错？")
        exit(EXIT_FAILURE);
    }
    // 是否存在调试器
    bool a = ((info.kp_proc.p_flag & P_TRACED) != 0);
    if (a == true) {
        // 是否开启调试器
        a = (getenv("DYLD_INSERT_LIBRARIES") != NULL);
    }
    if (a) {
        DLog(@"开启了sysctl")
    }
    return a;
}

+ (BOOL)getIsSIGSTOP
{
    __block BOOL result = NO;
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_SIGNAL, SIGSTOP, 0, dispatch_get_main_queue());
    dispatch_source_set_event_handler(source, ^{
        result = YES;
    });
    dispatch_resume(source);
    
    if (result) {
        DLog(@"捕捉到了SIGSTOP信号")
    }
    return result;
}

+ (void)AntiDebugASM
{
    anti_debug();
    check_svc_integrity();
    // 如果为1，那么代表处于调试状态
    if (isatty(1)) {
        abort();
    }
}

#pragma mark - 反调试检测 -
/// 使用inline方式将函数在调用处强制展开，防止被hook和追踪符号
static __attribute__((always_inline)) void anti_debug()
{
#ifdef __arm__
    __asm__ __volatile__
    (
     "mov r0,#31\n"
     "mov r1,#0\n"
     "mov r2,#0\n"
     "mov r12,#26\n"
     "svc #80\n"
     );
#endif
    // 判断是否是ARM64处理器指令集
#ifdef __arm64__
    // volatile修饰符能够防止汇编指令被编译器忽略
    __asm__ __volatile__
    (
     "mov X0, #26\n"
     "mov X1, #31\n"
     "mov X2, #0\n"
     "mov X3, #0\n"
     "mov X4, #0\n"
     "mov w16, #0\n"
     "svc #0x80"
     );
#endif
}

/// 反调试检测
static __attribute__((always_inline)) void check_svc_integrity() {
    int pid;
    static jmp_buf protectionJMP;
#ifdef __arm64__
    __asm__ __volatile__
    (
     "mov x0, #0\n"
     "mov w16, #20\n"
     "svc #0x80\n"
     "cmp x0, #0\n"
     "b.ne #24\n"
     
     "mov x1, #0\n"
     "mov sp, x1\n"
     "mov x29, x1\n"
     "mov x30, x1\n"
     "ret\n"
            
     "mov %[result], x0\n"
     : [result] "=r" (pid)
     :
     :
     );
    
    if (pid == 0) {
        longjmp(protectionJMP, 1);
    }
#endif
}

@end
