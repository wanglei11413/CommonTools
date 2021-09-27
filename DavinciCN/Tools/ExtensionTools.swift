//
//  ExtensionTools.swift
//  DavinciCN
//  相关拓展
//  Created by Mac on 2021/9/24.
//

import Foundation

extension String {
    
    // MARK: - range转NSRange
    /// range转NSRange
    /// - Parameter range: range
    /// - Returns: NSRange
    func nsRange(from range: Range<String.Index>) -> NSRange {
        return NSRange(range, in: self)
    }
    
    // MARK: - 蓝牙十六进制数据转字符串
    func decimalToHexadecimal() -> String {
        let sss : Int = Int(self)!
        let stringSixteen = "\(String(format: "%02lx", sss))"
        return stringSixteen
    }
    
    // MARK: - 返回是否为json字符串
    /// 返回是否为json字符串
    func isjsonStyle() -> Bool {
        let jsondata = self.data(using: .utf8)
        do {
            try JSONSerialization.jsonObject(with: jsondata!, options: .mutableContainers)
            return true
        } catch {
            return false
        }
    }
    
    // MARK: - 是否为单个emoji表情
    /// 是否为单个emoji表情
    var isSingleEmoji: Bool {
        return count == 1 && containsEmoji
    }

    // MARK: - 包含emoji表情
    /// 包含emoji表情
    var containsEmoji: Bool {
        return contains{ $0.isEmoji }
    }

    // MARK: - 只包含emoji表情
    /// 只包含emoji表情
    var containsOnlyEmoji: Bool {
        return !isEmpty && !contains{ !$0.isEmoji }
    }

    // MARK: - 提取emoji表情字符串
    /// 提取emoji表情字符串
    var emojiString: String {
        return emojis.map { String($0) }.reduce("",+)
    }

    // MARK: - 提取emoji表情数组
    /// 提取emoji表情数组
    var emojis: [Character] {
        return filter{ $0.isEmoji }
    }

    // MARK: - 提取单元编码标量
    /// 提取单元编码标量
    var emojiScalars: [UnicodeScalar] {
        return filter{ $0.isEmoji }.flatMap{ $0.unicodeScalars }
    }
}

extension Character {
    
    // MARK: - 是否为emoji表情
    /// 是否为emoji表情
    var isEmoji: Bool {
        return isSimpleEmoji || isCombinedIntoEmoji
    }
    
    /// 简单的emoji是一个标量，以emoji的形式呈现给用户
    var isSimpleEmoji: Bool {
        guard let firstProperties = unicodeScalars.first?.properties
        else {
            return false
        }
        return unicodeScalars.count == 1 &&
            (firstProperties.isEmojiPresentation ||
                firstProperties.generalCategory == .otherSymbol)
    }

    /// 检查标量是否将合并到emoji中
    var isCombinedIntoEmoji: Bool {
        return unicodeScalars.count > 1 &&
            unicodeScalars.contains { $0.properties.isJoinControl || $0.properties.isVariationSelector }
    }
}

extension UIView {
    
    // MARK: - 切view的圆角
    /// 切view的圆角
    /// - Parameters:
    ///   - corner: 圆角方向
    ///   - radii: 大小
    ///   - frame: frame
    ///   - haveShadow: 是否有阴影
    func configRectCorner(corner: UIRectCorner,
                          radii: CGSize,
                          frame: CGRect,
                          haveShadow: Bool) {
        let maskPath            = UIBezierPath.init(roundedRect: frame, byRoundingCorners: corner, cornerRadii: radii)
        let maskLayer           = CAShapeLayer.init()
        maskLayer.frame         = self.bounds
        maskLayer.path          = maskPath.cgPath
        if haveShadow {
            maskLayer.shadowColor   = RGBColorA(0, 0, 0, 0.4).cgColor
            maskLayer.shadowOffset  = CGSize(width: 0, height: 0)
            maskLayer.shadowRadius  = 10
            maskLayer.shadowOpacity = 1
        }
        self.layer.mask         = maskLayer
    }
    
    /// 设置阴影(颜色、偏移量、透明度、半径)
    /// - Parameters:
    ///   - color: 颜色
    ///   - opacity: 透明度
    ///   - radius: 半径
    ///   - offSet: 偏移量
    func configgShadow(color: UIColor,
                       opacity: Float,
                       radius: CGFloat,
                       offSet: CGSize) {
        self.layer.shadowColor   = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius  = radius
        self.layer.shadowOffset  = offSet
    }
    
    /// 设置圆角边框
    /// - Parameters:
    ///   - radius: 圆角半径
    ///   - borderWidth: 边框宽度
    ///   - borderColor: 边框颜色
    public func configBorderRadius(radius: CGFloat,
                                   borderWidth: CGFloat,
                                   borderColor: UIColor) {
        self.layer.cornerRadius  = radius
        self.layer.masksToBounds = true
        self.layer.borderWidth   = borderWidth
        self.layer.borderColor   = borderColor.cgColor
    }
}

extension Array {
    
    // MARK: - 防止数组越界
    // 防止数组越界
    subscript(index: Int, safe: Bool) -> Element? {
        if safe {
            if self.count > index {
                return self[index]
            } else {
                return nil
            }
        } else {
            return self[index]
        }
    }
    
}

extension UIImage {
    
    // MARK: - 更改图片颜色
    /// 更改图片颜色
    /// - Parameter color: 要更改的颜色
    /// - Returns: 图片
    public func imageWithTintColor(color : UIColor) -> UIImage{
        UIGraphicsBeginImageContext(self.size)
        color.setFill()
        let bounds = CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height)
        UIRectFill(bounds)
        self.draw(in: bounds, blendMode: CGBlendMode.destinationIn, alpha: 1.0)
        
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage!
    }
    
    // MARK: - 根据传入的宽度生成一张按照宽高比压缩的新图片
    /// 根据传入的宽度生成一张按照宽高比压缩的新图片
    /// - Parameter width: 宽度
    /// - Returns: 图片
    func imageWithScale(width:CGFloat) -> UIImage{
        //1.根据 宽度 计算高度
        let height = width * size.height / size.width
        //2.按照宽高比绘制一张新的图片
        let currentSize = CGSize.init(width: width, height: height)
        UIGraphicsBeginImageContext(currentSize)  //开始绘制
         draw(in: CGRect.init(origin: CGPoint.zero, size: currentSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()  //结束上下文
        return newImage!
    }
    
    // MARK: - 将图片修改为带边框的圆形图片
    /// 将图片修改为带边框的圆形图片
    /// - Parameters:
    ///   - borderWidth: 表框宽度
    ///   - borderColor: 边框颜色
    /// - Returns: 图片
    func imageChangeToCircle(borderWidth: CGFloat,
                             borderColor: UIColor) -> UIImage {
        let oriW = size.width, oriH = size.height
        var ovalWidth = oriW, ovalHeight = oriH
        if borderWidth > 0 {
            ovalWidth  = oriW + 2 * borderWidth
            ovalHeight = oriH + 2 * borderWidth
        }
        UIGraphicsBeginImageContextWithOptions(CGSize(width: ovalWidth, height: ovalHeight), false, 0)
        let biggerOval = UIBezierPath(rect: CGRect(x: 0, y: 0, width: ovalWidth, height: ovalHeight))
        borderColor.setFill()
        biggerOval.fill()
        //set the clip rect
        let clipPath = UIBezierPath(rect: CGRect(x: borderWidth, y: borderWidth, width: oriW, height: oriH))
        clipPath.addClip()
        // drwa image
        self.draw(at: CGPoint(x: borderWidth, y: borderWidth))
        guard let clipImage = UIGraphicsGetImageFromCurrentImageContext()
        else {
            return UIImage()
        }
        UIGraphicsEndImageContext()
        return clipImage
    }
}

extension UIButton {
    
    // MARK: - 带有倒计时的button
    /// 带有倒计时的button
    /// - Parameters:
    ///   - time: 倒计时时间
    ///   - title: 未开始倒计时的title
    ///   - subTitle: 倒计时中的子title，如 分、秒
    ///   - agaleTitle: 点击一次后显示的文字
    ///   - mainColor: 还没倒计时的颜色
    ///   - countColor: 倒计时中的颜色
    ///   - againColor: 点击一次后的文字颜色
    ///   - titleFont: 文字大小
    ///   - enable: 是否可点击
    ///   - timeEndBlock: 回调
    /// - Returns: 按钮
    func startCountTime(time: Double,
                        title: String,
                        subTitle: String,
                        agaleTitle: String,
                        mainColor: UIColor,
                        countColor: UIColor,
                        againColor: UIColor,
                        titleFont: UIFont,
                        enable: Bool,
                        timeEndBlock: @escaping () -> ()) {
        
        self.backgroundColor = mainColor
        self.titleLabel?.font = titleFont
        // 倒计时时间
        var timeOut = time
        // 创建定时器
        GCDTimerTool.share.scheduledDispatchTimer(withName: "StartCountTimeTimer", timeInterval: timeOut, queue: DispatchQueue.main, repeats: false) {
            [weak self] in
            guard let `self` = self else {return}
            // 倒计时结束关闭倒计时
            if timeOut <= 0 {
                GCDTimerTool.share.destoryTimer(withName: "StartCountTimeTimer")
                self.isUserInteractionEnabled = true
                self.setTitleColor(againColor, for: .normal)
                self.setTitle(agaleTitle, for: .normal)
                timeEndBlock()
            } else {
                // 开始计时
                let allTime = time + 1
                let seconds = timeOut.truncatingRemainder(dividingBy: allTime)
                let timeStr = String(format: "%d", seconds)
                DispatchQueue.main.async {
                    self.isUserInteractionEnabled = enable
                    self.setTitleColor(countColor, for: .normal)
                    if subTitle.isEmpty {
                        self.setTitle("重新发送(\(timeStr)", for: .normal)
                    } else {
                        self.setTitle("\(timeStr)\(subTitle)后重新发送", for: .normal)
                    }
                }
                timeOut = timeOut - 1
            }
        }
    }
}
