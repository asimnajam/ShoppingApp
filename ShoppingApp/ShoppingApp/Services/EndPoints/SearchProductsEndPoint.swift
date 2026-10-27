//
//  SearchProductsEndPoint.swift
//  RepoRadar
//
//  Created by Syed Asim Najam on 25/10/2026.
//

import Foundation

struct SearchProductsEndPoint: EndPoint {
    typealias Response = Products

    let method: HTTPMethod = .get
    let path = "/products/search"
    let body: Data? = nil
    let queryItems: [URLQueryItem]

    init(query: String, limit: Int = 20, skip: Int = 0) {
        queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "skip", value: String(skip))
        ]
    }
}
