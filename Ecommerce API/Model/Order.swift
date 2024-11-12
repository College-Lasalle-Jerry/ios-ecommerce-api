//
//  Order.swift
//  Ecommerce API
//
//  Created by Jerry Joy on 2024-11-06.
//

import Foundation


struct Order: Codable {
    let _id: String
    let user: String // Reference to the user who placed the order
    let totalAmount: Double
    let status: String
    let orderDate: Date
    let products: [OrderProduct]
}

struct OrderProduct: Codable {
    let product: String
    let quantity: Int
}
