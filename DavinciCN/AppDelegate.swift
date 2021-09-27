//
//  AppDelegate.swift
//  DavinciCN
//
//  Created by Mac on 2021/9/24.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        setRootViewController()
        return true
    }

    // MARK: - setRootViewController
    private func setRootViewController() {
        self.window                     = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = nil
        let rootVC                      = BaseNavigationController.init(rootViewController: HomeViewController())
        self.window?.rootViewController  = rootVC
        self.window?.makeKeyAndVisible()
    }
    
    // MARK: - 横竖屏相关方法
    private var orientation: UIInterfaceOrientationMask = UIInterfaceOrientationMask.portrait
    /// 设置屏幕是否允许旋转
    /// - Parameters:
    ///   - allowRoation: 是否允许旋转
    ///   - orientation: 旋转方向
    public func setOrientaition(allowRoation: Bool, orientation: UIInterfaceOrientationMask) {
        self.orientation = orientation
        if allowRoation == false {
            self.orientation = .portrait
            UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
        } else {
            switch orientation {
            case .landscapeLeft:
                UIDevice.current.setValue(UIDeviceOrientation.landscapeLeft.rawValue, forKey: "orientation")
                break
            case.landscapeRight:
                UIDevice.current.setValue(UIDeviceOrientation.landscapeRight.rawValue, forKey: "orientation")
                break
            default:
                break
            }
        }
    }
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
        return self.orientation
    }
}

