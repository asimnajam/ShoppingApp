//
//  ProductServiceDependency.swift
//  ShoppingApp
//
//  Created by Syed Asim Najam on 13/10/2026.
//

import ComposableArchitecture

private enum ProductServiceKey: DependencyKey {
    static let liveValue: any ProductService = DefaultProductService()
}

extension DependencyValues {
    var productService: any ProductService {
        get { self[ProductServiceKey.self] }
        set { self[ProductServiceKey.self] = newValue }
    }
}

