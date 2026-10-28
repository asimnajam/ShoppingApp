//
//  EndPoint.swift
//  ShoppingApp
//
//  Created by Syed Asim Najam on 13/10/2026.
//

import Foundation

protocol EndPoint {
    associatedtype Response: Decodable
    var method: HTTPMethod { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
    var body: Data? { get }
    func makeRequest(_ urLString: String, additionalHeaders: [String: String]) throws -> URLRequest
}

extension EndPoint {
    func makeRequest(_ urLString: String, additionalHeaders: [String: String] = [:]) throws -> URLRequest {
        guard let baseURL = URL(string: urLString) else {
            throw APIError.invalidBaseURL
        }
        guard var urlComponent = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            throw APIError.invalidBaseURL
        }
        urlComponent.path = path
        if !queryItems.isEmpty {
            urlComponent.queryItems = queryItems
        }
        
        guard let url = urlComponent.url else {
            throw APIError.badURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue.uppercased()
        
        if let body = body {
            request.httpBody = body
        }
        
        for (header, value) in additionalHeaders {
            request.setValue(value, forHTTPHeaderField: header)
        }

        return request
    }
}

enum HTTPMethod: String {
    case get
    case post
    case delete
    case put
}
