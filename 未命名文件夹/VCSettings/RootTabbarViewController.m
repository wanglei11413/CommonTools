//
//  RootTabbarViewController.m
//  huHuiShop
//
//  Created by Monster on 2017/12/19.
//  Copyright © 2017年 huiYanKeJi. All rights reserved.
//

#import "RootTabbarViewController.h"
#import "BaseNaviViewController.h"
#import "HomeViewController.h"
#import "TransactViewController.h"
#import "AccountViewController.h"
#import "MyViewController.h"

@interface RootTabbarViewController () <UITabBarControllerDelegate>

/// 上一次的tab栏位置
@property (nonatomic, assign) UIViewController *lastVC;

@end

@implementation RootTabbarViewController

-(instancetype)init
{
    if (self = [super init]) {
        //背景色
        self.tabBar.backgroundColor = APP_BasicColor;
        self.tabBar.barTintColor    = [VTGeneralTool colorWithHex:@"#fafafa"];
        self.tabBar.tintColor       = APP_MainColor;
        self.tabBar.translucent     = NO;
        //字体大小，颜色（未被选中时）
        [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[VTGeneralTool colorWithHex:@"#80808"], NSForegroundColorAttributeName, [UIFont systemFontOfSize:FITFRAME(10.00)],NSFontAttributeName,nil]forState:UIControlStateNormal];
        //字体大小，颜色（被选中时）
        [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:APP_MainColor,NSForegroundColorAttributeName, [UIFont systemFontOfSize:FITFRAME(10.00)],NSFontAttributeName,nil]forState:UIControlStateSelected];
        
        //首页
        [self addChildVC:[HomeViewController new] title:@"首页" normalImageName:@"home" selectedImageName:@"home_high"];
        //办理
        [self addChildVC:[TransactViewController new] title:@"办理" normalImageName:@"transact" selectedImageName:@"transact_high"];
        //账户
        [self addChildVC:[AccountViewController new] title:@"账户" normalImageName:@"account" selectedImageName:@"account_high"];
        //我的
        [self addChildVC:[MyViewController new] title:@"我的" normalImageName:@"mine" selectedImageName:@"mine_high"];
        
        self.delegate = self;
        
// 矫正TabBar图片位置，使之垂直居中显示
//        CGFloat offset = 6.0;
//        for (UITabBarItem *item in self.tabBar.items) {
//            item.imageInsets = UIEdgeInsetsMake(offset, 0, -offset, 0);
//        }
        
    }
    return self;
}

- (void)addChildVC:(UIViewController *)childVC
             title:(NSString *)title
   normalImageName:(NSString *)normalImageName
 selectedImageName:(NSString *)selectedImageName
{
    // 未选中图片
    UIImage *norImage = [[UIImage imageNamed:normalImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    // 选中图片
    UIImage *selectedImage = [[UIImage imageNamed:selectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //
    UITabBarItem *tabItem = [[UITabBarItem alloc] initWithTitle:title image:norImage selectedImage:selectedImage];
    // 导航
    BaseNaviViewController *nav    = [[BaseNaviViewController alloc] initWithRootViewController:childVC];
    nav.useSystemBackBarButtonItem = YES;
    nav.tabBarItem                 = tabItem;
    
    [self addChildViewController:nav];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if (viewController == [tabBarController.viewControllers objectAtIndex:1] &&
        self.lastVC != viewController) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RechargeGiftNotiName" object:nil];
        });
    }
    self.lastVC = viewController;
    
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
