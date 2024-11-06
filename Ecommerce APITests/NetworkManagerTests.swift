//
//  NetworkManagerTests.swift
//  Ecommerce APITests
//
//  Created by Jerry Joy on 2024-11-06.
//

import XCTest
@testable import Ecommerce_API

class NetworkManagerTests: XCTestCase {
    var networkManager: NetworkManager!
    var mockSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        networkManager = NetworkManager(session: mockSession)
        networkManager.setToken("mockToken")
    }
    
    
    func testLogin() async throws {
        // Prepare mock data
        let loginData = ["email": "june.sleepy@gmail.com", "password": "1234567890"]
        mockSession.nextData = try JSONEncoder().encode(loginData)
        
        // Call the function
        let login = try await networkManager.login(email: "june.sleepy@gmail.com" , password: "1234567890")
        
        // Verify the results
//        XCTAssertEqual(login.id, "mockId")
//        XCTAssertEqual(address.street, "123 Street")
//        XCTAssertEqual(address.city, "City")
//        XCTAssertEqual(mockSession.lastURL?.absoluteString, "https://your-nodejs-api-url.com/api/addresses")
        
        print(login)
    }
    
    func testGetAllProducts() async throws {
        let products = try await networkManager.fetchProducts()
        print("Products: \(products)")
    }
    
}
