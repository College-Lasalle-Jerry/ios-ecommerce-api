//
//  Cart.swift
//  Ecommerce API
//
//  Created by Jerry Joy on 2024-11-06.
//

import Foundation


struct Cart: Codable {
    let _id: String
    let user: String
    let products: [CartProduct]
}

struct CartProduct: Codable {
    let product: String
    let quantity: Int
    let _id: String
}

struct CartRequest: Codable {
    let productId: String
    let quantity: Int
}
