//
//  RequestTool.swift
//  DavinciMotor
//  网络请求
//  Created by Mac on 2021/8/16.
//

import UIKit
import Alamofire

class RequestTool: NSObject {
    
    /// 请求方法
    /// - Parameters:
    ///   - URLString: 请求地址
    ///   - method: 请求方式
    ///   - parameters: 请求参数
    ///   - finishedCallback: 回调
    ///   - error: 错误信息
    class func Request(URLString: String,
                       method: HTTPMethod,
                       parameters: NSDictionary,
                       hintText: String?,
                       finishedCallback: @escaping (_ responseModel: BaseModel, _ response: Any) -> (), error: @escaping (_ error: Error?, _ code: Int?, _ message: String) -> ()) {
        // 如果提示语不为nil
        if hintText != nil {
            HUDTool.showLoading(hintText!)
        }
        // 如果url为空
        if URLString.isEmpty {
            error(nil, nil, "请检查网络设置或重试")
            return
        }
        // 设置超时时间
        AF.sessionConfiguration.timeoutIntervalForRequest = 30
        //token
        var token = String()
        if (userDefaultsGet("token") != nil) {
            token = userDefaultsGet("token") as! String
        }else{
            token = ""
        }
        //请求链接
        var url = String()
        url = (API.base + URLString).addingPercentEncoding(withAllowedCharacters:  CharacterSet.urlQueryAllowed)!
        // 发起请求
        AF.request(URL(string: url)!,
                   method: method,
                   parameters: (parameters as! Parameters),
                   encoding: JSONEncoding.default,
                   headers: ["Authorization":token]).responseJSON
            { response in
            
            guard let result = response.value else {
                //错误回调
                error(response.error, nil, "请检查网络设置或重试")
                // 如果提示语不为nil
                if hintText != nil {
                    HUDTool.hideAll()
                }
                DLog("错误：\(response)")
                return
            }
            
            DLog("传参为:\(parameters)\n回参为:\(result)")
            
            /*
             //重新登录
             if ((result as! NSDictionary)["code"] as! NSNumber) == 401 {
             //重新登录处理
             }
             */
            
            //结果回调
            if let baseModel = BaseModel.deserialize(from: result as? NSDictionary) {
                if baseModel.code == 0 {
                    finishedCallback(baseModel, result)
                } else {
                    error(response.error, baseModel.code, baseModel.message)
                }
                // 如果提示语不为nil
                if hintText != nil {
                    HUDTool.hideAll()
                }
            } else {
                error(response.error, nil, "请检查网络设置或重试")
                // 如果提示语不为nil
                if hintText != nil {
                    HUDTool.hideAll()
                }
            }
        }
    }
}
