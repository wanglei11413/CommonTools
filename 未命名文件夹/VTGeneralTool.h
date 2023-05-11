//
//  VTGeneralTool.h
//  SZDT_Partents
//
//  Created by szdt on 15/3/23.
//  Copyright (c) 2015年 szdt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AudioToolbox/AudioToolbox.h>

typedef void(^sureBlock)(void);

/**
 block回调
 
 @param currentVersion 当前版本号
 @param storeVersion 商店版本号
 @param openUrl 跳转到商店的地址
 @param isUpdate 是否为最新版本
 */
typedef void(^UpdateBlock)(NSString *currentVersion,NSString *storeVersion, NSString *openUrl,BOOL isUpdate);

/**
 清除缓存回调
 */
typedef void(^ClearCachesBlock)(void);

/**
 点击键盘上方完成按钮回调
 */
typedef void(^TextFieldDoneBlock)(void);




@interface VTGeneralTool : NSObject

+ (NSString *)stringFromeVideo:(NSString *)mp4Path;

//检查身份证号
+ (BOOL)validateIDCardNumber:(NSString *)value ;

+ (CGSize)boundingRectWithSize:(CGSize)size  font:(CGFloat)font text:(NSString *)text;

//16进制颜色
+ (UIColor *)colorWithHex:(NSString *)hexColor;

//随机颜色
+ (UIColor *)randomColor;

+ (UIImage *)imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth;

//获取当前手机型号
+ (NSString *)getCurrentDevice;

+ (NSString*)base64forData:(NSData*)theData;

/**
 *  各种字符串判断
 */
//是否为数字和字母结合
+ (Boolean)isNumberCharaterString:(NSString *)str;
//是否为字符集合
+ (Boolean)isCharaterString:(NSString *)str;
//是否为数字集合
+ (Boolean)isNumberString:(NSString *)str;
/// 是否为符号合集
+ (Boolean)isSymbolString:(NSString *)str;
//是否含有非法字符
+ (Boolean)hasillegalString:(NSString *)str;
//是否为纯数字验证码
+ (Boolean)isValidSmsString:(NSString *)str;
//是否为email
+ (BOOL)verifyEmail:(NSString*)email;
+ (NSString *)getTimeString:(NSInteger)duration; //通过时长获取时分秒的字符串
+ (NSString *)cleanPhone:(NSString *)beforeClean;

/**
 *  检查非法字符和中文
 */
+ (BOOL)checkNoChar:(NSString *)str;

/**
 *  检查电话号码合法性
 */
+ (BOOL)checkPhoneNumInput:(NSString *)phoneNumber;

/**
 检查字符串是否为空
 */
+ (BOOL) isBlankString:(NSString *)string;

/**
 *  根据dict返回data
 */
+ (NSData*)returnDataWithDictionary:(NSDictionary*)dict;

/**
 *  根据输入的日期 返回周几的字符串
 */
+ (NSString*)weekdayStringFromDate:(NSDate*)inputDate;

/**
 获取当前日期
 */
+ (NSString *)getDate;

/**
 *  获取当前周的日期数组
 */
+ (NSArray *)getCurrentWeekDay:(NSDate *)date;


/**
 得到documents或者caches目录
 */
+ (NSString *)getCacheFilePathWithDirectory:(NSSearchPathDirectory)directory atPath:(NSString *)path;

/**
 判断是否存在该文件 不存在那么创建
 */
+ (void)judgeFileExistsAtPath:(NSString *)path;

/**
 *  计算当前路径下文件大小
 */
+ (float)fileSizeAtPath:(NSString *)path;

/**
 *  当前路径文件夹的大小
 */
+ (float)folderSizeAtPath:(NSString *)path;

/**
 *  清除文件
 */
+ (void)clearCache:(NSString *)path compelteBlock:(ClearCachesBlock)completeBlock;

/**
 * 修改图片大小
 */
+ (UIImage *) imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize) newSize;

/**
 * 保存图片
 */
+ (NSString *)saveImage:(UIImage *)tempImage WithName:(NSString *)imageName;

/**
 * 生成GUID
 */
+ (NSString *)generateUuidString;

/**
 * 检查系统"照片"授权状态, 如果权限被关闭, 提示用户去隐私设置中打开.
 */
+ (BOOL)checkPhotoLibraryAuthorizationStatus;

/**
 * 检查系统"相机"授权状态, 如果权限被关闭, 提示用户去隐私设置中打开.
 */
+ (BOOL)checkCameraAuthorizationStatus;

/**
 *  百度转火星坐标
 */
+ (CLLocationCoordinate2D )bdToGGEncrypt:(CLLocationCoordinate2D)coord;

/**
 *  火星转百度坐标
 */
+ (CLLocationCoordinate2D )ggToBDEncrypt:(CLLocationCoordinate2D)coord;

+(NSString  *)displayDataStyleWithNumber:(NSString *)timeNumber;

//播放声音 注意不能循环 只能播放一次 无法停止
+(void)playsound:(NSString *)soundname;
//使手机振动
+ (void)vibrate;
//判断是否是iPhone x
+ (BOOL)isIphoneX;
//获取当前界面控制器
+ (UIViewController *)getCurrentVC;

/**
 清除缓存
 */
+ (void)clearAppCacheCompelteBlock:(ClearCachesBlock)completeBlock;


/**
 生成系统样式的alert 按钮为 取消 和 确定

 @param title 标题
 @param subTitle 文字
 @param sureBlock 确定按钮
 */
+ (void)showAlertSystemWithTitle:(NSString *)title subTitle:(NSString *)subTitle sureBlock:(sureBlock)sureBlock;


/**
 生成系统样式的alert

 @param title 标题
 @param subTitle 自镖旗
 @param cancel 取消按钮
 @param sure 确认按钮
 @param sureBlock 确定block
 */
+ (void)showAlertSystemWithTitle:(NSString *)title subTitle:(NSString *)subTitle cancel:(NSString *)cancel sure:(NSString *)sure sureBlock:(sureBlock)sureBlock;



/**
 指定高度和字体，计算文本宽度

 @param title 文字
 @param fontSize 字体
 @param height 高度
 @return 宽度
 */
+ (CGFloat)countStringWidthTitle:(NSString *)title fontSize:(CGFloat)fontSize height:(CGFloat)height;

/**
 指定宽度和字体，计算文本高度
 
 @param title 文字
 @param fontSize 字体
 @param width 宽度
 @return 高度
 */
+ (CGFloat)countStringHeightTitle:(NSString *)title fontSize:(CGFloat)fontSize width:(CGFloat)width;

/**
 一行代码实现检测app是否为最新版本。appId，bundelId，随便传一个 或者都传nil 即可实现检测。
 
 @param appId    项目APPID，10位数字，有值默认为APPID检测，可传nil
 @param bundelId 项目bundelId，有值默认为bundelId检测，可传nil
 @param block    检测结果block回调
 */
+ (void)judgeAppVersionWithAPPID:(NSString *)appId withBundleId:(NSString *)bundelId block:(UpdateBlock)block;

/**
 获取设备唯一标识

 @return 设备的UUID
 */
+ (NSString *)getUUID;

+ (BOOL)checkHaveEmoji:(NSString *)string;

//判断第三方键盘中的表情
+ (BOOL)hasEmoji:(NSString*)string;

/**
 校验密码格式
 英文与数字结合 6-18位
 @param password 密码
 @return 是否合格
 */
+ (BOOL)checkPassword:(NSString *)password;

/**
 银行卡校验

 @param cardNum 银行卡号码
 @return 结果
 */
+ (BOOL)isBankCardNumber:(NSString *)cardNum;

/**
 为textField添加完成按钮
 
 @return toolBar
 */
+ (UIToolbar *)textFieldToolBarDone:(TextFieldDoneBlock)doneBlock;

/// 不四舍五入保留小数
/// @param price 价格
/// @param position 小数点后几位
+ (NSString *)notRounding:(double)price afterPoint:(int)position;

/**
 创建带logo的二维码

 @param url 二维码地址
 @param size 大小
 @param logoImageName logo
 @return 二维码
 */
+ (UIImage *)creatQRCodeWithUrl:(NSString *)url size:(CGFloat)size logoImageName:(NSString *)logoImageName;

/// 将大写转为小写
/// @param str 要转化的目标
+ (NSString *)stringToLower:(NSString *)str;


/// 展示自定义的弹窗alert
+ (void)showCustomerAlertWithTitle:(NSString *)title;

// 状态栏+导航栏的高度
+ (CGFloat)navFullHeight;

@end
