//
//  Enums.swift
//  OrderDrinksApp
//
//  Created by 林佩柔 on 2021/11/24.
//

import Foundation

enum OrderCategory: String, CaseIterable, Codable {
    case orderName = "訂購人"
    case capacity = "容量"
    case sugerLevel = "甜度"
    case tempLevel = "溫度"
    case toppings = "配料"
}

enum Capacity: String, CaseIterable, Codable{
    case large = "大杯"
    case medium = "中杯"
}
enum SugerLevel: String, CaseIterable, Codable {
    case normal = "標準糖"
    case less = "少糖"
    case half = "半糖"
    case light = "微糖"
    case no = "無糖"
}

enum TempLevel: String, CaseIterable, Codable {
    case normal = "標準冰"
    case less = "少冰"
    case light = "微冰"
    case no = "去冰"
    case hot = "熱飲"
}

enum Toppings: String, CaseIterable, Codable {
    case bubble = "珍珠"
    case basilSeed = "小紫蘇"
    case littleTaroBallsAndBubble = "新雙Q" // "新雙Q(珍珠+芋圓+薯圓)"
    case littleTaroBalls = "小芋圓" // "小芋圓(芋圓+薯圓)"
    case bubbleAndCoconutJellyAndLycheeJelly = "搖果樂"//"搖果樂(珍珠+椰果+荔枝凍)"
    case konjacJelly = "寒天晶球"
    case coconutJelly = "椰果"
    case aiyu = "愛玉"
    case aloeVera = "蘆薈"
    case lycheeJelly = "荔枝凍"
    case purpleRice = "紫米"
    case herbJelly = "仙草凍"
    case pudding = "布丁"
    
    var price: Int {
        switch self {
        case .bubble:
            return 5
        case .basilSeed:
            return 5
        case .littleTaroBallsAndBubble:
            return 10
        case .littleTaroBalls:
            return 10
        case .bubbleAndCoconutJellyAndLycheeJelly:
            return 10
        case .konjacJelly:
            return 10
        case .coconutJelly:
            return 10
        case .aiyu:
            return 10
        case .aloeVera:
            return 10
        case .lycheeJelly:
            return 10
        case .purpleRice:
            return 10
        case .herbJelly:
            return 15
        case .pudding:
            return 15
        }
    }
}

