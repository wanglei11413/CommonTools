//
//  BaseModel.swift
//  DavinciMotor
//  Model 基类
//  Created by Mac on 2021/8/17.
//

import UIKit

class BaseModel: HandyJSON {
    
    required init() {}
    
    ///返回信息
    var message: String = ""
    ///请求码
    var code: Int?
    ///数据
    var data: Any?
}
