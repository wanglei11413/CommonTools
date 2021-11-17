//
//  BaseNavigationController.swift
//  DavinciMotor
//  导航栏
//  Created by Mac on 2021/8/9.
//

import UIKit

class BaseNavigationController: RTRootNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //重写导航栏推送方法，跳转时隐藏底部tabbar
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewController.hidesBottomBarWhenPushed = true
        super.pushViewController(viewController, animated: animated)
    }
}
