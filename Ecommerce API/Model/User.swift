//
//  User.swift
//  Ecommerce API
//
//  Created by Jerry Joy on 2024-11-06.
//

import Foundation


struct User: Codable {
    let _id: String
    let name: String
    let email: String
    let role: String
}

struct Login: Codable{
    let data: String
}


struct ApiResponse<T: Codable>: Codable {
    let data: T
    let msg: String?
    let status: Int
}

struct DataResponse<T: Codable>: Codable {
    let data: T
    let msg: String?
}

