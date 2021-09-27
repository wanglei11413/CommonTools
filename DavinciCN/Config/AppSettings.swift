//
//  AppSettings.swift
//  DavinciCN
//  app的一些常用属性等等
//  Created by Mac on 2021/9/24.
//

import Foundation
import UIKit

// MARK: APP主题色、各种文字大小、间距大小

//APP 主题色
public let APP_MainColor = RGBColor(38, 38, 38)
//视图背景色
public let APP_BasicColor = RGBColor(242, 242, 242)
//分割线颜色
public let APP_LineColor  = RGBColor(232, 232, 232)
//绿颜色的按钮
public let APP_GreenColor = RGBColor(0, 134, 117)

/*
 文字颜色 由浅到深
 */
public let TextColor_LightGray = RGBColor(192, 192, 192)
public let TextColor_Gray      = RGBColor(140, 140, 140)
public let TextColor_DarkGray  = RGBColor(38, 38, 38)

//大字体
public let Font_Max_Light  = Font(16)
public let Font_Max_Medium = UIFont.init(name: "PingFangSC-Medium", size: RW(16))
//中字体
public let Font_Mid_Light  = Font(14)
public let Font_Mid_Medium = UIFont.init(name: "PingFangSC-Medium", size: RW(14))
//小字体
public let Font_Min_Light  = Font(12)

//间距
public let kMarginMax = RW(20)
public let kMarginMid = RW(15)
public let kMarginMin = RW(10)

//按钮或cell的高度
public let kNoramlHeight = RW(44)

// MARK: 各种三方库key设置
let JGAppKey        = "a4cbbf4a4a88bb39d9d75f80"
let JGSecret        = "9680bcc9fe7e728ae619ccea"

let WXAppKey        = "wxa2ea8edc74831c9f"
let WXAppSecret     = "3640218b4ad2afcadafd40c911a2acfb"

let QQAppKey        = "1111769864"
let QQAppSecret     = "1LLet8feBdsNaDy6"

let WBAppKey        = "2505795739"
let WBAppSecret     = "c2e438468e489223c654b93eb773e1bb"

let UMAppKey        = "60d0581d8a102159db7271d8"

let AliPayScheme    = "DavinciAliPayScheme"

//地图
let AmapApiKey      = "6a19f57fa53338ffbdbc012f06b78588"
//let amapKey       = "3953bcd943f6a934b4000149f7a9f0b1" // 控车app使用

let UniversalLink   = "https://www.davincimotor.com/"
let AppStoreAddress = "https://itunes.apple.com/cn/app/id1566981580?mt=8"
