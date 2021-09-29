//
//  BaseModel.swift
//  DavinciMotor
//  Model 基类
//  Created by Mac on 2021/8/17.
//

class BaseModel: HandyJSON {
    
    required init() {}
    
    ///返回信息
    var message: String = ""
    ///请求码
    var code: Int?
    
    
    ///数据
    var
        data: Any?
    /// status信息
    var status: StatusModel?
}

/// status模型
struct StatusModel: HandyJSON {
    var code: String?
    var errorCode: String?
    var errorDescription: String?
}
