//
//  UIView+Autolayout.h
//  YWAlertViewDemo
//
//  Created by yaowei on 2018/8/27.
//  Copyright © 2018年 yaowei. All rights reserved.
//

#import <UIKit/UIKit.h>

//相关配置
#define DefaultTranslucenceColor            [UIColor colorWithRed:1 green:1 blue:1 alpha:1]
#define DefaultLineTranslucenceColor        [UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1]
#define WLAlertTextCommonColor              [UIColor colorWithRed:0/255.0 green:134/255.0 blue:117/255.0 alpha:1]
#define WLAlertTextDarkColor                [UIColor colorWithRed:0 green:0 blue:0 alpha:1]
#define WLAlertBtnHeight                    44.0
#define WLAlertTextFontMax                  [UIFont systemFontOfSize:18.0]
#define WLAlertTextFontMid                  [UIFont systemFontOfSize:14.0]

@interface UIView (Autolayout)

-(void)addConstraint:(NSLayoutAttribute)attribute equalTo:(UIView *)to offset:(CGFloat)offset;

-(NSLayoutConstraint *)addConstraintAndReturn:(NSLayoutAttribute)attribute equalTo:(UIView *)to toAttribute:(NSLayoutAttribute)toAttribute offset:(CGFloat)offset;

-(void)addConstraint:(NSLayoutAttribute)attribute equalTo:(UIView *)to toAttribute:(NSLayoutAttribute)toAttribute offset:(CGFloat)offset;

- (void)removeAllAutoLayout;

- (void)removeAutoLayout:(NSLayoutConstraint *)constraint;

- (NSLayoutConstraint *)getAutoLayoutByIdentifier:(NSString *)identifier;

@end
