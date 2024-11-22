//
//  NetworkManager.swift
//  Ecommerce API
//
//  Created by Jerry Joy on 2024-11-06.
//

import Foundation


// Define the protocol
protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

// Make URLSession conform to the protocol
extension URLSession: URLSessionProtocol {}

// Define the mock class for testing
class MockURLSession: URLSessionProtocol {
    var nextData: Data? // Holds the mock data to return when a request is made
    var nextError: Error? //     // Holds an error to throw when a request is made, useful for simulating failures
    
    var lastURL: URL? // Stores the URL of the last request made, allowing test assertions to be made about the request
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        lastURL = request.url
        if let error = nextError {
            throw error
        }
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (nextData ?? Data(), response)
    }
}


public class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://api.jerryjoy.me/api"
    var token: String?
    private var session: URLSessionProtocol
    
    //    private init() {}
    
    init(session: URLSessionProtocol = URLSession.shared) { // Use URLSessionProtocol here
        self.session = session
        
        self.token = UserDefaults.standard.string(forKey: "userToken")
    }
    
    func setToken(_ token: String) {
        self.token = token
        // Save token to UserDefaults for persistence
        UserDefaults.standard.set(token, forKey: "userToken")
    }
    
    func clearToken() {
        self.token = nil
        // Remove token from UserDefaults
        UserDefaults.standard.removeObject(forKey: "userToken") // after we set the token in login/register
    }
    
    
    struct Response<T: Codable>: Codable {
        let data: T
        let msg: String
        let status: Int
    }
    
    
     func request<T: Codable>(endpoint: String, method: String = "GET", body: Data? = nil) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)")
        else {
            print("\(baseURL)\(endpoint)")
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body = body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        //        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
        //            throw URLError(.badServerResponse)
        //        }
        guard response is HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        let result = try JSONDecoder().decode(T.self, from: data)
        print("Result \(result)")
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    // Authentication
    func register(name: String, email: String, password: String) async throws -> Response<String> {
        let registerData = ["name": name, "email": email, "password": password]
        let data = try JSONEncoder().encode(registerData)
        struct registerStructure: Codable {
            let data: String
            let msg: String
        }
        let result: registerStructure = try await request(endpoint: "/auth/register", method: "POST", body: data)
        
        if !result.msg.isEmpty {
            return Response(data: "", msg: result.msg, status: 400)
        }
        
        return Response(data: result.data, msg: "Account Created", status: 200)
    }
    
    
    func login(email: String, password: String) async throws -> Response<String> {
        let loginData = ["email": email.lowercased(), "password": password.lowercased()]
        let data = try JSONEncoder().encode(loginData)
        struct LoginResponse: Codable {
            let data: String
            let msg: String
        }
        let result: LoginResponse = try await request(endpoint: "/auth/login", method: "POST", body: data)
        if !result.msg.isEmpty {
            return Response(data: result.data, msg: result.msg, status: 400) // unauthorised
            //            return nil
        }
        setToken(result.data)
        return Response(data: result.data, msg: result.msg, status: 200)
        //        return result.data
    }
    
    func fetchUserProfile() async throws -> Response<User> {
        struct UserResponse: Codable {
            let data: User
            let msg: String
        }
        let result: UserResponse = try await request(endpoint: "/auth/profile")
        if !result.msg.isEmpty {
            return Response(data: [] as! User, msg: result.msg, status: 400)
        }
        return Response(data: result.data, msg: "User Details", status: 200)
    }
    
    // Product APIs
    func fetchProducts() async throws -> Response<[Product]> {
        struct productResponse: Codable {
            let data: [Product]
            let msg: String
        }
        let result: productResponse = try await request(endpoint: "/products")
        if !result.msg.isEmpty {
            return Response(data: [] as! [Product], msg: result.msg, status: 400)
        }
        return Response(data: result.data, msg: result.msg, status: 200)
        
    }
    
    //    // Cart APIs
    func addToCart(productId: String, quantity: Int) async throws -> Response<Cart> {
        let cartData = CartRequest(productId: productId, quantity: quantity)
        let data = try JSONEncoder().encode(cartData)
        struct CartResponse: Codable {
            let data: Cart
            let msg: String
            let status: Int
        }
        let result: CartResponse =  try await request(endpoint: "/cart/add", method: "POST", body: data)
        print(result)
        if result.status != 200 {
            return Response(data: [] as! Cart, msg: result.msg, status: result.status)
        }
        return Response(data: result.data, msg: result.msg, status: result.status)
    }
    
    func cartInfo() async throws -> Response<Cart?> {
        struct CartInfoResponse : Codable {
            let data: Cart?
            let msg: String
            let status: Int
        }
        
        let result: CartInfoResponse = try await request(endpoint: "/cart")
        print("Result Cart Info: \(result)")
        
        if result.status != 200 {
            return Response(data: nil, msg: result.msg, status: result.status)
        }
        
        return Response(data: result.data, msg: result.msg, status: result.status)
    }
    //
    func checkoutCart() async throws -> Response<Int> {
        struct CheckoutResponse: Codable {
            let data: Int
            let msg: String
            let status: Int
        }
        let result: CheckoutResponse = try await request(endpoint: "/cart/checkout", method: "POST")
        if result.status != 200 {
            return Response(data: 0, msg: result.msg, status: result.status)
        }
        return Response(data: result.data, msg: result.msg, status: 200)
    }
    //
    // Address APIs
    func addAddress(street: String, city: String, state: String, zip: String) async throws -> Response<Address> {
        let addressData = ["street": street, "city": city, "state": state, "zip": zip]
        let data = try JSONEncoder().encode(addressData)
        struct AddressResponse: Codable {
            let data: Address
            let msg: String
        }
        let result: AddressResponse = try await request(endpoint: "/addresses", method: "POST", body: data)
        if !result.msg.isEmpty {
            return Response(data: [] as! Address, msg: result.msg, status: 400)
        }
        
        return Response(data: result.data, msg: result.msg, status: 200)
        
    }
    //
    func fetchAddresses() async throws -> Response<[Address]> {
        struct AddressResponse: Codable {
            let data: [Address]
            let msg: String
            
        }
        let result: AddressResponse =  try await request(endpoint: "/addresses")
        if !result.msg.isEmpty {
            return Response(data: [] as! [Address], msg: result.msg, status: 400)
        }
        return Response(data: result.data, msg: "Address fetched successfully", status: 200)
    }
    //
    func updateAddress(addressId: String, street: String, city: String, state: String, zip: String) async throws -> Response<Address> {
        let addressData = AddressRequest(street: street, city: city, state: state, zip: zip)
        let data = try JSONEncoder().encode(addressData)
        struct UpdateAddressResponse: Codable {
            let data: Address
            let msg: String
        }
        let result: UpdateAddressResponse =  try await request(endpoint: "/addresses/\(addressId)", method: "PUT", body: data)
        if !result.msg.isEmpty {
            return Response(data: [] as! Address, msg: result.msg, status: 400)
        }
        return Response(data: result.data, msg: "Address updated successfully", status: 200)
    }
    
    func deleteAddress(addressId: String) async throws -> Response<String> {
        
        struct DeleteAddressResponse: Codable {
            let msg: String
            let status: Int
        }
        let result: DeleteAddressResponse = try await request(endpoint: "/addresses/\(addressId)", method: "DELETE")
        if !result.msg.isEmpty {
            return Response(data: "", msg: result.msg, status: result.status)
        }
        return Response(data: result.msg, msg: "Address deleted successfully", status: result.status)
    }
    //
    //    // Orders
    //    func fetchUserOrders() async throws -> [Order] {
    //        return try await request(endpoint: "/order")
    //    }
}
