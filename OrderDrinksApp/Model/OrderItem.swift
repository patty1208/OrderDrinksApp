//
//  OrderItem.swift
//  OrderDrinksApp
//
//  Created by 林佩柔 on 2022/7/26.
//  屬性為自訂型別 Enum

import Foundation

struct OrderItem {
    var orderName: String
    var drinkName: String
    var capacity: Capacity?
    var tempLevel: TempLevel?
    var sugarLevel: SugerLevel?
    var toppings: [Toppings]
    var quantity: Int
    var price: Int
}
