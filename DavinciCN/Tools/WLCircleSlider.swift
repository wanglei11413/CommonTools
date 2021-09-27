//
//  WLCircleSlider.swift
//  DavinciMotor
//  绘制半圆的slider
//  Created by Mac on 2021/9/9.
//

import UIKit

/// 代理方法
@objc protocol WLCircleSliderDelegate: NSObjectProtocol {
    /// 值改变
    /// - Parameter value: 值
    @objc optional func sliderValueChanged(sender: WLCircleSlider, value: Int)
    
    /// 结束滑动
    /// - Parameter value: 值
    @objc optional func sliderValueChangedEnd(sender: WLCircleSlider, value: Int)
}

class WLCircleSlider: UIControl {
    // MARK: - public属性
    /// 起始角度数
    var startAngle: Int = 0
    /// 结束角度数
    var endAngle: Int = 0
    /// 线条宽度
    var lineWidth: CGFloat = 5
    /// 灰线颜色
    var trackColor: UIColor = .gray
    /// 填充线颜色
    var trackFilledColor: UIColor = .gray
    /// thumb大小
    var thumbSize: CGFloat = 0
    /// 按钮颜色
    var thumbColor: UIColor = .blue
    // 代理
    var delegate: WLCircleSliderDelegate?
    /// 最小值
    var minimumValue: Int = 0
    /// 最大值
    var maximumValue: Int = 0
    /// 当前值
    var currentValue: Int = 0 {
        didSet {
            let aaa = CGFloat(360 - startAngle + endAngle) / CGFloat(maximumValue) * CGFloat(currentValue)
            angle = startAngle + Int(aaa)
        }
    }
    var shadowColor: UIColor = .clear {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    // MARK: - private属性x
    private var angle: Int      = 0
    private var radius: CGFloat = 0
    // MARK: - END

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        self.clipsToBounds            = false
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - privates methods
    
    private func makeUI() {
        self.backgroundColor = .clear
        radius = self.frame.size.height/2 - lineWidth - thumbSize - 5
    }
    
    // MARK: - draw
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        /// 画底部灰线
        let startA = CGFloat(Double.pi)/180*CGFloat(startAngle)
        let endA   = CGFloat(Double.pi)/180*CGFloat(endAngle)
        let ctx    = UIGraphicsGetCurrentContext()
        ctx?.addArc(center: self.center, radius: radius, startAngle: startA, endAngle: endA, clockwise: false)
        trackColor.setStroke()
        ctx?.setLineWidth(lineWidth)
        ctx?.setLineCap(.butt)
        ctx?.drawPath(using: .stroke)
        // 画填充线
        ctx?.addArc(center: self.center, radius: radius, startAngle: startA, endAngle: CGFloat(Double.pi)/180*CGFloat(angle), clockwise: false)
        ctx?.setShadow(offset: CGSize(width: 0, height: 0), blur: 6, color: shadowColor.cgColor)
        trackFilledColor.setStroke()
        ctx?.setLineWidth(lineWidth)
        ctx?.setLineCap(.butt)
        ctx?.drawPath(using: .stroke)
        // 设置阴影
        // 画thumb
        ctx?.saveGState()
        let handleCenter = pointFromAngle(angleInt: angle)
        thumbColor.set()
        ctx?.fillEllipse(in: CGRect(x: handleCenter.x-thumbSize/2 + lineWidth/2, y: handleCenter.y-thumbSize/2 + lineWidth/2, width: thumbSize, height: thumbSize))
        ctx?.restoreGState()
    }
    
    // MARK: - Tracking相关
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        sendActions(for: .editingDidBegin)
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        //用于排除点在圆外面点与圆心半径80以内的点
        let lastPoint = touch.location(in: self)
        if (lastPoint.x >= -10 && lastPoint.x <= self.frame.size.height) &&
            (lastPoint.y >= -10 && lastPoint.y <= self.frame.size.height){
            //
//            if lastPoint.x <= 57.5 || lastPoint.x >= 217.5 || lastPoint.y <= 57.5  || lastPoint.y >= 217.5{
                moveHandle(point: lastPoint)
//            }
        }
        sendActions(for: .valueChanged)
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        sendActions(for: .editingDidEnd)
        
        if delegate != nil {
            delegate!.sliderValueChangedEnd?(sender: self, value: currentValue)
        }
    }
    
    // MARK: - 相关方法
    
    /// 移动thumb的位置
    /// - Parameter point: 要移到的位置
    private func moveHandle(point: CGPoint) {
        let centerPoint         = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        let currentAngleDouble = floor(angleFromNorth(p1: centerPoint, p2: point))
        let currentAngle        = Int(currentAngleDouble)
        // 计算当前的value
        currentValue = valueFromAngle(angle: currentAngle)
        if delegate != nil {
            delegate!.sliderValueChanged?(sender: self, value: currentValue)
        }
        // 滑动到最大值
        if currentAngle > endAngle && currentAngle < startAngle {
            return
        } else {
            if currentAngle <= endAngle {
                angle = currentAngle + 360
            } else {
                angle = currentAngle
            }
        }
        self.setNeedsDisplay()
    }
    
    /// 根据angle得到中心坐标
    /// - Parameter angleInt: angle
    /// - Returns: 坐标
    private func pointFromAngle(angleInt: Int) -> CGPoint {
        let centerPoint = CGPoint(x: self.frame.size.width/2 - lineWidth/2, y: self.frame.size.height/2 - lineWidth/2)
        var result      = CGPoint()
        result.x        = round(centerPoint.x + radius * CGFloat(cos(ToRad(deg: CGFloat(angleInt)))))
        result.y        = round(centerPoint.y + radius * CGFloat(sin(ToRad(deg: CGFloat(angleInt)))))
        return result
    }
    
    /// 根据当前手指位置计算角度
    /// - Parameters:
    ///   - p1: p1
    ///   - p2: p2
    /// - Returns: 角度
    private func angleFromNorth(p1: CGPoint, p2: CGPoint) -> Double {
        var v      = CGPoint(x: p2.x - p1.x, y: p2.y - p1.y)
        let vmag   = sqrt(Double(SQR(x: Int(v.x)) + SQR(x: Int(v.y))))
        var result = 0.0
        v.x        = v.x / CGFloat(vmag)
        v.y        = v.y / CGFloat(vmag)
        let radius = atan2(v.y, v.x)
        result     = ToDeg(rad: radius)
        return result >= 0 ? result : result + 360.0
    }
    
    /// 根据当前角度得到当前对应的value值
    /// - Parameter angle: 当前角度
    /// - Returns: value值
    private func valueFromAngle(angle: Int) -> Int {
        if angle > endAngle && angle < startAngle {
            return 0
        }
        var angle1 = angle - startAngle
        // 如果angle1小于0了，代表已经滑动了一圈
        if angle1 < 0 {
            // 此时的角度应该如下
            angle1 = 360 - startAngle + angle
        }
        let value = angle1*maximumValue/(360 - startAngle + endAngle)
        return value
    }
    
    private func ToRad(deg: CGFloat) -> Double {
        return Double.pi * Double(deg) / 180.0
    }
    private func ToDeg(rad: CGFloat) -> Double {
        return 180.0 * Double(rad) / Double.pi
    }
    private func SQR(x: Int) -> Int {
        return x * x
    }
}
