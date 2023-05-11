//
//  UIImage+ChangedColor.h
//  HTFortune
//
//  Created by 王雷 on 16/9/25.
//  Copyright © 2016年 hongtai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ChangedColor)

- (UIImage *) imageWithCustomTintColor:(UIColor *)tintColor;

//不改变图片的透明度，alpha 通道 -- 修改图片的填充颜色
- (UIImage *) imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode;

//改变图片大小
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;


/**
 *  加载最原始的图片，没有渲染
 *
 *  @param imageName 图片名称
 *
 *  @return 图片
 */
+ (instancetype)imageWithOriginalName:(NSString *)imageName;

/**
 *  加载拉伸图片（居中拉伸）
 *
 *  @param imageName 图片名称
 *
 *  @return 图片
 */
+ (instancetype)imageWithStretchableName:(NSString *)imageName;

/**
 * @brief 图片裁剪为带圆环的圆图
 * @param image original image
 * @param border width of the ring. Minimum value is zero
 * @param borderColor color of the ring
 * @return return the clipped image
 */
+ (UIImage *)imageClip:(UIImage *)image borderWidth:(CGFloat)border borderColor:(UIColor *)borderColor;

/**
 * 颜色转图片
 *
 *  @param color 颜色
 *
 *  @return 图片
 */
+ ( UIImage  *)imageWithColor:( UIColor  *)color size:( CGSize )size;

/**
 屏幕截图
 
 @param view view
 @param imgSize 大小
 @return 图片
 */
-(UIImage *)screenImageWithView:(UIView *)view Size:(CGSize )imgSize;

/**
 图片模糊处理
 
 @param theImage 图片
 @return 图片
 */
+ (UIImage*) blur:(UIImage*)theImage;

/**
 获取视频第一帧图片

 @param url url
 @param size 大小
 @return 图片
 */
+ (UIImage *)firstFrameWithVideoURL:(NSURL *)url size:(CGSize)size;

/**
 截取图片指定部分

 @param rect 要截取的部分
 @return 图片
 */
- (UIImage *)clipImageInRect:(CGRect)rect;

/**
 * @brief 添加水印文字
 * @param waterText 待添加的水印文字
 * @param position 水印文字位置
 * @param attributes 水印文字属性字典
 * @return return a new image with water text
 */
- (UIImage *)addWaterText:(NSString *)waterText textPosition:(CGPoint)position textAttributes:(NSDictionary <NSString *, id> * )attributes;

/**
 *  调用该方法处理图像变清晰
 *  根据CIImage生成指定大小的UIImage
 *
 *  @param image CIImage
 *  @param size  图片宽度以及高度
 */
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size;

@end
