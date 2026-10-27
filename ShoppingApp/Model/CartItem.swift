//
//  CartItem.swift
//  RepoRadar
//
//  Created by Syed Asim Najam on 20/10/2026.
//

struct CartItem: Identifiable, Codable, Equatable, Sendable {
    let product: Product
    var quantity: Int

    var id: Product.ID { product.id }
}
