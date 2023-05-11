//
//  BasicViewController.h
//  qianQianJiaDao
//
//  Created by Monster on 2017/12/29.
//  Copyright © 2017年 huiYanKeJi. All rights reserved.
//

//所有viewController均继承该viewController
#import <UIKit/UIKit.h>
#import "UIViewController+RTRootNavigationController.h"

#define weak_self(var) __weak typeof(var) weakSelf = var

@interface BasicViewController : UIViewController

/**
 导航栏文字颜色
 */
@property (nonatomic, strong) UIColor *navTextColor;

/**
 是否不允许透明效果
 */
@property (nonatomic, assign) BOOL navUnTranslucent;

/**
 隐藏底部细线
 */
@property (nonatomic, assign) BOOL navShadowImageHidden;

/**
 导航栏背景颜色
 */
@property (nonatomic, strong) UIColor *navBackgroundColor;

/**
 导航栏渲染风格
 */
@property (nonatomic, assign) UIBarStyle navBarStyle;

/**
 导航栏图标渲染颜色
 */
@property (nonatomic, strong) UIColor *navTintColor;

/**
 是否为浅色状态栏
 */
@property (nonatomic, assign) BOOL statusBarIsLight;

@end
