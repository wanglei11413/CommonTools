//
//  YWAlertView.h
//  YWAlertViewDemo
//
//  Created by yaowei on 2018/8/28.
//  Copyright © 2018年 yaowei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLAlertViewProtocol.h"
#import "UIView+Autolayout.h"

@interface WLAlertView : UIView <WLAlertViewProtocol>

/// 弹窗
/// @param isLand 是否为横屏
/// @param image 图片
/// @param title 标题（文字或者富文本），如果为富文本，那么message不生效
/// @param message 详情
/// @param cancelButtonTitle 取消按钮
/// @param otherButtonTitles 其余按钮
/// @param handler 回调
- (nullable id<WLAlertViewProtocol>)alertViewWithIsLand:(BOOL)isLand
                                                  image:(nullable UIImage *)image
                                                 title:(nullable id)title
                                              message:(nullable NSString *)message
                                    cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                                    otherButtonTitles:(nullable NSArray *)otherButtonTitles
                                              handler:(nullable void(^)(NSInteger buttonIndex,id _Nullable value))handler;

@end
