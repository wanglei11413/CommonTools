//
//  DMApi.swift
//  DavinciMotor
//  接口请求API
//  Created by Mac on 2021/8/16.
//

import UIKit

// MARK: 环境设置

enum Environment {
    case product //生产
    case developer //测试
}

let env = Environment.developer

struct API {
    
    // MARK: baseUrl
    
    static var base:String = {
        switch env {
        case .product:
            return ""
        case .developer:
            return ""
        }
    }()
    
    
    // MARK: 项目中使用到的api
    
    /// 接口地址
    static let carInfo = ""
}








