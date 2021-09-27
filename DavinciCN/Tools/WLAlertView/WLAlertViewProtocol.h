//
//  WLAlertViewProtocol.h
//  WLAlertViewDemo
//
//  Created by yaowei on 2018/8/28.
//  Copyright © 2018年 yaowei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class WLResultModel;

@protocol WLAlertViewThemeProtocol <NSObject>

@optional

/**
 alert背景图
 
 @return im
 */
- (nullable UIImage *)alertBackgroundView;

/**
 alert背景图的清晰度

 @return 0~1(越小越清晰)
 */
- (CGFloat)alterBackgroundViewArticulation;

/**
 alert的背景颜色

 @return color
 */
- (nullable UIColor *)alertBackgroundColor;

/**
 titleView的颜色
 
 @return color
 */
- (nullable UIColor *)alertTitleViewColor;

/**
 取消按钮的颜色
 
 @return color
 */
- (nullable UIColor *)alertCancelColor;

/**
 修改title的字体

 @return string
 */
- (nullable NSString *)alertTitleFontWithName;

/**
 修改title的字号大小
 
 @return string
 */
- (CGFloat )alertTitleFont;

/**
 修改Message的字体
 
 @return string
 */
- (nullable NSString *)alertMessageFontWithName;

/**
 修改Message的字号大小
 
 @return string
 */
- (CGFloat )alertMessageFont;

@end

//MARK: --------- WLAlertViewProtocol(基本接口协议)
@protocol WLAlertViewProtocol <NSObject>

@optional
/**
 默认显示在Windows上
 */
- (void)show;
/**
 隐藏弹框
 */
- (void)hiddenAlertView;
//config配置信息
@optional
/**
 隐藏bodyview上下的两个分隔线
 */
- (void)hiddenBodyLineView;
/**
 隐藏所有的分隔线
 */
- (void)hiddenAllLineView;

/**
 设置整个弹框的背景颜色

 @param color 颜色
 */
- (void)setAlertViewBackgroundColor:(nullable UIColor *)color;
/**
 设置titleView的背景颜色

 @param color 颜色
 */
- (void)setTitleViewBackColor:(nullable UIColor *)color;
/**
 设置titleView的title颜色

 @param color 颜色
 */
- (void)setTitleViewTitleColor:(nullable UIColor *)color;
/**
 设置message的字体颜色

 @param color 颜色
 */
- (void)setMessageTitleColor:(nullable UIColor *)color;
/**
 设置所有按钮的字体颜色

 @param color 颜色
 */
- (void)setAllButtionTitleColor:(nullable UIColor *)color;
/**
 设置单个按钮的颜色

 @param color 颜色
 @param index 下标
 */
- (void)setButtionTitleColor:(nullable UIColor *)color index:(NSInteger)index;
/**
 设置单个按钮的字体以及其大小

 @param name 什么字体
 @param size 大小
 @param index 小标
 */
- (void)setButtionTitleFontWithName:(nullable NSString *)name size:(CGFloat)size index:(NSInteger)index;
/**
 设置title的字体以及其大小

 @param name 什么字体(为nil时,即是系统字体)
 @param size 大小
 */
- (void)setTitleFontWithName:(nullable NSString *)name size:(CGFloat)size;
/**
 设置message的字体以及其大小
 
 @param name 什么字体(为nil时,即是系统字体)
 @param size 大小
 */
- (void)setMessageFontWithName:(nullable NSString *)name size:(CGFloat)size;
/**
 设置蒙版的背景图

 @param image 蒙版的背景图（可使用高斯的image）
 */
- (void)setGaussianBlurImage:(nullable UIImage *)image;
/**
 统一配置信息

 @param theme 主题
 */
- (void)setTheme:(nullable id<WLAlertViewThemeProtocol>)theme;

/**
 修改tiele
 
 @param title 提示名称
 */
- (void)resetAlertTitle:(nullable NSString *)title;

@end

//MARK: ------------------ alert 私有的方法 ------------------
@protocol WLAlertAlertViewProtocol <WLAlertViewProtocol>
/**
 alert背景图(目前对WLAlert有效)
 
 @param image image
 @param articulation 0~1(越小越清晰)
 */
- (void)setAlertBackgroundView:(nullable UIImage *)image articulation:(CGFloat)articulation;
/**
 自定义bodyview
 
 @param bodyView 需要定义的view
 @param height 该view的高度
 */
- (void)setCustomBodyView:(nullable UIView *)bodyView height:(CGFloat)height;

/**
 修改message信息，高度也会跟着适配

 @param message 信息
 */
- (void)resetAlertMessage:(nullable NSString *)message;

@end



