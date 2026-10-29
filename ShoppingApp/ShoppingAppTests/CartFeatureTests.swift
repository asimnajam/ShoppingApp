//
//  CartFeatureTests.swift
//  ShoppingApp
//
//  Created by Syed Asim Najam on 28/10/2026.
//

import Testing
import ComposableArchitecture
import Foundation
@testable import ShoppingApp

@MainActor
struct CartFeatureTests {
    let apple = CartItem(id: 1, title: "Apple", price: 1.5,
                         thumbnail: URL(string: "https://example.com/1.png")!, quantity: 2)
    let pear  = CartItem(id: 2, title: "Pear", price: 2.0,
                         thumbnail: URL(string: "https://example.com/2.png")!, quantity: 1)

    @Test
    func removeItem () async {
        let store = TestStore(initialState: CartFeature.State(items: [apple, pear]), reducer: {
            CartFeature()
        })
        
        await store.send(.removedTapped(id: apple.id)) {
            $0.items = [pear]
        }
        
        // 3. Check the action the effect sends back.
        await store.receive(\.delegate.itemsChanged, [pear])
    }
    
    @Test
    func quantityZeroRemovesItem() async {
        let store = TestStore(initialState: CartFeature.State(items: [apple, pear])) {
            CartFeature()
        }
        
        await store.send(.quantityChanged(id: apple.id, quantity: 0)) {
            $0.items = [pear]
        }
        
        await store.receive(\.delegate.itemsChanged, [pear])
    }
    
    @Test
    func unknownIDDoesNothing() async {
        let store = TestStore(initialState: CartFeature.State(items: [apple, pear])) {
            CartFeature()
        }
        
        await store.send(.quantityChanged(id: 999, quantity: 0))
    }
    
    @Test
    func quantityChangeUpdatesItem() async {
        let store = TestStore(initialState: CartFeature.State(items: [apple, pear])) {
            CartFeature()
        }
        
        await store.send(.quantityChanged(id: apple.id, quantity: 5)) {
            $0.items[0].quantity = 5
        }
        
        var updatedApple = apple
        updatedApple.quantity = 5
        
        await store.receive(\.delegate.itemsChanged, [updatedApple, pear])
    }
    
    @Test
    func negativeQuantityIsIgnored() async {
        let store = TestStore(initialState: CartFeature.State(items: [apple, pear])) {
            CartFeature()
        }
        
        await store.send(.quantityChanged(id: apple.id, quantity: -1))
    }
    
    @Test
    func quantityAboveMaxIsIgnored() async {
        let store = TestStore(initialState: CartFeature.State(items: [apple, pear])) {
            CartFeature()
        }
        
        await store.send(.quantityChanged(id: apple.id, quantity: 150))
    }
}
