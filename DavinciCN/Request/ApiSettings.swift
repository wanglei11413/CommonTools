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
            return "http://nats.intestcar.com:8329"
        case .developer:
            return "https://api-cn-dev.davincimotor.com/"
//            return "http://122.9.2.216:3080"
        }
    }()
    
    
    // MARK: 项目中使用到的api
    
    ///车况数据  POST
    static let carInfo = "/web-api/car/vehicle_query"
    
    /// 搜索充电桩
    static let chargeList = "/web-api/map/charger-query-nokeyword"
    
    /// 根据关键字搜索充电桩
    static let chargeListSearch = "/web-api/map/charger-query-keyword"
    
    /// 获取充电桩历史记录
    static let chargeHistoryList = "/web-api/history/charger/retrive"
    
    /// 添加充电站历史记录
    static let addChargeHistory = "/web-api/history/charger/create"
    
    /// 删除充电桩历史记录
    static let deleteChargeHistory = "/web-api/history/charger/delete"
    
    /// 清空充电桩历史记录
    static let clearChargeHistory = "/web-api/history/charger/delete_all"
    
    /// 获取目的地导航历史记录
    static let naviGoHistory = "/web-api/history/desination/retrive"
    
    /// 添加目的地导航历史记录
    static let addNaviGoHistory = "/web-api/history/desination/create"
    
    /// 删除目的地导航历史记录
    static let deleteNaviGoHistory = "/web-api/history/desination/delete"
    
    /// 清空目的地导航历史记录
    static let clearNaviGoHistory = "/web-api/history/desination/delete_all"
    
    
    
    
    
    
    
    
    
    /// 根据key获取内容
    static let getSomethingData = "/content/api/Content/metadata"
    
    
    /// 获取车辆信息（列表、详情）
    static let getCarInfo = "/content/api/Product/vehicle-model"
}








