//
//  ProductDetailFeature.swift
//  ShoppingApp
//
//  Created by Syed Asim Najam on 16/10/2026.
//

import ComposableArchitecture

@Reducer
struct ProductDetailFeature {
    @ObservableState
    struct State {
        var product: Product
        var quantity: Int = 1
        var didAddToCart: Bool = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case addToCartTapped
        case delegate(Delegate)
        
        enum Delegate {
            case addToCart(product: Product, quantity: Int)
        }
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .addToCartTapped:
                guard (1...CartItem.maxQuantity).contains(state.quantity) else {
                    return .none
                }
                state.didAddToCart = true
                return .send(.delegate(.addToCart(product: state.product, quantity: state.quantity)))
            case .binding:
                state.didAddToCart = false
                return .none
            case .delegate:
                return .none
            }
        }
    }
}
