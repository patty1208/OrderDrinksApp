//
//  Order.swift
//  OrderDrinksApp
//
//  Created by 林佩柔 on 2021/11/23.
//

import Foundation

struct Order: Codable {
    var orderName: String
    var drinkName: String
    var capacity: String
    var tempLevel: String
    var sugarLevel: String
    var toppings: String?
    var quantity: Int
    var price: Int
}

