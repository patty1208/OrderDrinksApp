//
//  ResponseModels.swift
//  OrderDrinksApp
//
//  Created by 林佩柔 on 2021/11/28.
//

import Foundation

struct MenuResponse: Codable {
    var records: [MenuRecord]
}

struct MenuRecord: Codable {
    let id: String
    let fields: MenuItem
}

struct OrderResponse: Codable {
    var records: [OrderRecord]
}

struct OrderRecord: Codable {
    let id: String?
    let fields: Order
    let createdTime: String?
}
