//
//  ResponseModels.swift
//  OrderDrinksApp
//
//  Created by 林佩柔 on 2021/11/28.
//

import Foundation

struct MenuResponse: Codable {
    var records: [Record]
    
    struct Record: Codable {
        let id: String
        let fields: MenuItem
    }
}

struct OrderResponse: Codable {
    var records: [Record]
    
    struct Record: Codable {
        let id: String?
        let fields: Order
        let createdTime: String?
    }
}
