//
//  VTGeneralTool.m
//  SZDT_Partents
//
//  Created by szdt on 15/3/23.
//  Copyright (c) 2015年 szdt. All rights reserved.
//

#import "VTGeneralTool.h"
#import <AVFoundation/AVFoundation.h>
#import <sys/utsname.h>
#import "KeychainItemWrapper.h"
#import "UIBarButtonItem+ClickBlock.h"

#import "RootTabbarViewController.h"
#import "UIImage+ChangedColor.h"
#import "WLAlertView.h"

static NSString * const FORM_FLE_INPUT = @"file";

@interface VTGeneralTool ()<UIAlertViewDelegate, WLAlertViewProtocol>

@end


@implementation VTGeneralTool

+ (NSString *)stringFromeVideo:(NSString *)mp4Path
{
    NSData *videoData = [NSData dataWithContentsOfFile:mp4Path];
    NSString *pictureDataString=[videoData
                                 base64EncodedStringWithOptions:(NSDataBase64Encoding64CharacterLineLength)];
//    NSString *unicodeStr = [NSString stringWithCString:[pictureDataString UTF8String] encoding:NSUTF8StringEncoding];
    NSString *last = [pictureDataString stringByReplacingOccurrencesOfString: @"\r" withString:@""];
    NSString *last2 =  [last stringByReplacingOccurrencesOfString: @"\n" withString:@""];
    return last2;
}

+ (BOOL)simpleVerifyIdentityCardNum
{
    NSString *regex2 = @"^(\\\\d{14}|\\\\d{17})(\\\\d|[xX])$";
    return [self isValidateByRegex:regex2];
}

+ (BOOL)isValidateByRegex:(NSString *)regex {
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pre evaluateWithObject:self];
}

+ (BOOL)validateIDCardNumber:(NSString *)identityCard
{
    
    BOOL flag;
    if (identityCard.length <= 0)
    {
        flag = NO;
        return flag;
    }
    
    NSString *regex2 = @"^(^[1-9]\\d{7}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}$)|(^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])((\\d{4})|\\d{3}[Xx])$)$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    flag = [identityCardPredicate evaluateWithObject:identityCard];
    
    
    //如果通过该验证，说明身份证格式正确，但准确性还需计算
    if(flag)
    {
        if(identityCard.length==18)
        {
            //将前17位加权因子保存在数组里
            NSArray * idCardWiArray = @[@"7", @"9", @"10", @"5", @"8", @"4", @"2", @"1", @"6", @"3", @"7", @"9", @"10", @"5", @"8", @"4", @"2"];
            
            //这是除以11后，可能产生的11位余数、验证码，也保存成数组
            NSArray * idCardYArray = @[@"1", @"0", @"10", @"9", @"8", @"7", @"6", @"5", @"4", @"3", @"2"];
            
            //用来保存前17位各自乖以加权因子后的总和
            
            NSInteger idCardWiSum = 0;
            for(int i = 0;i < 17;i++)
            {
                NSInteger subStrIndex = [[identityCard substringWithRange:NSMakeRange(i, 1)] integerValue];
                NSInteger idCardWiIndex = [[idCardWiArray objectAtIndex:i] integerValue];
                
                idCardWiSum+= subStrIndex * idCardWiIndex;
                
            }
            
            //计算出校验码所在数组的位置
            NSInteger idCardMod=idCardWiSum%11;
            
            //得到最后一位身份证号码
            NSString * idCardLast= [identityCard substringWithRange:NSMakeRange(17, 1)];
            
            //如果等于2，则说明校验码是10，身份证号码最后一位应该是X
            if(idCardMod==2)
            {
                if([idCardLast isEqualToString:@"X"]||[idCardLast isEqualToString:@"x"])
                {
                    return flag;
                }else
                {
                    flag =  NO;
                    return flag;
                }
            }else
            {
                //用计算出的验证码与最后一位身份证号码匹配，如果一致，说明通过，否则是无效的身份证号码
                if([idCardLast isEqualToString: [idCardYArray objectAtIndex:idCardMod]])
                {
                    return flag;
                }
                else
                {
                    flag =  NO;
                    return flag;
                }
            }
        }
        else
        {
            flag =  NO;
            return flag;
        }
    }
    else
    {
        return flag;
    }
    
}



+(NSString  *)displayDataStyleWithNumber:(NSString *)timeNumber
{
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSDate *date1 = [NSDate dateWithTimeIntervalSince1970:[timeNumber longLongValue]/1000];
   // NSLog(@"**** == %ld",(long)[timeNumber integerValue]);
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"];
    NSString *dateSMS = [dateFormatter stringFromDate:date1];
//    NSLog(@"给的时间date****%@",dateSMS);
    
    
    NSDate *now = [NSDate date];
    NSString *dateNow = [dateFormatter stringFromDate:now];
    //当前的时间转为时间戳
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[now timeIntervalSince1970]];
    //计算当前的时间戳和给定得时间戳的差值
    long long int interval = ([timeSp longLongValue] - [timeNumber longLongValue]/1000);
    
    //判断是不是今天
    if ([dateSMS isEqualToString:dateNow]) {
        [dateFormatter setDateFormat:@"HH:mm:ss"];
        if (interval < 60) {
            //秒
            return @"刚刚";
        }else if (interval < 60 * 60){
            //分钟
            return [NSString stringWithFormat:@"%ld分钟前", (NSInteger)interval/60];
        }else  {
            //小时
            return [NSString stringWithFormat:@"%ld小时前", (NSInteger)interval/(60 * 60)];
        }
    }else {
        //不是今天的情况
        //判断是不是昨天
        //条件就是取两天的差值
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"yyyy-MMM-dd";
        //只要年月日
        NSString *dateString = [formatter stringFromDate:date1];
        NSString *nowString = [formatter stringFromDate:[NSDate date]];
        
        //年-月-日
        NSDate *date = [formatter dateFromString:dateString];
        NSDate *now1 = [formatter dateFromString:nowString];
        //取两天之间的差值
        NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
        NSDateComponents *component = [calendar components:unit fromDate:date toDate:now1 options:0];
        if (component.year == 0 && component.month == 0 && component.day ==1) {
            
            [dateFormatter setDateFormat:@"HH:mm:ss"];
            NSString *dateSMS = [dateFormatter stringFromDate:date1];
            NSString *date = [dateSMS substringWithRange:NSMakeRange(0, 5)];
            return  [NSString stringWithFormat:@"昨天 %@", date];
            
        }else{
            
            //  出来今天和昨天剩下两种情况  要么是本周之内 要么是超过了一周
            //  判断是不是本周之内
            //  这里得到的日期是星期的开始日期
            //  下面的到本周的开始日期
            NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian] ;
            [gregorian setFirstWeekday:2]; //monday is first day
            NSDate *now = [NSDate date];
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:now];
            NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
            [componentsToSubtract setDay: - ((([components weekday] - [gregorian firstWeekday])+ 7 ) % 7)];
            NSDate *beginningOfWeek = [gregorian dateByAddingComponents:componentsToSubtract toDate:now options:0];
            NSDateComponents *componentsStripped = [gregorian components: (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)fromDate: beginningOfWeek];
            NSDateFormatter *hahaformatter1 = [[NSDateFormatter alloc] init];
            // [hahaformatter1 setDateFormat:@"yyyy-MM-dd EEEE HH:mm:ss"];
            [hahaformatter1 setDateFormat:@"EEEE"];
            hahaformatter1.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"];
            //这里得到的日期是星期的开始日期  //得到星期的第一天的信息
            beginningOfWeek = [gregorian dateFromComponents: componentsStripped];
            
            NSString *begintimeSp = [NSString stringWithFormat:@"%ld", (long)[beginningOfWeek timeIntervalSince1970]];
            NSString *judgetimeSp1 = [NSString stringWithFormat:@"%ld", (long)[date1 timeIntervalSince1970]];
            
            //比较这周开始的一天的日期和即将判定的也就是给定的日期的先后
            //date1是给定的即将判定的某一天
            if ([begintimeSp intValue]>[judgetimeSp1 intValue]) {
             //   NSLog(@"直接显示年月日");
                //超过了一周 不是本周内  在本周之前
                //这里超过了一周
                [dateFormatter setDateFormat:@"YYYY-MM-dd"];
                NSString *dateSMS = [dateFormatter stringFromDate:date1];
                NSString *dateStr = [NSString stringWithFormat:@"%@",dateSMS];
                return dateStr;
            }else{
                //是本周则直接显示的星期
                [dateFormatter setDateFormat:@"EEEE"];
                NSString *dateSMS = [dateFormatter stringFromDate:date1];
                NSString *dateStr = [NSString stringWithFormat:@"%@",dateSMS];
                if ([dateStr isEqualToString:@"Monday"]) {
                    return @"星期一";
                }else if ([dateStr isEqualToString:@"Tuesday"]){
                    return @"星期二";
                }else if ([dateStr isEqualToString:@"Wednesday"]){
                    return @"星期三";
                }else if ([dateStr isEqualToString:@"Thursday"]){
                    return @"星期四";
                }else if ([dateStr isEqualToString:@"Friday"]){
                    return @"星期五";
                }
                return dateStr;
            }
            
        }
        
    }
    
}

+ (CGSize)boundingRectWithSize:(CGSize)size  font:(CGFloat)font text:(NSString *)text
{
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:font]};
    
    CGSize retSize = [text boundingRectWithSize:size
                                        options:\
                      NSStringDrawingTruncatesLastVisibleLine |
                      NSStringDrawingUsesLineFragmentOrigin |
                      NSStringDrawingUsesFontLeading
                                     attributes:attribute
                                        context:nil].size;
    
    return retSize;
}


+ (UIColor *)colorWithHex:(NSString *)hexColor
{
    
    if (hexColor == nil) {
        return nil;
    }
    if ([hexColor length] < 7 ) {
        return nil;
    }
    
    unsigned int red, green, blue;
    NSRange range;
    range.length = 2;
    
    range.location = 1;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
    range.location = 3;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
    range.location = 5;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
    
    return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green/255.0f) blue:(float)(blue/255.0f) alpha:1.0f];
    
}

//随机颜色
+ (UIColor *)randomColor{
    CGFloat r = arc4random_uniform(256)/255.0;
    CGFloat g = arc4random_uniform(256)/255.0;
    CGFloat b = arc4random_uniform(256)/255.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

+(BOOL)verifyEmail:(NSString*)email
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[A-Za-z0-9._%+-]+@[A-Za-z0-9._%+-]+\\.[A-Za-z0-9._%+-]+$" options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSInteger numberOfMatches = [regex numberOfMatchesInString:email options:0 range:NSMakeRange(0, [email length])];
    if (numberOfMatches != 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (NSString *)getTimeString:(NSInteger)duration
{
    
    NSInteger hour = 0;
    NSInteger minute = 0;
    NSInteger second = 0;
    
    hour = duration / 3600;
    minute = duration % 3600 / 60;
    second = duration % 3600 % 60;
    
    NSString *dateStr = nil;
    
    if ( hour > 0 )
    {
        dateStr = [NSString stringWithFormat:@"%02d小时%02d分%02d秒", (int)hour, (int)minute, (int)second];
    }
    else if ( minute > 0 )
    {
        dateStr = [NSString stringWithFormat:@"%02d分%02d秒", (int)minute, (int)second];
    }
    else
    {
        dateStr = [NSString stringWithFormat:@"%02d秒", (int)second];
    }
    
    return dateStr;
}

+ (NSString *)cleanPhone:(NSString *)beforeClean
{
    if ([beforeClean hasPrefix:@"+86"])
    {
        return [beforeClean substringFromIndex:3];
    }
    else if ([beforeClean hasPrefix:@"0086"])
    {
        return [beforeClean substringFromIndex:4];
    }
    else
        return beforeClean;
}


+ (NSString*)base64forData:(NSData*)theData {
    
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i,i2;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        for (i2=0; i2<3; i2++) {
            value <<= 8;
            if (i+i2 < length) {
                value |= (0xFF & input[i+i2]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

+ (UIImage *) imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = height / (width / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if(CGSizeEqualToSize(imageSize, size) == NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(size);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    
    UIGraphicsEndImageContext();
    return newImage;
}

+ (Boolean)isNumberCharaterString:(NSString *)str
{
    NSCharacterSet *disallowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789QWERTYUIOPLKJHGFDSAZXCVBNMqwertyuioplkjhgfdsazxcvbnm"] invertedSet];
    NSRange foundRange = [str rangeOfCharacterFromSet:disallowedCharacters];
    if (foundRange.location == NSNotFound) {
        NSLog(@"是数字和字母的集合");
        return YES;
    }
    return NO;
}

+ (BOOL) isBlankString:(NSString *)string
{
    
    if (string == nil || string == NULL) {
        
        return YES;
        
    }
    
    if ([string isKindOfClass:[NSNull class]]) {
        
        return YES;
        
    }
    
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        
        return YES;
        
    }
    
    return NO;
    
}

+ (Boolean)isCharaterString:(NSString *)str
{
    NSCharacterSet *disallowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"QWERTYUIOPLKJHGFDSAZXCVBNMqwertyuioplkjhgfdsazxcvbnm"] invertedSet];
    NSRange foundRange = [str rangeOfCharacterFromSet:disallowedCharacters];
    if (foundRange.location == NSNotFound) {
//        DLog(@"字母的集合");
        return YES;
    }
    return NO;
}

+ (Boolean)isNumberString:(NSString *)str
{
    NSCharacterSet *disallowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    NSRange foundRange = [str rangeOfCharacterFromSet:disallowedCharacters];
    if (foundRange.location == NSNotFound) {
//        DLog(@"是数字集合");
        return YES;
    }
    return NO;
}

+ (Boolean)isSymbolString:(NSString *)str
{
    NSCharacterSet *disallowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"~!@#$%^*()_+{}:\"?`[];'./,-="] invertedSet];
    NSRange foundRange = [str rangeOfCharacterFromSet:disallowedCharacters];
    if (foundRange.location == NSNotFound) {
//        DLog(@"是符号集合");
        return YES;
    }
    return NO;
}

+ (Boolean)hasillegalString:(NSString *)str
{
    if ( str.length == 0 )  //目前允许是空
    {
        return NO;
    }
    
    NSCharacterSet *disallowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"/／!！@@#＃$￥%^……&&*＊(（)）——_++|“”:：｛{}｝《<>》?？~～、-；;"] invertedSet];
    NSRange foundRange = [str rangeOfCharacterFromSet:disallowedCharacters];
    
    NSLog( @"%@", str );
    
    if (foundRange.location == NSNotFound)
    {
        NSLog(@"含有非法字符");
        return YES;
    }
    
    return NO;
}

+ (Boolean)isValidSmsString:(NSString *)str
{
    NSCharacterSet *disallowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789+"] invertedSet];
    NSRange foundRange = [str rangeOfCharacterFromSet:disallowedCharacters];
    if (foundRange.location == NSNotFound) {
        NSLog(@"是数字集合");
        return YES;
    }
    return NO;
}

+ (UIImage *)createImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

+ (BOOL)checkNoChar:(NSString *)str
{
    NSInteger alength = [str length];
    for (int i = 0; i<alength; i++)
    {
        char commitChar = [str characterAtIndex:i];
        NSString *temp = [str substringWithRange:NSMakeRange(i,1)];
        const char *u8Temp = [temp UTF8String];
        if (3==strlen(u8Temp)){
            NSLog(@"字符串中含有中文");
            return YES;
        }else if((commitChar>64)&&(commitChar<91)){
            NSLog(@"字符串中含有大写英文字母");
        }else if((commitChar>96)&&(commitChar<123)){
            NSLog(@"字符串中含有小写英文字母");
        }else if((commitChar>47)&&(commitChar<58)){
            NSLog(@"字符串中含有数字");
        }else{
            NSLog(@"不含有非法字符");
            return NO;
        }
    }
    return NO;
}

+ (BOOL)checkPhoneNumInput:(NSString *)phoneNumber
{
    //检查电话号码
    if (phoneNumber.length != 11)
    {
        return NO;
    }
//    //内部账号为999开头
//    NSString *str = [phoneNumber substringToIndex:3];
//    if ([str isEqualToString:@"999"]) {
//        return YES;
//    }
    
//    /**
//     * 手机号码:
//     * 13[0-9], 14[5,7], 15[0, 1, 2, 3, 5, 6, 7, 8, 9], 17[6, 7, 8], 18[0-9], 170[0-9]
//     * 移动号段: 134,135,136,137,138,139,150,151,152,157,158,159,182,183,184,187,188,147,178,1705
//     * 联通号段: 130,131,132,155,156,185,186,145,176,1709
//     * 电信号段: 133,153,180,181,189,177,1700
//     */
//    NSString *MOBILE = @"^1(3[0-9]|4[57]|5[0-35-9]|8[0-9]|7[0678])\\d{8}$";
//    /**
//     * 中国移动：China Mobile
//     * 134,135,136,137,138,139,150,151,152,157,158,159,182,183,184,187,188,147,178,1705,198
//     */
//    NSString *CM = @"(^1(3[4-9]|4[7]|5[0-27-9]|7[8]|8[2-478]|9[8])\\d{8}$)|(^1705\\d{7}$)";
//    /**
//     * 中国联通：China Unicom
//     * 130,131,132,155,156,185,186,145,176,1709,166
//     */
//    NSString *CU = @"(^1(3[0-2]|4[5]|5[56]|7[56]|8[56]|6[6])\\d{8}$)|(^1709\\d{7}$)";
//    /**
//     * 中国电信：China Telecom
//     * 133,153,180,181,189,177,1700,199
//     */
//    NSString *CT = @"(^1(33|53|77|8[019]|9[9]|73)\\d{8}$)|(^1700\\d{7}$)";
    
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    //   NSString * PHS = @"^(0[0-9]{2})\\d{8}$|^(0[0-9]{3}(\\d{7,8}))$";
    
    
//    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
//    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
//    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
//    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    //手机号正则 修改为 1开头，11位
    NSString *ALL = @"^1[0-9]{10}";
    NSPredicate *regextestall = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", ALL];
    if ([regextestall evaluateWithObject:phoneNumber] == YES)
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
//    if (([regextestmobile evaluateWithObject:phoneNumber] == YES)
//        || ([regextestcm evaluateWithObject:phoneNumber] == YES)
//        || ([regextestct evaluateWithObject:phoneNumber] == YES)
//        || ([regextestcu evaluateWithObject:phoneNumber] == YES)
//        || ([regextestall evaluateWithObject:phoneNumber] == YES))
//    {
//        return YES;
//    }
//    else
//    {
//        return NO;
//    }
}

+(NSData*)returnDataWithDictionary:(NSDictionary*)dict
{
    NSMutableData* data = [[NSMutableData alloc]init];
    NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:dict forKey:@"talkData"];
    [archiver finishEncoding];
    
    return data;
}

#pragma mark - 日期与字符串
+ (NSString *)getDate
{//得到今天日期的字符串
    NSDate *senddate=[NSDate date];
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    NSString *locationString=[dateformatter stringFromDate:senddate];
    
    NSLog(@"locationString:%@",locationString);
    
    return locationString;
}


+ (NSString*)weekdayStringFromDate:(NSDate*)inputDate
{//将日期转换成周字符串
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六", nil];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    
    [calendar setTimeZone: timeZone];
    
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:inputDate];
    
    return [weekdays objectAtIndex:theComponents.weekday];
}

+ (NSArray *)getCurrentWeekDay:(NSDate *)date
{//获取当前周的日期数组
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitDay
                                         fromDate:now];
    
    // 得到星期几
    // 1(星期天) 2(星期二) 3(星期三) 4(星期四) 5(星期五) 6(星期六) 7(星期天)
    NSInteger weekDay = [comp weekday];
    // 得到几号
    NSInteger day = [comp day];
    // 计算当前日期和这周的星期一和星期天差的天数
    long firstDiff,lastDiff;
    if (weekDay == 1)
    {
        firstDiff = 1;
        lastDiff = 0;
    }
    else
    {
        firstDiff = [calendar firstWeekday] - weekDay;
        lastDiff = 9 - weekDay;
    }
    // 在当前日期(去掉了时分秒)基础上加上差的天数
    NSDateComponents *firstDayComp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    [firstDayComp setDay:day + firstDiff];
    
    NSDateComponents *lastDayComp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    [lastDayComp setDay:day + lastDiff];
    
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    return nil;
}

+ (NSString *)getCacheFilePathWithDirectory:(NSSearchPathDirectory)directory atPath:(NSString *)path
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES);
//    NSString *filePath = paths.lastObject;
    NSString *filePath = [paths.lastObject stringByAppendingPathComponent:path];
    //
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL existed = [fileManager fileExistsAtPath:filePath];
    //如果不存在
    if (!existed) {
        // 在Document目录下创建一个archiver目录
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return filePath;
}

+ (void)judgeFileExistsAtPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDir = NO;
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL existed = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    //如果不存在
    if (!(isDir && existed)) {
        // 在Document目录下创建一个archiver目录
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

#pragma mark - 缓存清理工具
//计算单个文件大小
+(float)fileSizeAtPath:(NSString *)path
{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:path]){
        long long size=[fileManager attributesOfItemAtPath:path error:nil].fileSize;
        return size/1024.0/1024.0;
    }
    return 0;
}

+(float)folderSizeAtPath:(NSString *)path
{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    float folderSize = 0.0;
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childerFiles=[fileManager subpathsAtPath:path];
        for (NSString *fileName in childerFiles) {
            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
           folderSize +=[self fileSizeAtPath:absolutePath];
        }
//SDWebImage框架自身计算缓存的实现
//        folderSize+=[[SDImageCache sharedImageCache] getSize]/1024.0/1024.0;
        return folderSize;
    }
    return 0;
}

+(void)clearCache:(NSString *)path compelteBlock:(ClearCachesBlock)completeBlock
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path])
    {
        NSArray *childerFiles = [fileManager subpathsAtPath:path];
        for (NSString *fileName in childerFiles)
        {
            //如有需要，加入条件，过滤掉不想删除的文件
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }
    
    [[[SDWebImageManager sharedManager] imageCache] clearWithCacheType:SDImageCacheTypeAll completion:^{
        [MBProgressHUD hideHUD];
        [MBProgressHUD showMessage:@"缓存清除成功"];
        if (completeBlock) {
            completeBlock();
        }
    }];
}

/**
 * 修图片大小
 */
+ (UIImage *) imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize) newSize
{
    newSize.height=image.size.height*(newSize.width/image.size.width);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return  newImage;
    
}

/**
 * 保存图片
 */
+ (NSString *)saveImage:(UIImage *)tempImage WithName:(NSString *)imageName
{
    NSData* imageData;
    
    //判断图片是不是png格式的文件
    if (UIImagePNGRepresentation(tempImage)) {
        //返回为png图像。
        imageData = UIImagePNGRepresentation(tempImage);
    }else {
        //返回为JPEG图像。
        imageData = UIImageJPEGRepresentation(tempImage, 1.0);
    }
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    
    NSString* documentsDirectory = [paths objectAtIndex:0];
    
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:imageName];
    
    NSArray *nameAry=[fullPathToFile componentsSeparatedByString:@"/"];
    NSLog(@"===fullPathToFile===%@",fullPathToFile);
    NSLog(@"===FileName===%@",[nameAry objectAtIndex:[nameAry count]-1]);
    
    [imageData writeToFile:fullPathToFile atomically:NO];
    return fullPathToFile;
}

/**
 * 生成GUID
 */
+ (NSString *)generateUuidString{
    // create a new UUID which you own
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    
    // create a new CFStringRef (toll-free bridged to NSString)
    // that you own
    NSString *uuidString = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuid));
    
    CFRelease(uuid);
    
    return uuidString;
}


+ (BOOL)checkPhotoLibraryAuthorizationStatus
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        [MBProgressHUD showMessage:@"该设备不支持相册"];
        return NO;
    }
    
    if ([AVCaptureDevice respondsToSelector:@selector(authorizationStatusForMediaType:)]) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (AVAuthorizationStatusDenied == authStatus ||
            AVAuthorizationStatusRestricted == authStatus) {
            [self showSettingAlertStr:@"请在iPhone的“设置->隐私->相册”中打开本应用的访问权限"];
            return NO;
        }
    }
    
    return YES;
}

+ (BOOL)checkCameraAuthorizationStatus
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [MBProgressHUD showMessage:@"该设备不支持拍照"];
        return NO;
    }
    
    if ([AVCaptureDevice respondsToSelector:@selector(authorizationStatusForMediaType:)]) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (AVAuthorizationStatusDenied == authStatus ||
            AVAuthorizationStatusRestricted == authStatus) {
            [self showSettingAlertStr:@"请在iPhone的“设置->隐私->相机”中打开本应用的访问权限"];
            return NO;
        }
    }
    
    return YES;
}

+ (void)showSettingAlertStr:(NSString *)tipStr{
    //iOS8+系统下可跳转到‘设置’页面，否则只弹出提示窗即可
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:tipStr preferredStyle:UIAlertControllerStyleAlert];
        //取消
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            //
        }]];
        //确定
        [alert addAction:[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UIApplication *app = [UIApplication sharedApplication];
            NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            
            if ([app canOpenURL:settingsURL])
            {
                [app openURL:settingsURL];
            }
            
        }]];
        UIViewController *viewC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        [viewC presentViewController:alert animated:YES completion:nil];

    }else{
       
    }
}

//百度转火星坐标
+ (CLLocationCoordinate2D )bdToGGEncrypt:(CLLocationCoordinate2D)coord
{
    double x = coord.longitude - 0.0065, y = coord.latitude - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * M_PI);
    double theta = atan2(y, x) - 0.000003 * cos(x * M_PI);
    CLLocationCoordinate2D transformLocation ;
    transformLocation.longitude = z * cos(theta);
    transformLocation.latitude = z * sin(theta);
    return transformLocation;
}

//火星坐标转百度坐标
+ (CLLocationCoordinate2D )ggToBDEncrypt:(CLLocationCoordinate2D)coord
{
    double x = coord.longitude, y = coord.latitude;
    
    double z = sqrt(x * x + y * y) + 0.00002 * sin(y * M_PI);
    double theta = atan2(y, x) + 0.000003 * cos(x * M_PI);
    
    CLLocationCoordinate2D transformLocation ;
    transformLocation.longitude = z * cos(theta) + 0.0065;
    transformLocation.latitude = z * sin(theta) + 0.006;
    
    return transformLocation;
}

//获得设备型号
+ (NSString *)getCurrentDevice
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString*platform = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
        
    if([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";

    if([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";

    if([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";

    if([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";

    if([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";

    if([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";

    if([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";

    if([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";

    if([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";

    if([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";

    if([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";

    if([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";

    if([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";

    if([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";

    if([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";

    if([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";

    if([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
        
    if([platform isEqualToString:@"iPhone10,1"]) return @"iPhone 8";
        
    if([platform isEqualToString:@"iPhone10,4"]) return @"iPhone 8";
        
    if([platform isEqualToString:@"iPhone10,2"]) return @"iPhone 8 Plus";
        
    if([platform isEqualToString:@"iPhone10,5"]) return @"iPhone 8 Plus";
        
    if([platform isEqualToString:@"iPhone10,3"]) return @"iPhone X";
        
    if([platform isEqualToString:@"iPhone10,6"]) return @"iPhone X";
    
    if([platform  isEqualToString:@"iPhone11,8"]) return @"iPhone XR";
    
    if([platform  isEqualToString:@"iPhone11,2"]) return @"iPhone XS";
    
    if([platform  isEqualToString:@"iPhone11,4"]) return @"iPhone XS Max";
    
    if([platform  isEqualToString:@"iPhone11,6"]) return @"iPhone XS Max";
        
    if([platform isEqualToString:@"iPod1,1"]) return @"iPod Touch 1G";
        
    if([platform isEqualToString:@"iPod2,1"]) return @"iPod Touch 2G";
        
    if([platform isEqualToString:@"iPod3,1"]) return @"iPod Touch 3G";
        
    if([platform isEqualToString:@"iPod4,1"]) return @"iPod Touch 4G";
        
    if([platform isEqualToString:@"iPod5,1"]) return @"iPod Touch 5G";
        
    if([platform isEqualToString:@"iPad1,1"]) return @"iPad 1G";
        
    if([platform isEqualToString:@"iPad2,1"]) return @"iPad 2";
        
    if([platform isEqualToString:@"iPad2,2"]) return @"iPad 2";
        
    if([platform isEqualToString:@"iPad2,3"]) return @"iPad 2";
        
    if([platform isEqualToString:@"iPad2,4"]) return @"iPad 2";
        
    if([platform isEqualToString:@"iPad2,5"]) return @"iPad Mini 1G";
        
    if([platform isEqualToString:@"iPad2,6"]) return @"iPad Mini 1G";
        
    if([platform isEqualToString:@"iPad2,7"]) return @"iPad Mini 1G";
        
    if([platform isEqualToString:@"iPad3,1"]) return @"iPad 3";
        
    if([platform isEqualToString:@"iPad3,2"]) return @"iPad 3";
        
    if([platform isEqualToString:@"iPad3,3"]) return @"iPad 3";
        
    if([platform isEqualToString:@"iPad3,4"]) return @"iPad 4";
        
    if([platform isEqualToString:@"iPad3,5"]) return @"iPad 4";
        
    if([platform isEqualToString:@"iPad3,6"]) return @"iPad 4";
        
    if([platform isEqualToString:@"iPad4,1"]) return @"iPad Air";
        
    if([platform isEqualToString:@"iPad4,2"]) return @"iPad Air";
        
    if([platform isEqualToString:@"iPad4,3"]) return @"iPad Air";
        
    if([platform isEqualToString:@"iPad4,4"]) return @"iPad Mini 2G";
        
    if([platform isEqualToString:@"iPad4,5"]) return @"iPad Mini 2G";
        
    if([platform isEqualToString:@"iPad4,6"]) return @"iPad Mini 2G";
        
    if([platform isEqualToString:@"iPad4,7"]) return @"iPad Mini 3";
        
    if([platform isEqualToString:@"iPad4,8"]) return @"iPad Mini 3";
        
    if([platform isEqualToString:@"iPad4,9"]) return @"iPad Mini 3";
        
    if([platform isEqualToString:@"iPad5,1"]) return @"iPad Mini 4";
        
    if([platform isEqualToString:@"iPad5,2"]) return @"iPad Mini 4";
        
    if([platform isEqualToString:@"iPad5,3"]) return @"iPad Air 2";
        
    if([platform isEqualToString:@"iPad5,4"]) return @"iPad Air 2";
        
    if([platform isEqualToString:@"iPad6,3"]) return @"iPad Pro 9.7";
        
    if([platform isEqualToString:@"iPad6,4"]) return @"iPad Pro 9.7";
        
    if([platform isEqualToString:@"iPad6,7"]) return @"iPad Pro 12.9";
        
    if([platform isEqualToString:@"iPad6,8"]) return @"iPad Pro 12.9";
        
    if([platform isEqualToString:@"i386"]) return @"iPhone Simulator";
        
    if([platform isEqualToString:@"x86_64"]) return @"iPhone Simulator";
    
    return platform;
}

//播放声音
+(void)playsound:(NSString *)soundname{
    NSString *tempstr1=[[NSString alloc]init];
    NSString *tempstr2=[[NSString alloc]init];
    NSRange subrange;
    subrange = [soundname rangeOfString:@".mp3"];
    
    if (subrange.location !=NSNotFound) {
        tempstr1=[soundname substringToIndex:subrange.location];
        tempstr2=[soundname substringFromIndex:subrange.location+1];
    }else{
        NSLog(@"文件名输入错误！");
        return;
    }
    NSURL* system_sound_url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:tempstr1 ofType:tempstr2]];
    SystemSoundID system_sound_id;
    
    AudioServicesCreateSystemSoundID(
                                     (__bridge CFURLRef)system_sound_url,
                                     &system_sound_id
                                     );
    
    // Register the sound completion callback.
    AudioServicesAddSystemSoundCompletion(
                                          system_sound_id,
                                          NULL, // uses the main run loop
                                          NULL, // uses kCFRunLoopDefaultMode
                                          MySoundFinishedPlayingCallback, // the name of our custom callback function
                                          NULL // for user data, but we don't need to do that in this case, so we just pass NULL
                                          );
    
    // Play the System Sound
    AudioServicesPlaySystemSound(system_sound_id);
}


void MySoundFinishedPlayingCallback(SystemSoundID sound_id, void* user_data)
{
    AudioServicesDisposeSystemSoundID(sound_id);
}

+ (void)vibrate   {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

+(BOOL)isIphoneX
{
    //Simulator
    if ([[self getCurrentDevice] isEqualToString:@"iPhone Simulator"]) {
        return true;
    }
    
    //获取状态栏的rect
    CGRect statusRect = [[UIApplication sharedApplication] statusBarFrame];
    
    if ([[self getCurrentDevice] isEqualToString:@"iPhone X"] ||
        [[self getCurrentDevice] isEqualToString:@"iPhone XR"] ||
        [[self getCurrentDevice] isEqualToString:@"iPhone XS"] ||
        [[self getCurrentDevice] isEqualToString:@"iPhone XS Max"] ||
        statusRect.size.height > 20) {
        return true;
    } else {
        return false;
    }
}

+ (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    //app默认windowLevel是UIWindowLevelNormal，如果不是，找到它
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    id nextResponder = nil;
    UIViewController *appRootVC = window.rootViewController;
    //1、通过present弹出VC，appRootVC.presentedViewController不为nil
    if (appRootVC.presentedViewController) {
        nextResponder = appRootVC.presentedViewController;
    }else{
        //2、通过navigationcontroller弹出VC
//        DLog(@"subviews == %@",[window subviews]);
        UIView *frontView = [[window subviews] objectAtIndex:0];
        nextResponder = [frontView nextResponder];
    }
    //1、tabBarController
    if ([nextResponder isKindOfClass:[UITabBarController class]]){
        UITabBarController * tabbar = (UITabBarController *)nextResponder;
        UINavigationController * nav = (UINavigationController *)tabbar.viewControllers[tabbar.selectedIndex];
        //或者 UINavigationController * nav = tabbar.selectedViewController;
        result = nav.childViewControllers.lastObject;
    }else if ([nextResponder isKindOfClass:[UINavigationController class]]){
        //2、navigationController
        UIViewController * nav = (UIViewController *)nextResponder;
        result = nav.childViewControllers.lastObject;
    }else{//3、viewControler
        result = nextResponder;
    }
    
    result = window.rootViewController;
    while (result.presentedViewController) {
        result = result.presentedViewController;
    }
    if ([result isKindOfClass:[RootTabbarViewController class]]) {
        result = [(RootTabbarViewController *)result selectedViewController];
    }
    if ([result isKindOfClass:[UINavigationController class]]) {
        result = [(UINavigationController *)result topViewController];
    }
    return result;
}

+ (void)clearAppCacheCompelteBlock:(ClearCachesBlock)completeBlock
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    //计算缓存文件大小
//    float size = [VTGeneralTool folderSizeAtPath:path];
//
//    [MBProgressHUD showLoadingWithMessage:@"正在计算..."];
//    NSString *str = [NSString stringWithFormat:@"缓存大小为%.2fM，确定清理缓存吗？",size];
    NSString *str = @"清除缓存会删除您下载的音视频，确定要清理缓存吗？";
    [self showAlertSystemWithTitle:@"提示" subTitle:str sureBlock:^{
        [MBProgressHUD showLoadingWithMessage:@"正在清除缓存..."];
        [VTGeneralTool clearCache:path compelteBlock:^{
            if (completeBlock) {
                completeBlock();
            }
        }];
    }];
    [MBProgressHUD hideHUD];
}

+ (void)showAlertSystemWithTitle:(NSString *)title subTitle:(NSString *)subTitle sureBlock:(sureBlock)sureBlock
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:subTitle preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (sureBlock) {
            sureBlock();
        }
    }]];
    [[self getCurrentVC] presentViewController:alert animated:YES completion:nil];
}

+ (void)showAlertSystemWithTitle:(NSString *)title subTitle:(NSString *)subTitle cancel:(NSString *)cancel sure:(NSString *)sure sureBlock:(sureBlock)sureBlock
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:subTitle preferredStyle:UIAlertControllerStyleAlert];
    if (cancel) {
        [alert addAction:[UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
    }
    if (sure) {
        [alert addAction:[UIAlertAction actionWithTitle:sure style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (sureBlock) {
                sureBlock();
            }
        }]];
    }
    [[self getCurrentVC] presentViewController:alert animated:YES completion:nil];
}

+ (CGFloat)countStringWidthTitle:(NSString *)title fontSize:(CGFloat)fontSize height:(CGFloat)height
{
    CGSize textSize = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil].size;
    return textSize.width;
}

+ (CGFloat)countStringHeightTitle:(NSString *)title fontSize:(CGFloat)fontSize width:(CGFloat)width
{
    CGSize textSize = [title boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil].size;
    return textSize.height;
}

+ (void)judgeAppVersionWithAPPID:(NSString *)appId withBundleId:(NSString *)bundelId block:(UpdateBlock)block
{
    NSDictionary *infoDic=[[NSBundle mainBundle] infoDictionary];
    __block NSString *currentVersion=infoDic[@"CFBundleShortVersionString"];
    
//    __block NSString *currentVersion = infoDic[@"CFBundleVersion"];
    
    NSURLRequest *request;
    if (appId != nil) {
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/cn/lookup?id=%@",appId]]];
        DLog(@"【1】当前为APPID检测，您设置的APPID为:%@  当前版本号为:%@",appId,currentVersion);
    }else if (bundelId != nil){
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@&country=cn",bundelId]]];
        DLog(@"【1】当前为BundelId检测，您设置的bundelId为:%@  当前版本号为:%@",bundelId,currentVersion);
    }else{
        NSString *currentBundelId=infoDic[@"CFBundleIdentifier"];
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@&country=cn",currentBundelId]]];
        DLog(@"【1】当前为自动检测,  当前版本号为:%@",currentVersion);
    }
    //开始检测
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
           DLog(@"检测失败，原因：\n%@",error);
            dispatch_async(dispatch_get_main_queue(), ^{
                block(currentVersion,@"",@"",NO);
            });
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *appInfoDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            if ([appInfoDic[@"resultCount"] integerValue] == 0) {
                DLog(@"检测出未上架的APP或者查询不到");
                block(currentVersion,@"",@"",NO);
                return;
            }
            DLog(@"【3】苹果服务器返回的检测结果：\n appId = %@ \n bundleId = %@ \n 开发账号名字 = %@ \n 商店版本号 = %@ \n 应用名称 = %@ \n 打开连接 = %@",appInfoDic[@"results"][0][@"artistId"],appInfoDic[@"results"][0][@"bundleId"],appInfoDic[@"results"][0][@"artistName"],appInfoDic[@"results"][0][@"version"],appInfoDic[@"results"][0][@"trackName"],appInfoDic[@"results"][0][@"trackViewUrl"]);
            NSString *appStoreVersion = appInfoDic[@"results"][0][@"version"];
            currentVersion = [currentVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
            if (currentVersion.length==2) {
                currentVersion  = [currentVersion stringByAppendingString:@"0"];
            } else if (currentVersion.length==1){
                currentVersion  = [currentVersion stringByAppendingString:@"00"];
            }
            appStoreVersion = [appStoreVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
            if (appStoreVersion.length==2) {
                appStoreVersion  = [appStoreVersion stringByAppendingString:@"0"];
            }else if (appStoreVersion.length==1){
                appStoreVersion  = [appStoreVersion stringByAppendingString:@"00"];
            }
            if ([currentVersion floatValue] < [appStoreVersion floatValue])
            {
                DLog(@"判断结果：当前版本号%@ < 商店版本号%@ 需要更新\n=========我是分割线========",[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"],appInfoDic[@"results"][0][@"version"]);
                block([[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"],appInfoDic[@"results"][0][@"version"],appInfoDic[@"results"][0][@"trackViewUrl"],YES);
            } else {
                DLog(@"判断结果：当前版本号%@ > 商店版本号%@ 不需要更新\n========我是分割线========",[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"],appInfoDic[@"results"][0][@"version"]);
                block([[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"],appInfoDic[@"results"][0][@"version"],appInfoDic[@"results"][0][@"trackViewUrl"],NO);
            }
        });
    }];
    [task resume];
}

+ (NSString *)getUUID
{
    //7MM2ZZHFF5.sdk10018
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"YiCaiTongUUID" accessGroup:nil];
    NSString *UUID = [keychainItem objectForKey:(__bridge id)kSecValueData];
    
    if (UUID == nil || UUID.length == 0) {
        [keychainItem setObject:@"MY_APP_CREDENTIALS" forKey:(id)kSecAttrService];
        UUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [keychainItem setObject:UUID forKey:(__bridge id)kSecValueData];
    }
    return UUID;
}

+ (BOOL)checkHaveEmoji:(NSString *)string
{
    __block BOOL returnValue = NO;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue = YES;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue = YES;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                    }
                                }
                            }];
    
    NSString *other = @"➋➌➍➎➏➐➑➒";     //九宫格的输入值
    if ([other rangeOfString:string].location != NSNotFound) {
        returnValue = NO;
    }
    
    return returnValue;
}

//判断第三方键盘中的表情
+ (BOOL)hasEmoji:(NSString*)string
{
    NSString *pattern = @"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:string];
    return isMatch;
}

+ (BOOL)checkPassword:(NSString *)password
{
    NSString *pattern =@"^(?![0-9]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{8,16}";
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    
    BOOL isMatch = [pred evaluateWithObject:password];
    
    return isMatch;
}

/** 银行卡号有效性问题Luhn算法
 *  现行 16 位银联卡现行卡号开头 6 位是 622126～622925 之间的，7 到 15 位是银行自定义的，
 *  可能是发卡分行，发卡网点，发卡序号，第 16 位是校验码。
 *  16 位卡号校验位采用 Luhm 校验方法计算：
 *  1，将未带校验位的 15 位卡号从右依次编号 1 到 15，位于奇数位号上的数字乘以 2
 *  2，将奇位乘积的个十位全部相加，再加上所有偶数位上的数字
 *  3，将加法和加上校验位能被 10 整除。
 */
+ (BOOL)isBankCardNumber:(NSString *)cardNum
{
    
    NSString * lastNum = [[cardNum substringFromIndex:(cardNum.length-1)] copy];//取出最后一位
    NSString * forwardNum = [[cardNum substringToIndex:(cardNum.length -1)] copy];//前15或18位
    
    NSMutableArray * forwardArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i=0; i<forwardNum.length; i++) {
        NSString * subStr = [forwardNum substringWithRange:NSMakeRange(i, 1)];
        [forwardArr addObject:subStr];
    }
    
    NSMutableArray * forwardDescArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = (int)(forwardArr.count-1); i> -1; i--) {//前15位或者前18位倒序存进数组
        [forwardDescArr addObject:forwardArr[i]];
    }
    
    NSMutableArray * arrOddNum = [[NSMutableArray alloc] initWithCapacity:0];//奇数位*2的积 < 9
    NSMutableArray * arrOddNum2 = [[NSMutableArray alloc] initWithCapacity:0];//奇数位*2的积 > 9
    NSMutableArray * arrEvenNum = [[NSMutableArray alloc] initWithCapacity:0];//偶数位数组
    
    for (int i=0; i< forwardDescArr.count; i++) {
        NSInteger num = [forwardDescArr[i] intValue];
        if (i%2) {//偶数位
            [arrEvenNum addObject:[NSNumber numberWithInteger:num]];
        }else{//奇数位
            if (num * 2 < 9) {
                [arrOddNum addObject:[NSNumber numberWithInteger:num * 2]];
            }else{
                NSInteger decadeNum = (num * 2) / 10;
                NSInteger unitNum = (num * 2) % 10;
                [arrOddNum2 addObject:[NSNumber numberWithInteger:unitNum]];
                [arrOddNum2 addObject:[NSNumber numberWithInteger:decadeNum]];
            }
        }
    }
    
    __block  NSInteger sumOddNumTotal = 0;
    [arrOddNum enumerateObjectsUsingBlock:^(NSNumber * obj, NSUInteger idx, BOOL *stop) {
        sumOddNumTotal += [obj integerValue];
    }];
    
    __block NSInteger sumOddNum2Total = 0;
    [arrOddNum2 enumerateObjectsUsingBlock:^(NSNumber * obj, NSUInteger idx, BOOL *stop) {
        sumOddNum2Total += [obj integerValue];
    }];
    
    __block NSInteger sumEvenNumTotal =0 ;
    [arrEvenNum enumerateObjectsUsingBlock:^(NSNumber * obj, NSUInteger idx, BOOL *stop) {
        sumEvenNumTotal += [obj integerValue];
    }];
    
    NSInteger lastNumber = [lastNum integerValue];
    
    NSInteger luhmTotal = lastNumber + sumEvenNumTotal + sumOddNum2Total + sumOddNumTotal;
    
    return (luhmTotal%10 ==0)?YES:NO;
}

+ (UIToolbar *)textFieldToolBarDone:(TextFieldDoneBlock)doneBlock
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    toolbar.tintColor = TextColor_DarkGray;
    toolbar.backgroundColor = APP_BasicColor;
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:nil action:nil];
    [doneBtn bindClickHandlerBlock:^{
        if (doneBlock) {
            doneBlock();
        }
    }];
    
    toolbar.items = @[space, doneBtn];
    return toolbar;
}

+ (NSString *)notRounding:(double)price afterPoint:(int)position
{
    NSString *doubleString = [NSString stringWithFormat:@"%f", price];
    
    NSRange range = [doubleString rangeOfString:@"."];
    if (range.location != NSNotFound) {
        NSString *result = [doubleString substringToIndex:range.location + range.length + position];
        return result;
    } else {
        return doubleString;
    }

//    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
//    NSDecimalNumber *ouncesDecimal;
//    NSDecimalNumber *roundedOunces;
//
//    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:price];
//    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
//    return [NSString stringWithFormat:@"%@",roundedOunces];
    
//    return [NSString stringWithFormat:@"%.2lf", floor(price*100.0)/100];
}

+ (UIImage *)creatQRCodeWithUrl:(NSString *)url size:(CGFloat)size logoImageName:(NSString *)logoImageName
{
    // 1. 创建一个二维码滤镜实例(CIFilter)
    CIFilter *filter   = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 滤镜恢复默认设置
    [filter setDefaults];
    // 2. 给滤镜添加数据
    NSString *string   = url;
    NSData *data       = [string dataUsingEncoding:NSUTF8StringEncoding];
    // 使用KVC的方式给filter赋值
    [filter setValue:data forKeyPath:@"inputMessage"];

    // 3. 生成二维码
    CIImage *image     = [filter outputImage];

    //4.在中心增加一张图片
    UIImage *img       = [UIImage createNonInterpolatedUIImageFormCIImage:image withSize:size];

    if (logoImageName) {
        //5.把中央图片划入二维码里面
        //5.1开启图形上下文
        UIGraphicsBeginImageContext(img.size);
        //5.2将二维码的图片画入
        [img drawInRect:CGRectMake(0, 0, img.size.width, img.size.height)];
        UIImage *centerImg = [UIImage imageNamed:logoImageName];
        CGFloat centerW    = img.size.width * 0.25;
        CGFloat centerH    = centerW;
        CGFloat centerX    = (img.size.width - centerW) * 0.5;
        CGFloat centerY    = (img.size.height - centerH) * 0.5;
        [centerImg drawInRect:CGRectMake(centerX, centerY, centerW, centerH)];
        //5.3获取绘制好的图片
        UIImage *finalImg  = UIGraphicsGetImageFromCurrentImageContext();
        //5.4关闭图像上下文
        UIGraphicsEndImageContext();
        
        return finalImg;
    }
    return img;
}

+ (NSString *)stringToLower:(NSString *)str
{
    for (NSInteger i = 0; i < str.length; i++) {
        if ([str characterAtIndex:i] >= 'A' & [str characterAtIndex:i] <= 'Z') {
            char temp = [str characterAtIndex:i]+32;
            NSRange range = NSMakeRange(i, 1);
            str = [str stringByReplacingCharactersInRange:range withString:[NSString stringWithFormat:@"%c",temp]];
        }
    }
    return str;
}



+ (void)showCustomerAlertWithTitle:(NSString *)title
{
    NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
    style.alignment                 = NSTextAlignmentCenter;
    style.lineSpacing               = FITFRAME(12.0);
    NSMutableAttributedString *aStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", title] attributes:@{NSForegroundColorAttributeName: WLAlertTextDarkColor, NSFontAttributeName: WLAlertTextFontMax, NSParagraphStyleAttributeName: style}];
    id <WLAlertViewProtocol> alert = [WLAlertView alertViewWithTitle:aStr message:nil preferredStyle:WLAlertViewStyleAlert footStyle:WLAlertPublicFootStyleDefalut bodyStyle:WLAlertPublicBodyStyleDefalut cancelButtonTitle:@"我知道了" otherButtonTitles:nil handler:^(NSInteger buttonIndex, id  _Nullable value) {
        
    }];
    [alert setButtionTitleColor:APP_MainColor index:0];
    [alert show];
}

// 状态栏+导航栏的高度
+ (CGFloat)navFullHeight {
    CGFloat height = 0;
    if (@available(iOS 13.0, *)) {
        UIWindow *win = [UIApplication sharedApplication].windows.firstObject;
        height = win.safeAreaInsets.top;
    } else {
        height = [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    return height + 44;
}

@end
