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
    
    // Custom initializer to handle missing keys
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Use decodeIfPresent and provide default values for missing keys
        self._id = try container.decodeIfPresent(String.self, forKey: ._id) ?? ""
        self.user = try container.decodeIfPresent(String.self, forKey: .user) ?? ""
        self.products = try container.decodeIfPresent([CartProduct].self, forKey: .products) ?? []
    }

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
