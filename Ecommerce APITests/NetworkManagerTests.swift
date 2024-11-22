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
    //        func testRegister() async throws {
    //            let registerData: [String: String] = ["name":"Jerry Joy", "email": "jerry.joy@gmail.com", "password": "1234567890"]
    //            mockSession.nextData = try JSONEncoder().encode(registerData)
    //
    //            let registerToken = try await networkManager.register(name: "Jerry Joy", email: "jerry.joy@gmail.com", password: "1234567890")
    //            if registerToken.status != 200 {
    //                token = nil
    //                print(registerToken.msg)
    //            }
    //            token = registerToken.data
    //            networkManager.setToken(registerToken.data)
    //
    //        }
    //
    
    func testLogin() async throws {
        // Prepare mock data
        let loginData = ["email": "jerryjoy99@gmail.com", "password": "1234567890"]
        mockSession.nextData = try JSONEncoder().encode(loginData)
        
        // Call the function
        let loginToken = try await networkManager.login(email: "jerryjoy99@gmail.com" , password: "1234567890")
        
        if loginToken.status != 200 {
            token = ""
        }
        print(loginToken.data)
        token = loginToken.data
        networkManager.setToken(loginToken.data)
        
    }
    
    //    func testGetAllProducts() async throws {
    //        let products = try await networkManager.fetchProducts()
    //        print("Products: \(products)")
    //    }
    
    //    func testFetchAddress() async throws {
    //        try await ensureTokenIsSet()
    //        let addresses = try await networkManager.fetchAddresses()
    //        print("Addresses: \(addresses)")
    //    }
    
    //    func testAddAddress() async throws {
    //        try await ensureTokenIsSet()
    //        let addressData = ["street": "street", "city": "city", "state": "state", "zip": "zip"]
    //        mockSession.nextData = try JSONEncoder().encode(addressData)
    //
    //        let address = try await networkManager.addAddress(street: "street", city: "city", state: "state", zip: "zip")
    //        print("Add Address: \(address)")
    //    }
    ////
    //    func testUpdateAddress() async throws {
    //        try await ensureTokenIsSet()
    //        let addressData = ["street": "street", "city": "city", "state": "state", "zip": "zip"]
    //        mockSession.nextData = try JSONEncoder().encode(addressData)
    //
    //        let updateAddress = try await networkManager.updateAddress(addressId: "67338636602f7976dc3454f4", street: "street", city: "city", state: "state", zip: "zip")
    //        print("Add Address: \(updateAddress)")
    //    }
    //
    //    func testDeleteAddress() async throws {
    //        try await ensureTokenIsSet()
    //
    //        let deleteAddress = try await networkManager.deleteAddress(addressId: "67338636602f7976dc3454f4")
    //        print("Add Address: \(deleteAddress)")
    //    }
    
    
    //    func testUserProfile() async throws {
    //        // Check if token is set; if not, run testLogin to set it
    //        if token == nil {
    //            print("Logging in")
    //            try await testLogin()
    //            print("After loggin in")
    //        }
    //
    //        // Now proceed to fetch the user profile
    //        let user = try await networkManager.fetchUserProfile()
    //        if user.status != 200 {
    //            print(user.msg)
    //        }
    //        print(user.data)
    //    }
    
    
    //        func testAddToCart() async throws {
    //            try await ensureTokenIsSet()
    //            let addToCart = try await networkManager.addToCart(productId: "672457c799714013c00cbb89", quantity: 1)
    //            print(addToCart)
    //        }
    
    //    func testCheckout() async throws {
    //        try await ensureTokenIsSet()
    //        let checkout = try await networkManager.checkoutCart()
    //        print(checkout)
    //    }
    
    func testCartInfo() async throws {
        try await ensureTokenIsSet()
                
        let result = try await networkManager.cartInfo()
        
        print(result)
    }
    
    
    
}


// cmd + U
