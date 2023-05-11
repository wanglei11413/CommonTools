//
//  MyDiyEmptyView.h
//  YiCaiTong
//
//  Created by wang on 2018/9/19.
//  Copyright © 2018年 wang. All rights reserved.
//

#import "LYEmptyView.h"
#import "LYEmptyViewHeader.h"

/**
 自定义的表格无数据占位图
 */
@interface MyDiyEmptyView : LYEmptyView

/**
 展示无数据无点击事件的占位图

 @return 占位图
 */
+ (instancetype)diyNoDataEmpty;

/**
 展示无数据无点击事件的占位图
 
 @return 占位图
 */
+ (instancetype)diyNoDataEmptyWithBanner;

/**
 展示无网络连接时的占位图

 @param target 事件响应
 @param action 方法名称
 @return 占位图
 */
+ (instancetype)diyNoNetworkEmptyWithTarget:(id)target action:(SEL)action;

/**
 展示无网络连接时的占位图
 @prram margin 距离上边距
 @param target 事件响应
 @param action 方法名称
 @return 占位图
 */
+ (instancetype)diyNoNetworkEmptyWithMargin:(CGFloat)margin Target:(id)target action:(SEL)action;

@end
