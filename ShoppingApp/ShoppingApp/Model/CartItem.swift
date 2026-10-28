//
//  CartItem.swift
//  RepoRadar
//
//  Created by Syed Asim Najam on 20/10/2026.
//
import Foundation

struct CartItem: Identifiable, Codable, Equatable, Sendable {
    let id: Product.ID
    let title: String
    let price: Double
    let thumbnail: URL
    var quantity: Int
}

extension CartItem {
    init(product: Product, quantity: Int) {
        self.init(
            id: product.id,
            title: product.title,
            price: product.price,
            thumbnail: product.thumbnail,
            quantity: quantity
        )
    }
}
