//
//  Product.swift
//  Ecommerce API
//
//  Created by Jerry Joy on 2024-11-06.
//

import Foundation


struct Product: Codable {
    let _id: String
    let name: String
    let description: String
    let price: Double
    let stock: Int
    let imageUrl: String
}
