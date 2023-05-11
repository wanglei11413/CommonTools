//
//  UIImage+ChangedColor.m
//  HTFortune
//
//  Created by 王雷 on 16/9/25.
//  Copyright © 2016年 hongtai. All rights reserved.
//

#import "UIImage+ChangedColor.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetImageGenerator.h>
#import <AVFoundation/AVTime.h>

@implementation UIImage (ChangedColor)

- (UIImage *)imageByScalingToSize:(CGSize)targetSize
{
    if([[UIScreen mainScreen] scale] == 3.0) {
        UIGraphicsBeginImageContextWithOptions(targetSize, NO, 3.0);
    } else if ([[UIScreen mainScreen] scale] == 2.0) {
        UIGraphicsBeginImageContextWithOptions(targetSize, NO, 2.0);
    } else {
        UIGraphicsBeginImageContext(targetSize);
    }
    [self drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
    
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

- (UIImage *) imageWithCustomTintColor:(UIColor *)tintColor
{
    return [self imageWithTintColor:tintColor blendMode:kCGBlendModeDestinationIn];
}

- (UIImage *) imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode
{
    //We want to keep alpha, set opaque to NO; Use 0.0f for scale to use the scale factor of the device’s main screen.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    
    //Draw the tinted image in context
    [self drawInRect:bounds blendMode:blendMode alpha:1.0f];
    
    if (blendMode != kCGBlendModeDestinationIn) {
        [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    }
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

+ (instancetype)imageWithOriginalName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

+ (instancetype)imageWithStretchableName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    return [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
}

+ (UIImage *)imageClip:(UIImage *)image borderWidth:(CGFloat)border borderColor:(UIColor *)borderColor {
    CGFloat oriW = image.size.width;
    CGFloat oriH = image.size.height;
    CGFloat ovalWidth = oriW;
    CGFloat ovalHeight = oriH;
    if (border > 0) {
        ovalWidth = oriW + 2 * border;
        ovalHeight = oriH + 2 * border;
    }
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(ovalWidth, ovalHeight), NO, 0);
    UIBezierPath *biggerOval = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, ovalWidth, ovalHeight)]; //绘制大圆
    [borderColor setFill];
    [biggerOval fill];
    
    //set the clip rect
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(border, border, oriW, oriH)];
    [clipPath addClip];
    //draw image
    [image drawAtPoint:CGPointMake(border, border)];
    UIImage *clipImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return clipImage;
}

+ ( UIImage  *)imageWithColor:( UIColor  *)color size:( CGSize )size
{
    
    @autoreleasepool  {
        
        CGRect  rect =  CGRectMake ( 0 ,  0 , size. width , size. height );
        
        UIGraphicsBeginImageContext (rect. size );
        
        CGContextRef  context =  UIGraphicsGetCurrentContext ();
        
        CGContextSetFillColorWithColor (context,
                                        
                                        color. CGColor );
        
        CGContextFillRect (context, rect);
        
        UIImage  *img =  UIGraphicsGetImageFromCurrentImageContext ();
        
        UIGraphicsEndImageContext ();
        
        
        
        return  img;
        
    }
    
}

-(UIImage *)screenImageWithView:(UIView *)view Size:(CGSize )imgSize{
    UIGraphicsBeginImageContextWithOptions(imgSize, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [view.layer renderInContext:context];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (UIImage*) blur:(UIImage*)theImage
{
    // create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
    
    CIFilter *affineClampFilter = [CIFilter filterWithName:@"CIAffineClamp"];
    CGAffineTransform xform = CGAffineTransformMakeScale(1.0, 1.0);
    [affineClampFilter setValue:inputImage forKey:kCIInputImageKey];
    [affineClampFilter setValue:[NSValue valueWithBytes:&xform
                                               objCType:@encode(CGAffineTransform)]
                         forKey:@"inputTransform"];
    
    CIImage *extendedImage = [affineClampFilter valueForKey:kCIOutputImageKey];
    
    // setting up Gaussian Blur (could use one of many filters offered by Core Image)
    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [blurFilter setValue:extendedImage forKey:kCIInputImageKey];
    [blurFilter setValue:[NSNumber numberWithFloat:20.0f] forKey:@"inputRadius"];
    CIImage *result = [blurFilter valueForKey:kCIOutputImageKey];
    
    // CIGaussianBlur has a tendency to shrink the image a little,
    // this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
    //create a UIImage for this function to "return" so that ARC can manage the memory of the blur...
    //ARC can't manage CGImageRefs so we need to release it before this function "returns" and ends.
    CGImageRelease(cgImage);//release CGImageRef because ARC doesn't manage this on its own.
    
    return returnImage;
}

#pragma mark ---- 获取图片第一帧
+ (UIImage *)firstFrameWithVideoURL:(NSURL *)url size:(CGSize)size
{
    // 获取视频第一帧
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:opts];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = CGSizeMake(size.width, size.height);
    NSError *error = nil;
    CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(0, 10) actualTime:NULL error:&error];
    {
        return [UIImage imageWithCGImage:img];
    }
    return nil;
}

- (UIImage *)clipImageInRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *thumbScale = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return thumbScale;
}

- (UIImage *)addWaterText:(NSString *)waterText textPosition:(CGPoint)position textAttributes:(NSDictionary<NSString *,id> *)attributes {
    UIGraphicsBeginImageContext(self.size);
    [self drawAtPoint:CGPointZero];
    [waterText drawAtPoint:position withAttributes:attributes];
    UIImage *waterImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return waterImg;
}

/**
 *  调用该方法处理图像变清晰
 *  根据CIImage生成指定大小的UIImage
 *
 *  @param image CIImage
 *  @param size  图片宽度以及高度
 */
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size
{
    CGRect extent          = CGRectIntegral(image.extent);
    CGFloat scale          = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    //1.创建bitmap;
    size_t width           = CGRectGetWidth(extent) * scale;
    size_t height          = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs     = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context     = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    //2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

@end
