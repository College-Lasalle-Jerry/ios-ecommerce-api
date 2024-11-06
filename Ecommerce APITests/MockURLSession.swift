//
//  MockURLSession.swift
//  Ecommerce APITests
//
//  Created by Jerry Joy on 2024-11-06.
//

import Foundation

//public protocol URLSessionProtocol {
//    func data(for request: URLRequest) async throws -> (Data, URLResponse)
//}
//
//extension URLSession: URLSessionProtocol {}
//
//
//class MockURLSession: URLSessionProtocol {
//    var nextData: Data?
//    var nextError: Error?
//    var lastURL: URL?
//    
//    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
//        lastURL = request.url
//        if let error = nextError {
//            throw error
//        }
//        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
//        return (nextData ?? Data(), response)
//    }
//}
