//
//  ShopFeature.swift
//  RepoRadar
//
//  Created by Syed Asim Najam on 20/10/2026.
//

import ComposableArchitecture
import Foundation

@Reducer
struct ShopFeature {
    @ObservableState
    struct State {
        var products: ProductListFeature.State = .init()
        var cart: CartFeature.State = .init()
        var hasLoadedCart = false
        var isLoadingCart = false
        var cartLoadError: String?
        var isSavingCart = false
        var needsCartSave = false
        var cartSaveError: String?
    }
    
    enum Action {
        case products(ProductListFeature.Action)
        case cart(CartFeature.Action)
        case loadCart
        case cartLoaded([CartItem])
        case cartLoadFailed(String)
        case saveCart
        case cartSaved
        case cartSaveFailed(String)
    }
    
    @Dependency(\.cartStorage) var cartStorage
    
    var body: some ReducerOf<Self> {
        Scope(\.products, action: \.products) {
            ProductListFeature()
        }
        
        Scope(\.cart, action: \.cart) {
            CartFeature()
        }
        
        Reduce { state, action in
            switch action {
            case let .products(
                .delegate(
                    .addToCart(product: product, quantity: quantity)
                )
            ):
                if let index = state.cart.items.firstIndex(where: { $0.id == product.id }) {
                    state.cart.items[index].quantity += quantity
                } else {
                    state.cart.items.append(CartItem(product: product, quantity: quantity))
                }
                return .none
            case .cart(.quantityChanged):
                return .send(.saveCart)
            case .cart, .products:
                return .none
            case .loadCart:
                guard !state.hasLoadedCart, !state.isLoadingCart else {
                    return .none
                }

                state.isLoadingCart = true
                state.cartLoadError = nil

                return .run { [cartStorage] send in
                    do {
                        let items = try await cartStorage.load()
                        try Task.checkCancellation()
                        await send(.cartLoaded(items))
                    } catch {
                        guard !Task.isCancelled else { return }
                        await send(.cartLoadFailed(error.localizedDescription))
                    }
                }

            case let .cartLoaded(items):
                state.cart.items = items
                state.hasLoadedCart = true
                state.isLoadingCart = false
                return .none

            case let .cartLoadFailed(message):
                state.isLoadingCart = false
                state.cartLoadError = message
                return .none
            case .saveCart:
                guard state.hasLoadedCart else { return .none }

                if state.isSavingCart {
                    state.needsCartSave = true
                    return .none
                }

                state.isSavingCart = true
                state.needsCartSave = false
                state.cartSaveError = nil

                return persistCart(state.cart.items)

            case .cartSaved:
                state.cartSaveError = nil

                if state.needsCartSave {
                    state.needsCartSave = false
                    return persistCart(state.cart.items)
                }

                state.isSavingCart = false
                return .none

            case let .cartSaveFailed(message):
                state.isSavingCart = false
                state.needsCartSave = true
                state.cartSaveError = message
                return .none
            }
        }
    }
    
    private func persistCart(
        _ items: [CartItem]
    ) -> EffectOf<Self> {
        .run { [cartStorage] send in
            do {
                try await cartStorage.save(items)
                await send(.cartSaved)
            } catch {
                await send(.cartSaveFailed(error.localizedDescription))
            }
        }
    }
}
