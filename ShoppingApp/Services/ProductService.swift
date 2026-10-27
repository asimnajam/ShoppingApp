//
//  ProductService.swift
//  RepoRadar
//
//  Created by Syed Asim Najam on 13/10/2026.
//

import Foundation

protocol ProductService: Sendable {
    func fetchAll() async throws -> [Product] //https://dummyjson.com/products
    func getProduct(by id: String) async throws //https://dummyjson.com/products
    func search(query: String) async throws -> [Product]
    func getProductCatagories()
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
    
    func fetchAll() async throws -> [Product] {
        let endPoint = GetAllProductsEndPoint()
        let product = try await client.fetch(endPoint: endPoint)
        print(product)
        return product.products
    }
    
    func getProduct(by id: String) async throws {
        
    }
    
    func search(query: String) async throws -> [Product] {
        let endPoint = SearchProductsEndPoint(query: query)
        let response = try await client.fetch(endPoint: endPoint)
        return response.products
    }
    
    func getProductCatagories() {
        
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
