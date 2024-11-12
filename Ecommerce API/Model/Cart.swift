//
//  Cart.swift
//  Ecommerce API
//
//  Created by Jerry Joy on 2024-11-06.
//

import Foundation


struct Cart: Codable {
    let user: String
    let products: [CartProduct]
}

struct CartProduct: Codable {
    let product: String
    let quantity: Int
}

struct CartRequest: Codable {
    let product: String
    let quantity: Int
}
