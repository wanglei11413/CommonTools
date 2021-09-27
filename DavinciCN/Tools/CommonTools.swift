//
//  CommonTools.swift
//  DavinciCN
//  常用工具
//  Created by Mac on 2021/9/24.
//

import Foundation
import UIKit
import AVFoundation
import Photos

// MARK: - 设置RGB颜色
func RGBColor(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
    return UIColor.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1)
}

/// 设置RGB颜色带透明度
func RGBColorA(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat) -> UIColor {
    return UIColor.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
}

// MARK: - 设置十六进制颜色（样式：0xff00ff ）
public let HexRGB:((Int) -> UIColor) = { (rgbValue : Int) -> UIColor in
    return HexRGBAlpha(rgbValue,1.0)
}

/// 通过 十六进制与alpha来设置颜色值  （ 样式： 0xff00ff ）
public let HexRGBAlpha:((Int,Float) -> UIColor) = { (rgbValue : Int, alpha : Float) -> UIColor in
    return UIColor(red: CGFloat(CGFloat((rgbValue & 0xFF0000) >> 16)/255), green: CGFloat(CGFloat((rgbValue & 0xFF00) >> 8)/255), blue: CGFloat(CGFloat(rgbValue & 0xFF)/255), alpha: CGFloat(alpha))
}

// MARK: - 设置字体
func Font(_ float: Float) -> UIFont {
    return UIFont.systemFont(ofSize: RW(CGFloat(float)))
}

/// 设置宽体字体大小
func BoldFont(_ float: Float) -> UIFont {
    return UIFont.boldSystemFont(ofSize: RW(CGFloat(float)))
}

// MARK: - 适配宽度
func RW(_ value: CGFloat) -> CGFloat {
    return (value) / 375.0 * UIScreen.main.bounds.size.width
}

// MARK: - 适配高度
func RH(_ value: CGFloat) -> CGFloat {
    return (value) / (isFullScreen ? 812.0 : 667.0) * UIScreen.main.bounds.size.height
}

// MARK: - 根据名称设置图片
func imageName(_ imageString:String)->UIImage{
    return UIImage(named: imageString)!
}


// MARK: 获取当前根控制器
public func getRootVC() -> UIViewController? {
    
    let window: UIWindow? = (UIApplication.shared.delegate?.window)!
    var topViewController: UIViewController? = window?.rootViewController
    
    while true {
        
        if topViewController?.presentedViewController != nil {
            
            topViewController = topViewController?.presentedViewController
        } else if (topViewController is UINavigationController) && (topViewController as? UINavigationController)?.topViewController != nil {
            
            topViewController = (topViewController as? UINavigationController)?.topViewController
        } else if (topViewController is UITabBarController) {
            
            let tab = topViewController as? UITabBarController
            topViewController = tab?.selectedViewController
        } else {
            break
        }
    }
    return topViewController
}


// MARK: log输出&提示框
public func DLog<T>(_ message : T, file : String = #file, funcName : String = #function, lineNum : Int = #line) {
    
    let fileName = (file as NSString).lastPathComponent
    print(dateString(nil, nil))
    print("\(fileName):(\(lineNum))-\(message)")
}

// MARK: - 获取当前时间戳
/// 获取当前时间戳
/// - Returns: 时间戳
public func dateCurrentStamp() -> String {
    
    let date       = Date(timeIntervalSinceNow: 0)
    let interval   = date.timeIntervalSince1970
    let timeString = String(format: "%0.f", interval)
    return timeString
}

// MARK: - 根据时间戳、格式获取时间
/// 根据时间戳、格式获取时间
/// - Parameters:
///   - timeStamp: 时间戳，为空代表取当前时间
///   - foramtter: 时间格式，为空代表取默认格式
/// - Returns: 结果
public func dateString(_ timeStamp: Double?,
                       _ foramtter: String?) -> String {
    // 如果timeStamp为空，那么代表取当前时间
    var currentDate = Date()
    if timeStamp != nil {
        currentDate = Date(timeIntervalSince1970: timeStamp!)
    }
    let format        = DateFormatter()
    format.dateFormat = "yyyy-MM-dd HH:mm:ss"
    // 如果foramtter为空，那么代表取默认格式
    if foramtter != nil {
        format.dateFormat = foramtter
    }
    let resultStr = format.string(from: currentDate)
    return resultStr
}

// MARK: - 比较两个日期大小
public func dateCompare(_ startDateStr: String?,
                        _ endDateStr: String?) -> Int {

    let formatter        = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    var date1 = Date(), date2 = Date()
    if startDateStr != nil {
        date1 = formatter.date(from: startDateStr!) ?? Date()
    }
    if endDateStr != nil {
        date2 = formatter.date(from: endDateStr!) ?? Date()
    }
    
    switch date1.compare(date2) {
    case .orderedSame:
        // 相等
        return 0
    case .orderedAscending:
        // end比start大
        return 1
    default:
        // end比start小
        return -1
    }
}

// MARK: 格式化日期
/// 格式化日期
/// - Parameters:
///   - dateStr: 转要转化的时间(格式为：yyyy-MM-dd HH:mm:ss)
/// - Returns:
/**- 刚刚(一分钟内)
*      - X分钟前(一小时内)
*      - X小时前(当天)
*      - MM-dd HH:mm(一年内)
*      - yyyy-MM-dd HH:mm(更早期)
*/
public func dateStyleDesc(_ dateStr: String) -> String {
    // 获取当前时间
    let currentDate = Date()
    // 目标时间
    let formatter        = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    guard let targetDate =  formatter.date(from: dateStr) else { return "" }
    
    let calendar = Calendar.current
    let returnFormatter = DateFormatter()
    // 先判断年份
    if calendar.isDate(targetDate, equalTo: currentDate, toGranularity: .year) {
        // 判断是否为今天
        if calendar.isDateInToday(targetDate) {
            let components = calendar.dateComponents([.minute, .hour], from: targetDate, to: currentDate)
            // 判断小时
            if components.hour == 0 {
                // 判断分钟
                if components.minute == 0 {
                    return "刚刚"
                } else {
                    return "\(String(describing: components.hour))分钟前"
                }
            } else {
                return "\(String(describing: components.hour))小时前"
            }
        } else if calendar.isDateInYesterday(targetDate) {
            return "昨天"
        } else {
            returnFormatter.dateFormat = "MM.dd"
            return returnFormatter.string(from: targetDate)
        }
    } else {
        // 直接返回年月日
        returnFormatter.dateFormat = "yyyy.MM.dd";
        return returnFormatter.string(from: targetDate)
    }
}

// MARK: - 计算两个日期的天数
/// 计算两个日期的天数（yyyy-MM-dd HH:mm:ss）
/// - Parameters:
///   - beginDateStr: 开始日期-为空代表当前时间
///   - endDateStr: 结束日期-为空代表当前时间
/// - Returns: 差值
public func dateDifferenceDays(_ beginDateStr: String?,
                               _ endDateStr: String?) -> Int {
    let formatter        = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    var beginDate = Date(), endDate = Date()
    if beginDateStr != nil {
        beginDate = formatter.date(from: beginDateStr!) ?? Date()
    }
    if endDateStr != nil {
        endDate = formatter.date(from: endDateStr!) ?? Date()
    }
    // 去时间间隔
    let deltaTime = endDate.timeIntervalSince(beginDate)
    let days = deltaTime / (24 * 60 * 60)
    return Int(days)
}

// MARK: - 返回指定时间加指定天数的结果日期字符串
/// 返回指定时间加指定天数的结果日期字符串
/// - Parameters:
///   - dateString: 指定时间-为空代表为当前时间
///   - formatterString: 格式-为空代表yyyy-MM-dd HH:mm:ss
///   - addDays: 要增加的天数
/// - Returns: 日期
public func dateAddDays(_ dateString: String? ,
                        _ formatterString: String?,
                        _ addDays: Int) -> String {
    let formatter        = DateFormatter()
    formatter.dateFormat = formatterString ?? "yyyy-MM-dd HH:mm:ss"
    var oldDate = Date()
    if dateString != nil {
        oldDate = formatter.date(from: dateString!) ?? Date()
    }
    let newDate = oldDate.addingTimeInterval(TimeInterval(60 * 60 * 24 * addDays))
    let resultString = formatter.string(from: newDate)
    return resultString
}

// MARK: - 计算过去一个时间与现在的差值
/// 计算过去一个时间与现在的差值
/// - Parameter time: 某个时间的时间戳
/// - Returns: 返回差值（单位 分钟）
func getTimeDifference(_ time: Int) -> Double {
    
    //获取当前时间的时间戳
    let now = Date()
    let nowTerval =  now.timeIntervalSince1970
    let nowSamp = Int(CLongLong(round(nowTerval * 1000)))
    
    //时间戳大于当前时间，返回0
    if time > nowSamp {
        return 0.0
    }
    
    //计算两个时间差
    let different = nowSamp - time
    let difMinutes: Double = Double((different/1000)/60)
    
    return difMinutes
}

// MARK: - 生成渐变色图片
/// 生成渐变色的图片
/// - Parameters:
///   - size: 要生成图片大小
///   - colors: 渐变色数组
///   - locations: 渐变位置
/// - Returns: 结果
func getGradualImage(_ size: CGSize,
                     _ colors: [UIColor],
                     _ locations: [NSNumber]) -> UIImage {
    if colors.count == 0 || locations.count == 0 {
        return UIImage()
    }
    UIGraphicsBeginImageContextWithOptions(size, true, 0)
    guard let context = UIGraphicsGetCurrentContext()
    else { return UIImage() }
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let colors = colors.map {(color: UIColor) -> AnyObject? in return color.cgColor as AnyObject? } as NSArray
    let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: nil)
    // 第二个参数是起始位置，第三个参数是终止位置
    context.drawLinearGradient(gradient!, start: CGPoint(x: 0, y: 0), end: CGPoint(x: size.width, y: 0), options: CGGradientDrawingOptions(rawValue: 0))
    guard let resultImg = UIGraphicsGetImageFromCurrentImageContext()
    else { return UIImage() }
    UIGraphicsEndImageContext()
    return resultImg
}

// MARK: - 去除图片背景色
/// 去除图片的背景颜色
/// - Parameters:
///   - img: 图片
///   - colorMasking: 要去除的颜色
/// - Returns: 新图片
public func transparentImageColor(_ img: UIImage,
                                  _ colorMasking: [CGFloat]) -> UIImage? {
    if let rawImageRef = img.cgImage {
        UIGraphicsBeginImageContext(img.size)
        if let maskedImageRef = rawImageRef.copy(maskingColorComponents: colorMasking) {
            let context: CGContext = UIGraphicsGetCurrentContext()!
            context.translateBy(x: 0.0, y: img.size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            context.draw(maskedImageRef, in: CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height))
            let result = UIGraphicsGetImageFromCurrentImageContext()
            return result
        }
    }
    return img
}

// MARK: - 扩大button的点击范围
/// 自定义的button，扩大了点击范围
class WLButton:UIButton {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let margin:CGFloat = -20
        let clickArea = bounds.insetBy(dx: margin, dy: margin)
        return clickArea.contains(point)
    }
}

// MARK: - 颜色转图片
/// 颜色转图片
/// - Parameters:
///   - color: 颜色
///   - viewSize: 大小
/// - Returns: 结果
func imageFromColor(_ color: UIColor,
                    _ viewSize: CGSize) -> UIImage{
   let rect: CGRect = CGRect(x: 0, y: 0, width: viewSize.width, height: viewSize.height)
   UIGraphicsBeginImageContext(rect.size)
   let context: CGContext = UIGraphicsGetCurrentContext()!
   context.setFillColor(color.cgColor)
   context.fill(rect)
   let image = UIGraphicsGetImageFromCurrentImageContext()
   UIGraphicsGetCurrentContext()
   return image!
}

// MARK: 存储数据到UserDefaults
let UserDefault = UserDefaults.standard;
///存本地
public func userDefaultsSave(_ value: Any, _ key: String) {
    UserDefault.set(value, forKey: key)
    UserDefault.synchronize()
}
///从本地取
public func userDefaultsGet(_ key: String) -> Any? {
    return UserDefault.object(forKey: key)
}
///清除本地数据
public func userDefaultsRemove(_ key: String) {
    UserDefault.removeObject(forKey: key)
    UserDefault.synchronize()
}

// MARK: 设备宽高、机型
public let kScreenHeight    = UIScreen.main.bounds.size.height
public let kScreenWidth     = UIScreen.main.bounds.size.width
public let kStatusBarheight = UIApplication.shared.statusBarFrame.size.height
public let kScreenFrame     = UIScreen.main.bounds

public let isIphoneX_XS = kScreenWidth == 375.0 && kScreenHeight == 812.0 ? true : false
public let isIphoneXR_XSMax = kScreenWidth == 414.0 && kScreenHeight == 896.0 ? true : false
public let isIphone_12Pro = kScreenWidth == 390.0 && kScreenHeight == 844.0 ? true : false
public let isIphone_12ProMax = kScreenWidth == 428.0 && kScreenHeight == 926.0 ? true : false

// MARK: - 是否为全屏
public let isFullScreen = getIsFullScreen()
private func getIsFullScreen() -> Bool {
    // 根据安全区域判断
    let height = UIApplication.shared.keyWindow?.safeAreaInsets.bottom
    //获取状态栏的rect
    let statusRect = UIApplication.shared.statusBarFrame
    
    if statusRect.size.height > 20 || (height ?? 0) > 0 {
        return true;
    } else {
        return false;
    }
}

// MARK: - 屏幕底部安全距离
let KSafeBottomMargin = getTabbarSafeBottomMargin()
let KTabBarHeight     = 49 +  KSafeBottomMargin
/// 获取屏幕底部安全距离
/// - Returns: 边距值
private func getTabbarSafeBottomMargin() -> CGFloat {
    var safeBottom: CGFloat = 0
    if #available(iOS 11, *) {
        let safeArea = UIApplication.shared.keyWindow?.safeAreaInsets
        safeBottom = safeArea?.bottom ?? 0
    }
    return safeBottom
}

// MARK: - 屏幕顶部安全距离
let KSafeTopMargin = getNaviSafeTopMargin()
let KNaviHeight    = 64 +  KSafeTopMargin
/// 获取屏幕底部安全距离
/// - Returns: 边距值
private func getNaviSafeTopMargin() -> CGFloat {
    var safeTop: CGFloat = 0
    if #available(iOS 11, *) {
        let safeArea = UIApplication.shared.keyWindow?.safeAreaInsets
        safeTop = safeArea?.top ?? 0
    }
    return safeTop
}

// MARK: - 生成随机颜色
public func randomColor() -> UIColor {
    let r = arc4random_uniform(256)
    let g = arc4random_uniform(256)
    let b = arc4random_uniform(256)
    return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1)
}

// MARK: - 将时长转为时分秒
public func getTimeString(_ duration: Int) -> String {
    let hour = duration / 3600
    let minute = duration % 3600 / 60
    let seconds = duration % 3600 % 60
    var dateStr = String(format: "%d秒", seconds)
    if hour > 0 {
        dateStr = String(format: "%d小时%d分钟", hour, minute)
    } else if minute > 0 {
        dateStr = String(format: "%d分钟", minute)
    }
    return dateStr
}

// MARK: - 检查身份证号格式
public func validateIDCardNumber(_ idCardNumber: String) -> Bool {
    var flag: Bool = false
    // 位数小于等于0直接返回false
    if idCardNumber.count <= 0 {
        return flag
    }
    // 正则校验
    let regex = "^(^[1-9]\\d{7}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}$)|(^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])((\\d{4})|\\d{3}[Xx])$)$"
    let identityCardPredicate = NSPredicate(format: "SELF MATCHES %@", regex)
    // 第一次核验
    flag = identityCardPredicate.evaluate(with: idCardNumber)
    // 如果通过该验证，说明身份证格式正确，但准确性还需计算
    if flag {
        // 如果是18位
        if idCardNumber.count == 18 {
            //将前17位加权因子保存在数组里
            let idCardWiArray = ["7", "9", "10", "5", "8", "4", "2", "1", "6", "3", "7", "9", "10", "5", "8", "4", "2"]
            //这是除以11后，可能产生的11位余数、验证码，也保存成数组
            let idCardYArray = ["1", "0", "10", "9", "8", "7", "6", "5", "4", "3", "2"]
            //用来保存前17位各自乖以加权因子后的总和
            var idCardWiSum = 0
            for i in 0..<17 {
                let subStrIndex = Int((idCardNumber as NSString).substring(with: NSRange(location: i, length: 1))) ?? 0
                let idCardWiIndex = Int(idCardWiArray[i]) ?? 0
                
                idCardWiSum = idCardWiSum + subStrIndex * idCardWiIndex
            }
            //计算出校验码所在数组的位置
            let idCardMod = idCardWiSum % 11;
            //得到最后一位身份证号码
            let idCardLast = (idCardNumber as NSString).substring(with: NSRange(location: 17, length: 1))
            //如果等于2，则说明校验码是10，身份证号码最后一位应该是X
            if idCardMod == 2 {
                if idCardLast == "X" || idCardLast == "x" {
                    return flag
                } else {
                    flag = false
                    return flag
                }
            } else {
                //用计算出的验证码与最后一位身份证号码匹配，如果一致，说明通过，否则是无效的身份证号码
                if idCardLast == idCardYArray[idCardMod] {
                    return flag
                } else {
                    flag = false
                    return flag
                }
            }
        } else {
            // 不是18位
            flag = false
            return flag
        }
    } else {
        return flag
    }
}

// MARK: - 校验邮箱格式
/// 校验邮箱格式
/// - Parameter email: 邮箱
/// - Returns: 结果
public func validateEmail(_ email: String) -> Bool {
    do {
        let regex = try NSRegularExpression(pattern: "^[A-Za-z0-9._%+-]+@[A-Za-z0-9._%+-]+\\.[A-Za-z0-9._%+-]+$", options: .caseInsensitive)
        let numberOfMatches = regex.numberOfMatches(in: email, options: .reportProgress, range: NSRange(location: 0, length: email.count))
        if numberOfMatches != 0 {
            return true
        } else {
            return false
        }
    } catch {
        return false
    }
}

// MARK: - 是否为数字以及字母合集
public func validateIsNumberLetter(_ targetStr: String) -> Bool {
    let numberRegex = NSPredicate(format: "SELF MATCHES %@",  "^.*[0-9]+.*$")
    let letterRegex = NSPredicate(format:"SELF MATCHES %@","^.*[A-Za-z]+.*$")
    if numberRegex.evaluate(with: targetStr) && letterRegex.evaluate(with: targetStr) {
        return true
    } else {
        return false
    }
}

// MARK: - 是否为数字合集
public func validateIsNumber(_ targetStr: String) -> Bool {
    let scan: Scanner = Scanner(string: targetStr)
    var val:Int = 0
    return scan.scanInt(&val) && scan.isAtEnd
}

// MARK: - 是否为字母合集
public func validateIsLetter(_ targetStr: String) -> Bool {
    let letterRegex = NSPredicate(format:"SELF MATCHES %@", "^[A-Za-z]*$")
    if letterRegex.evaluate(with: targetStr) {
        return true
    } else {
        return false
    }
}

// MARK: - 是否为符号合集
public func validateIsSymbol(_ targetStr: String) -> Bool {
    let symbolRegex = NSPredicate(format:"SELF MATCHES %@", "^[^A-Za-z0-9]*$")
    if symbolRegex.evaluate(with: targetStr) {
        return true
    } else {
        return false
    }
}

// MARK: - 是否含有中文
public func validateExistChinese(_ targetStr: String) -> Bool {
    for (_, value) in targetStr.enumerated() {
        if ("\u{4E00}" <= value  && value <= "\u{9FA5}") {
            return true
        }
    }
    return false
}

// MARK: - 校验手机号码格式
public func validatePhoneNumber(_ phoneNumber: String) -> Bool {
    if phoneNumber.count != 11 {
        return false
    }
    let regextestall = NSPredicate(format: "SELF MATCHES %@", "^1[0-9]{10}")
    if regextestall.evaluate(with: phoneNumber) {
        return true
    } else {
        return false
    }
}

// MARK: - 检测相册权限
public func checkPhotoLibraryAuthorizationStatus() -> Bool {
    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
        HUDTool.showText("该设备不支持相册")
        DLog("该设备不支持相册")
        return false
    }
    let status = PHPhotoLibrary.authorizationStatus()
    if status == .restricted || status == .denied || status == .notDetermined {
        showSettingAlertStr(tipStr: "请在iPhone的\"设置-隐私-照片\"选项中允许访问你的手机相册")
        return false
    } else {
        return true
    }
}

// MARK: - 检测相机权限
public func checkCameraAuthorizationStatus() -> Bool {
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
        HUDTool.showText("该设备不支持拍照")
        DLog("该设备不支持拍照")
        return false
    }
    let status = AVCaptureDevice.authorizationStatus(for: .video)
    if status == .restricted || status == .denied || status == .notDetermined {
        showSettingAlertStr(tipStr: "请在iPhone的\"设置-隐私-相机\"中允许访问你的相机")
        return false
    } else {
        return true
    }
}

// MARK: - 使手机震动
public func vibrate() {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
}

public func judgeAppVersion(_ appId: String?,
                            _ bundleId: String?,
                            block: @escaping (_ currentVersion: String,
                                              _ storeVersion: String,
                                              _ openUrl: String,
                                              _ isUpdate: Bool) -> ()) {
    
    let infoDic = Bundle.main.infoDictionary!
    var currentVersion = infoDic["CFBundleVersion"] as! String
    //
    var request: URLRequest?
    if appId != nil {
        let url = String(format: "http://itunes.apple.com/cn/lookup?id=%@", appId!)
        request = URLRequest(url: URL.init(string: url)!)
        DLog("【1】当前为APPID检测，您设置的APPID为:\(appId!)  当前版本号为:\(currentVersion)")
    } else if bundleId != nil {
        let url = String(format: "http://itunes.apple.com/lookup?bundleId=%@&country=cn", bundleId!)
        request = URLRequest(url: URL.init(string: url)!)
        DLog("【1】当前为BundelId检测，您设置的bundelId为:\(bundleId!)  当前版本号为:\(currentVersion)")
    } else {
        let currentBundelId = infoDic["CFBundleIdentifier"]
        let url = String(format: "http://itunes.apple.com/lookup?bundleId=%@&country=cn", currentBundelId as! CVarArg)
        request = URLRequest(url: URL.init(string: url)!)
        DLog("【1】当前为自动检测，您设置的bundelId为:\(currentBundelId!)  当前版本号为:\(currentVersion)")
    }
    let session = URLSession.shared
    let task = session.dataTask(with: request!) { data, response, error in
        if error != nil {
            DLog("【2】检测失败，原因：\(error!)")
            DispatchQueue.main.async {
                block(currentVersion, "", "", false)
            }
            return;
        }
        // 成功
        DispatchQueue.main.async {
            if data != nil {
                do {
                    let appInfoDic = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as! NSDictionary
                    if let resultCount = appInfoDic["resultCount"] {
                        if resultCount as! Int == 0 {
                            DLog("【2】检测出未上架的APP或者查询不到")
                            block(currentVersion, "", "", false);
                            return
                        }
                    }
                    //
                    let results = appInfoDic["results"] as! NSArray
                    let appDic = results[0] as! NSDictionary
                    DLog("【3】苹果服务器返回的检测结果：\n appId = \(appDic["artistId"]!) \n bundleId = \(appDic["bundleId"]!) \n 开发账号名字 = \(appDic["artistName"]!) \n 商店版本号 = \(appDic["version"]!) \n 应用名称 = \(appDic["trackName"]!) \n 打开连接 = \(appDic["trackViewUrl"]!)")
                    
                    var appStoreVersion = appDic["version"] as! String
                    currentVersion = (currentVersion as NSString).replacingOccurrences(of:".", with:"")
                    
                    if currentVersion.count == 2 {
                        appStoreVersion = appStoreVersion + "0"
                    } else if currentVersion.count == 1 {
                        appStoreVersion = appStoreVersion + "00"
                    }
                    
                    if Float(currentVersion) ?? 0 < Float(appStoreVersion) ?? 0 {
                        DLog("需要更新")
                        block(currentVersion, appDic["version"] as! String, appDic["trackViewUrl"] as! String, true)
                    } else {
                        DLog("不需要更新")
                        block(currentVersion, appDic["version"] as! String, appDic["trackViewUrl"] as! String, false)
                    }
                    
                } catch {
                    DLog("【2】检测出未上架的APP或者查询不到")
                    block(currentVersion, "", "", false)
                    return
                }
            }
        }
    }
    task.resume()
}

// MARK: - 闪烁动画
/// 闪烁动画
/// - Parameters:
///   - fromValue: 起始值
///   - toValue: 结束值
///   - repeatCount: 重复次数
///   - duration: 时长
/// - Returns: 动画
public func animateOpacity(_ fromValue: CGFloat,
                           _ toValue: CGFloat,
                           _ repeatCount: CGFloat,
                           _ duration: CGFloat) -> CABasicAnimation {
    let animation                   = CABasicAnimation(keyPath: "opacity")
    animation.fromValue             = fromValue
    animation.toValue               = toValue
    animation.autoreverses          = true
    animation.duration              = CFTimeInterval(duration)
    animation.repeatCount           = Float(repeatCount)
    animation.isRemovedOnCompletion = false
    animation.fillMode              = .forwards
    return animation
}

// MARK: - 缩放动画
/// 缩放动画
/// - Parameters:
///   - fromValue: 起始值
///   - toValue: 结束值
///   - repeatCount: 重复次数
///   - duration: 时长
/// - Returns: 动画
public func animateScale(_ fromValue: CGFloat,
                         _ toValue: CGFloat,
                         _  repeatCount: CGFloat,
                         _ duration: CGFloat) -> CABasicAnimation {
    let animation                   = CABasicAnimation(keyPath: "transform.scale")
    animation.fromValue             = fromValue
    animation.toValue               = toValue
    animation.autoreverses          = true
    animation.duration              = CFTimeInterval(duration)
    animation.repeatCount           = Float(repeatCount)
    animation.isRemovedOnCompletion = false
    animation.fillMode              = .forwards
    return animation
}

// MARK: - 旋转动画
/// 闪烁动画
/// - Parameters:
///   - fromValue: 起始值
///   - toValue: 结束值
///   - repeatCount: 重复次数
///   - duration: 时长
/// - Returns: 动画
public func animateRotation(_ fromValue: CGFloat,
                            _ toValue: CGFloat,
                            _ repeatCount: Int,
                            _ duration: CGFloat) -> CABasicAnimation {
    let animation                   = CABasicAnimation(keyPath: "transform.rotation.z")
    animation.fromValue             = fromValue
    animation.toValue               = toValue
    animation.autoreverses          = true
    animation.duration              = CFTimeInterval(duration)
    animation.isRemovedOnCompletion = false
    animation.fillMode              = .forwards
    return animation
}

// MARK: - 格式化价钱字符串
/// 格式化价钱字符串
/// - Parameter targetString: 价钱
/// - Returns: 结果
public func stringToPrice(_ targetString: String) -> String {
    let numberFormatter            = NumberFormatter()
    numberFormatter.positiveFormat = "###,##0.00;"
    let priceStr                   = numberFormatter.string(from: NSNumber(value: Int(targetString) ?? 0))
    return priceStr ?? "0"
}

// MARK: - 历史记录相关
/// 存储历史记录
/// - Parameters:
///   - arr: 要存储的数据
///   - fileName: 文件夹名字，需要带.plist
public func DMSaveHistorydata(arr: [[String: Any]], fileName: String) {
    
    let path     = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
    if let filePath = (path?.appending("/\(fileName)")) {
        let dataArr: NSArray = arr as NSArray
        dataArr.write(toFile: filePath, atomically: true)
//        DLog(NSArray.init(contentsOfFile: filePath))
    }
}

/// 得到存储的历史记录
/// - Parameter fileName: 文件夹名字，需要带.plist
public func DMGetHistoryData(fileName: String) -> [Any] {
    
    let path     = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
    if let filePath = (path?.appending("/\(fileName)")) {
        if let arr = NSArray.init(contentsOfFile: filePath) {
            return arr as! [[String: Any]]
        } else {
            return []
        }
    } else {
        return []
    }
}


// MARK: 权限相关

///相机权限
func isRightCamera() -> Bool {
    
    let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
    return authStatus != .restricted && authStatus != .denied
}

// MARK: - 私有方法
/// 提示框
/// - Parameter tipStr: 文字
private func showSettingAlertStr(tipStr: String) {
    let alert = WLAlertView().alertView(withIsLand: false, image: nil, title: "提示", message: tipStr, cancelButtonTitle: "取消", otherButtonTitles: ["前往设置"]) { index, _ in
        if index == 1 {
            let app = UIApplication.shared
            if let url = URL.init(string: UIApplication.openSettingsURLString) {
                if app.canOpenURL(url) {
                    app.open(url, options: [:]) { _ in
                        
                    }
                }
            }
        }
    }
    alert?.setButtionTitleColor?(TextColor_DarkGray, index: 0)
    alert?.show?()
}

