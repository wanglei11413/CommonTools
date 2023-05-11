//
//  BasicViewController.m
//  qianQianJiaDao
//
//  Created by Monster on 2017/12/29.
//  Copyright © 2017年 huiYanKeJi. All rights reserved.
//

#import "BasicViewController.h"
#import "UIImage+ChangedColor.h"
#import <UMCommon/MobClick.h>
#import "TailorPhotoViewController.h"

@interface BasicViewController ()

@end

@implementation BasicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置随机背景色
//    self.view.backgroundColor = RGBCOLOR(arc4random_uniform(255), arc4random_uniform(255), arc4random_uniform(255));
    self.view.backgroundColor = [UIColor whiteColor];
    //设置导航栏返回箭头文字
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    //设置文字大小
    [navBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:FITFRAME(18.0)]}];
    //是否允许透明
    [navBar setTranslucent:YES];
    //底部细线
    [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    //设置navBar的渲染风格为深色
    [navBar setBarStyle:UIBarStyleDefault];
    //图标的渲染颜色
    [navBar setTintColor:TextColor_DarkGray];
    //navBar的背景颜色
    [navBar setBarTintColor:[UIColor whiteColor]];
    //隐藏导航栏底部细线
//    [navBar setShadowImage:[[UIImage alloc] init]];
    //导航栏大标题
    if (@available(iOS 11.0, *)) {
        [navBar setPrefersLargeTitles:NO];
    } else {
        // Fallback on earlier versions
    }
    
    /** 设置文字大小颜色 */
    if (_navTextColor) {
        [navBar setTitleTextAttributes:@{ NSForegroundColorAttributeName:_navTextColor, NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Medium" size:FITFRAME(18)]}];
    }
    /** 是否不允许透明效果 */
    if (_navUnTranslucent) {
        [navBar setTranslucent:NO];
    }
    /** 隐藏底部细线 */
    if (_navShadowImageHidden) {
        [navBar setShadowImage:[[UIImage alloc] init]];
        navBar.clipsToBounds = YES;
    } else {
        navBar.clipsToBounds = NO;
        [navBar setShadowImage:[UIImage imageWithColor:APP_LineColor size:CGSizeMake(1, 1)]];
    }
    /** 导航栏背景颜色 */
    if (_navBackgroundColor) {
        [navBar setBackgroundImage:[UIImage imageWithColor:_navBackgroundColor size:CGSizeMake(1, 1)] forBarMetrics:UIBarMetricsDefault];
    }
    /** 导航栏渲染风格 */
    if (_navBarStyle) {
         [navBar setBarStyle:_navBarStyle];
    }
    /** 导航栏图标渲染颜色 */
    if (_navTintColor) {
        [navBar setTintColor:_navTintColor];
    }
    
    BOOL tailorVC = [self isKindOfClass:[TailorPhotoViewController class]];
    if (tailorVC)
    {
        [navBar setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor] size:CGSizeMake(1, 1)] forBarMetrics:UIBarMetricsDefault];
        [navBar setShadowImage:[[UIImage alloc] init]];
        //设置navBar的渲染风格为深色
        [navBar setBarStyle:UIBarStyleBlack];
        //图标的渲染颜色
        [navBar setTintColor:[UIColor whiteColor]];
    } else {
        [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    }
    
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        
        appearance.titleTextAttributes = @{ NSForegroundColorAttributeName:_navTextColor == nil ? TextColor_DarkGray : _navTextColor, NSFontAttributeName: [UIFont systemFontOfSize:FITFRAME(18.0)]};
        
        if (_navBackgroundColor) {
            appearance.backgroundImage = [UIImage imageWithColor:_navBackgroundColor size:CGSizeMake(1, 1)];
        } else {
            appearance.backgroundImage = [UIImage new];
            appearance.backgroundColor = UIColor.whiteColor;
        }
        appearance.backgroundEffect = nil;
     
        [UINavigationBar appearance].standardAppearance = appearance;
        [UINavigationBar appearance].scrollEdgeAppearance = appearance;
    }
    
    [MobClick beginLogPageView:self.navigationItem.title?self.navigationItem.title:@""];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [MBProgressHUD hideHUD];
    
    [MobClick endLogPageView:self.navigationItem.title?self.navigationItem.title:@""];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [MBProgressHUD hideHUD];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
