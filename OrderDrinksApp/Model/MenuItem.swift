//
//  MenuItem.swift
//  OrderDrinksApp
//
//  Created by 林佩柔 on 2021/11/23.
//

import Foundation

struct MenuItem: Codable {
    let drinkName: String
    let largePrice: Int?
    let mediumPrice: Int?
    let category: String
    let onlyCold: String?
    let onlyHot: String?
    let isRecommend: String?
}
