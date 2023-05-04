//
//  SafetyProtection.m
//  CommonTools
//
//  Created by admin on 2023/5/4.
//

#import "SafetyProtection.h"

/// 签名文件哈希值--可以从上一次打包时获取
#define PROVISION_HASH @"w2vnN9zRdwo0Z0Q4amDuwM2DKhc="
static NSDictionary * rootDic=nil;

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

/**
 /// 阻止动态调试 在main.m中设置
 #import <dlfcn.h>
 #import <sys/types.h>

 typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);
 #if !defined(PT_DENY_ATTACH)
 #define PT_DENY_ATTACH 31
 #endif  // !defined(PT_DENY_ATTACH)

 void disable_gdb() {
     void* handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
     ptrace_ptr_t ptrace_ptr = dlsym(handle, "ptrace");
     ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0);
     dlclose(handle);
 }

 int main(int argc, char *argv[]) {
     // Don't interfere with Xcode debugging sessions.
     #if !(DEBUG)
         disable_gdb();
     #endif

     @autoreleasepool {
         return UIApplicationMain(argc, argv, nil,
             NSStringFromClass([MyAppDelegate class]));
     }
 }
 */

+ (BOOL)getProxyStatus
{
#ifdef DEBUG
    return NO;
#else
    NSDictionary *proxySettings = (__bridge NSDictionary *)(CFNetworkCopySystemProxySettings());
    
    NSArray *proxies = (__bridge NSArray *)(CFNetworkCopyProxiesForURL((__bridge CFURLRef _Nonnull)([NSURL URLWithString:@"http://www.baidu.com"]), (__bridge CFDictionaryRef _Nonnull)(proxySettings)));
    
    NSDictionary *settings = proxies[0];
    
    if ([[settings objectForKey:(NSString *)kCFProxyTypeKey] isEqualToString:@"kCFProxyTypeNone"]) {
        // 未使用代理
        return NO;
    } else {
        // 使用了代理
        return YES;
    }
#endif
}

+ (void)checkSignatureMsg
{
    NSString *newPath=[[NSBundle mainBundle] resourcePath];

    if (!rootDic) {
        rootDic = [[NSDictionary alloc] initWithContentsOfFile:[newPath stringByAppendingString:@"/_CodeSignature/CodeResources"]];
    }

    NSDictionary*fileDic = [rootDic objectForKey:@"files2"];

    NSDictionary *infoDic = [fileDic objectForKey:@"embedded.mobileprovision"];
    NSData *tempData = [infoDic objectForKey:@"hash"];
    NSString *hashStr = [tempData base64EncodedStringWithOptions:0];
    if (hashStr != nil &&
        ![PROVISION_HASH isEqualToString:hashStr]) {
        abort();//退出应用
    }
}

@end
