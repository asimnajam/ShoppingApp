//
//  GetAllProductsEndPoint.swift
//  ShoppingApp
//
//  Created by Syed Asim Najam on 13/10/2026.
//

import Foundation

struct GetAllProductsEndPoint: EndPoint {
    typealias Response = Products
    
    let method: HTTPMethod = .get
    let body: Data? = nil
    let path = "/products"
    let queryItems: [URLQueryItem]
    
    init(limit: Int = 20, skip: Int = 0) {
        queryItems = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "skip", value: String(skip))
        ]
    }
}
