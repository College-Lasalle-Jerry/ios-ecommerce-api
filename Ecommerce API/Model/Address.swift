//
//  Address.swift
//  Ecommerce API
//
//  Created by Jerry Joy on 2024-11-06.
//

import Foundation


struct Address: Codable {
    let id: String
    let user: User
    let street: String
    let city: String
    let state: String
    let zip: String
}


struct AddressRequest: Codable {
    let street: String
    let city: String
    let state: String
    let zip: String
}