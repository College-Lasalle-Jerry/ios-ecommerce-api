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
    var token: String?
    
    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        networkManager = NetworkManager(session: mockSession)
    }
    
    private func ensureTokenIsSet() async throws {
        if token == nil {
            try await testLogin() // Run login to set the token
            networkManager.setToken(token!) // Set the token in NetworkManager
        }
    }
//    
    func testRegister() async throws {
        let registerData: [String: String] = ["name":"Jerry Joy", "email": "jerry.joy@gmail.com", "password": "1234567890"]
        mockSession.nextData = try JSONEncoder().encode(registerData)
        
        let registerToken = try await networkManager.register(name: "Jerry Joy", email: "jerry.joy@gmail.com", password: "1234567890")
        token = registerToken ?? "No Token"
        print("Register Token: \(registerToken ?? "No Token")")
        networkManager.setToken(token ?? "No Token")
    }
    
    
    func testLogin() async throws {
        // Prepare mock data
        let loginData = ["email": "june.sleepy@gmail.com", "password": "1234567890"]
        mockSession.nextData = try JSONEncoder().encode(loginData)
        
        // Call the function
        let loginToken = try await networkManager.login(email: "june.sleepy@gmail.com" , password: "1234567890")
        
        // Verify the results
        //        XCTAssertEqual(login.id, "mockId")
        //        XCTAssertEqual(address.street, "123 Street")
        //        XCTAssertEqual(address.city, "City")
        //        XCTAssertEqual(mockSession.lastURL?.absoluteString, "https://your-nodejs-api-url.com/api/addresses")
        
        print("Login Token: \(loginToken ?? "unauthorised")")
        token = loginToken
        networkManager.setToken(loginToken ?? "unauthorised")
    }
    
    func testGetAllProducts() async throws {
        let products = try await networkManager.fetchProducts()
        print("Products: \(products ?? [] as! [Product])")
    }
    
    func testUserProfile() async throws {
           // Check if token is set; if not, run testLogin to set it
           if token == nil {
               try await testLogin()
           }
           
           // Now proceed to fetch the user profile
           let user = try await networkManager.fetchUserProfile()
        print(user ?? "Unauthorized")
       }
}
