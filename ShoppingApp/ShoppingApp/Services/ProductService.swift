//
//  ProductService.swift
//  ShoppingApp
//
//  Created by Syed Asim Najam on 13/10/2026.
//

import Foundation

protocol ProductService: Sendable {
    func fetchPage(
        query: String,
        limit: Int,
        skip: Int
    ) async throws -> Products
}

struct DefaultProductService: ProductService {
    private static let baseURL = "https://dummyjson.com"
    private let client: NetworkClient
    
    init(client: NetworkClient = DefaultNetworkClient(baseURLString: baseURL)) {
        self.client = client
    }
    
    func fetchPage(
        query: String,
        limit: Int,
        skip: Int
    ) async throws -> Products {
        let trimmedQuery = query.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        if trimmedQuery.isEmpty {
            return try await client.fetch(
                endPoint: GetAllProductsEndPoint(
                    limit: limit,
                    skip: skip
                )
            )
        }

        return try await client.fetch(
            endPoint: SearchProductsEndPoint(
                query: trimmedQuery,
                limit: limit,
                skip: skip
            )
        )
    }
}
