//
//  BaseViewController.swift
//  CommonTools
//  所有控制器的基类
//  Created by Mac on 2021/9/26.
//

import UIKit

class BaseViewController: UIViewController {
    // MARK: - 外部变量
    //导航栏文字颜色
    public var navTextColor: UIColor?
    //是否允许透明
    public var navTranslucent: Bool = false
    //隐藏底部细线
    public var navShadowImageHidden: Bool = true
    //导航栏背景颜色
    public var navBackGroundColor: UIColor?
    //导航栏渲染风格
    public var navBarStyle: UIBarStyle?
    //导航栏图标渲染颜色
    public var navTintColor: UIColor?
    //是否为浅色状态栏
    public var statusBarIsLight: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        //背景色
        view.backgroundColor                  = .white
        //返回箭头文字
        let backItem                          = UIBarButtonItem.init()
        backItem.title                        = ""
        self.navigationItem.backBarButtonItem = backItem
        self.modalPresentationStyle           = .fullScreen
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let naviBar                  = self.navigationController?.navigationBar
        //设置文字大小及颜色
        naviBar?.titleTextAttributes = [.font: UIFont(name: "PingFangSC-Medium", size: RW(18)) ?? BoldFont(18), .foregroundColor: TextColor_DarkGray]
        //设置不透明
        naviBar?.isTranslucent       = false
        //设置背景图
        naviBar?.setBackgroundImage(nil, for: .default)
        //设置渲染风格
        naviBar?.barStyle            = .default
        //图标的渲染颜色
        naviBar?.tintColor           = TextColor_DarkGray
        //navBar的背景颜色
        naviBar?.barTintColor        = HexRGB(0xfafafa)
        //设置阴影
        naviBar?.shadowImage         = UIImage()

        //分割线
        let lineView                 = UIView.init(frame: CGRect(x: 0, y: 44, width: kScreenWidth, height: 0.5))
        lineView.backgroundColor     = APP_LineColor
        naviBar?.insertSubview(lineView, at: 0)
        
        //导航栏大标题
        naviBar?.prefersLargeTitles = false
        
        //设置文字大小颜色
        if self.navTextColor != nil {
            naviBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: self.navTextColor!, NSAttributedString.Key.font: UIFont.init(name: "PingFangSC-Medium", size: RW(18))!]
        }
        
        //是否允许透明效果
        if self.navTranslucent == true {
            naviBar?.isTranslucent = true
        }
        
        //隐藏底部细线
        if navShadowImageHidden == true{
            lineView.isHidden = true
        }
        
    }
    
    ///状态栏
    func preferredStatusBarStyle() -> UIStatusBarStyle{
        if self.statusBarIsLight == true {
            return .lightContent
        }
        return .default
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //这里操作参考国内版代码
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    deinit {
        DLog("\(String(describing: self.navigationItem.title))界面被销毁")
    }

}
