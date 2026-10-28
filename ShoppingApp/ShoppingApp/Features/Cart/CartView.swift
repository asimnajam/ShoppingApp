//
//  CartView.swift
//  ShoppingApp
//
//  Created by Syed Asim Najam on 20/10/2026.
//

import ComposableArchitecture
import SwiftUI


struct CartView: View {
    var store: StoreOf<CartFeature>
    
    var body: some View {
        Group {
            if store.items.isEmpty {
                ContentUnavailableView(
                    "Your cart is empty",
                    systemImage: "cart",
                    description: Text("Add products to get started.")
                )
            } else {
                List(store.items) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.title)
                            .font(.headline)
                        
                        Text("Quantity: \(item.quantity)")
                        
                        Text(
                            item.price,
                            format: .currency(code: "USD")
                        )
                        .foregroundStyle(.secondary)
                        
                        Stepper("Quantity: \(item.quantity)", value: Binding(
                            get: { item.quantity },
                            set: { newValue in
                            store.send(.quantityChanged(id: item.id, quantity: newValue))
                        }), in: 0...CartItem.maxQuantity)
                        
                    }
                    .padding(.vertical, 4)
                    .swipeActions {
                        Button("Remove", role: .destructive) {
                            store.send(.removedTapped(id: item.id))
                        }

                    }
                }
                .navigationTitle("Cart")
            }
        }
    }
}
