//
//  DMHUDTool.swift
//  DavinciMotor
//  加载loading框
//  Created by Mac on 2021/8/16.
//

import UIKit

class HUDTool {
    
    // MARK: - Loading
    
    static func showLoading() {
        self.show(status: .indeterminate, text: nil, view: nil, delay: nil)
    }
    
    static func showLoading(_ text: String) {
        self.show(status: .indeterminate, text: text, view: nil, delay: nil)
    }

    static func showLoading(_ text: String,
                            _ delay: TimeInterval?) {
        self.show(status: .indeterminate, text: text, view: nil, delay: delay)
    }
    
    static func showLoading(_ text: String?,
                            _ view: UIView?,
                            _ delay: TimeInterval?) {
        self.show(status: .indeterminate, text: text, view: view, delay: delay)
    }
    
    // MARK: - Text
    
    static func showText(_ text: String) {
        self.show(status: .text, text: text, view: nil, delay: nil)
    }
    
    static func showText(_ text: String,
                         _ delay: TimeInterval? = nil) {
        self.show(status: .text, text: text, view: nil, delay: delay)
    }
    
    static func showText(_ text: String?,
                         _ view: UIView?,
                         _ delay: TimeInterval?) {
        self.show(status: .text, text: text, view: view, delay: delay)
    }
    
    // MARK: - Progress
    
    static var progressHud: MBProgressHUD? = nil
    static func showProgress(progress: Float, title: String = "上传中...") {
        DispatchQueue.main.async {
            
            if self.progressHud == nil, let h = MBProgressHUD.forView(UIApplication.shared.keyWindow!) {
                self.progressHud = h
            }else {
                self.progressHud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: false)
            }
            self.progressHud!.mode       = .determinate
            self.progressHud!.label.text = title
            self.progressHud!.progress   = progress
        }
    }
    
    // MARK: - Hide
    
    static func hideAllBeforeShow() {
        while true {
            if !MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: false) {
                return
            }
        }
    }
    
    static func hideAll() {
        DispatchQueue.main.async {
            while true {
                if !MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: false) {
                    return
                }
            }
        }
    }
    
    static func hideAll(view: UIView) {
        DispatchQueue.main.async {
            while true {
                if !MBProgressHUD.hide(for: view, animated: false) {
                    return
                }
            }
        }
    }
    
    // MARK: - 私有方法
    
    static private func show(status: MBProgressHUDMode,
                     text: String?,
                     view: UIView?,
                     delay: TimeInterval?) {
        DispatchQueue.main.async {
            hideAllBeforeShow()
            let hud                       = MBProgressHUD.showAdded(to: view ?? UIApplication.shared.keyWindow!, animated: true)
            hud.mode                      = status
            hud.contentColor              = TextColor_DarkGray
            hud.label.textColor           = TextColor_DarkGray
            hud.label.font                = Font_Max_Light
            hud.backgroundView.style      = .solidColor
            hud.margin                    = 15
            hud.backgroundView.color      = RGBColorA(0, 0, 0, 0.1)
            hud.minSize                   = CGSize(width: 44, height: 44)
            hud.removeFromSuperViewOnHide = true
            hud.isSquare                  = false
            hud.minShowTime               = 1.0
            hud.isUserInteractionEnabled  = false
            
            switch status {
            case .indeterminate:
                hud.label.text = text ?? ""
                if let d = delay {
                    hud.hide(animated: true, afterDelay: d)
                }
                break
            case .text:
                hud.bezelView.style           = .solidColor
                hud.bezelView.backgroundColor = HexRGBAlpha(0x000000,0.8)
                hud.detailsLabel.textColor    = UIColor.white
                hud.detailsLabel.font         = Font_Mid_Light
                hud.detailsLabel.text         = text
                hud.hide(animated: true, afterDelay: delay ?? 2.0)
                break
            default:
                break
            }
        }
    }
    
}

