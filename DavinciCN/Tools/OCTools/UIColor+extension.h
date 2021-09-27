//
//  UIColor+extension.h
//  Davinci
//
//  Created by Miracle on 2021/6/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (extension)

/**
 * 两个颜色之间的过渡颜色
 * beginColor 开始颜色
 * endColor 结束颜色
 * position 过渡的比例 （0~1）
 */
+ (UIColor *)transitionColorWithStartColor:(UIColor *)startColor endColor:(UIColor *)endColor position:(CGFloat )position;


/**
 * 取两个颜色的过渡颜色
 * startColorHex 开始颜色的 十六进制值
 * endColorHex 结束颜色的 十六进制值
 * position 过渡比例 （0~1）
 */
+ (UIColor *)transitionColorWithStartColorHex:(unsigned int)startColorHex endColorHex:(unsigned int)endColorHex position:(CGFloat )position;

@end

NS_ASSUME_NONNULL_END
