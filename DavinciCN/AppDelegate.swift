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
        let rootVC                      = BaseViewController()
        self.window?.rootViewController  = rootVC
        self.window?.makeKeyAndVisible()
    }
}

