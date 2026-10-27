//
//  Products.swift
//  RepoRadar
//
//  Created by Syed Asim Najam on 13/10/2026.
//

import Foundation

struct Products: Codable, Sendable {
    let products: [Product]
    let total: Int
    let skip: Int
    let limit: Int
}

struct Review: Codable, Equatable, Sendable {
    let rating: Int
    let comment: String
    let date: Date
    let reviewerName: String
    let reviewerEmail: String
}

struct ProductMeta: Codable, Equatable, Sendable {
    let createdAt: Date
    let updatedAt: Date
    let barcode: String
    let qrCode: URL
}

struct Product: Codable, Equatable, Identifiable, Sendable {
    let id: Int
    let title: String
    let description: String
    let category: String
    let price: Double
    let discountPercentage: Double
    let rating: Double
    let stock: Int
    let tags: [String]
    let brand: String?
    let sku: String
    let weight: Double
    let dimensions: Dimensions
    let warrantyInformation: String
    let shippingInformation: String
    let availabilityStatus: String
    let reviews: [Review]
    let returnPolicy: String
    let minimumOrderQuantity: Int
    let meta: ProductMeta
    let images: [URL]
    let thumbnail: URL
}

struct Dimensions: Codable, Equatable, Sendable {
    let width: Double
    let height: Double
    let depth: Double
}
