//
//  CartFeature.swift
//  ShoppingApp
//
//  Created by Syed Asim Najam on 20/10/2026.
//

import ComposableArchitecture

@Reducer
struct CartFeature {
    @ObservableState
    struct State: Equatable {
        var items: [CartItem] = []
    }
    
    enum Action {
        case quantityChanged(id: CartItem.ID, quantity: Int)
        case removedTapped(id: CartItem.ID)
        case delegate(Delegate)
        
        enum Delegate {
            case itemsChanged([CartItem])
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .quantityChanged(let id, let quantity):
                guard quantity >= 0,
                   let index = state.items.firstIndex(where: { $0.id == id }) else {
                    return .none
                }
                if quantity == 0 {
                    state.items.remove(at: index)
                } else {
                    state.items[index].quantity = quantity
                }
                return .send(.delegate(.itemsChanged(state.items)))
            case .removedTapped(let id):
                state.items.removeAll(where: { $0.id == id })
                return .send(.delegate(.itemsChanged(state.items)))
                
            case .delegate:
                return .none
            }
        }
    }
}
