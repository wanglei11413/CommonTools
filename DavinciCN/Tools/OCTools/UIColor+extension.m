//
//  UIColor+extension.m
//  Davinci
//
//  Created by Miracle on 2021/6/26.
//

#import "UIColor+extension.h"

@implementation UIColor (extension)

+ (UIColor *)colorWithHexColor:(unsigned int)hexColor {
   return [UIColor colorWithRed:((hexColor>>16)&0xFF)/255.0 green:((hexColor>>8)&0xFF)/255.0 blue:(hexColor&0xFF)/255.0 alpha:1.0];
}


/**
 * 两个颜色之间的过渡颜色
 * beginColor 开始颜色
 * endColor 结束颜色
 * position 过渡的比例 （0~1）
 */
+ (UIColor *)transitionColorWithStartColor:(UIColor *)startColor endColor:(UIColor *)endColor position:(CGFloat )position {
    UIColor *desColor = nil;
    // 获取开始位置颜色的 R、G、B、A值
    CGFloat startR = 0;
    CGFloat startG = 0;
    CGFloat startB = 0;
    CGFloat startA = 0;
    [startColor getRed:&startR green:&startG blue:&startB alpha:&startA];

    // 获取结束位置颜色的 R、G、B、A值
    CGFloat endR = 0;
    CGFloat endG = 0;
    CGFloat endB = 0;
    CGFloat endA = 0;
    [endColor getRed:&endR green:&endG blue:&endB alpha:&endA];
    
    CGFloat R = (endR - startR)*position + startR;
    CGFloat G = (endG - startG)*position + startG;
    CGFloat B = (endB - startB)*position + startB;
    CGFloat A = (endA - startA)*position + startA;
    
    //根据当前位置获取当前应该要展示的颜色值
    desColor = [UIColor colorWithRed:R green:G blue:B alpha:A];
    
    return desColor;
}


/**
 * 取两个颜色的过渡颜色
 * startColorHex 开始颜色的 十六进制值
 * endColorHex 结束颜色的 十六进制值
 * position 过渡比例 （0~1）
 */
+ (UIColor *)transitionColorWithStartColorHex:(unsigned int)startColorHex endColorHex:(unsigned int)endColorHex position:(CGFloat )position {
    return [self transitionColorWithStartColor:[self colorWithHexColor:startColorHex] endColor:[self colorWithHexColor:endColorHex] position:position];
    
    
}

@end
