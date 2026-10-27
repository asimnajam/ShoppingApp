//
//  ShopView.swift
//  RepoRadar
//
//  Created by Syed Asim Najam on 20/10/2026.
//

import SwiftUI
import ComposableArchitecture

struct ShopView: View {
    let store: StoreOf<ShopFeature>

    var body: some View {
        Group {
            if store.hasLoadedCart {
                tabs
            } else if let message = store.cartLoadError {
                VStack(spacing: 16) {
                    Text("Couldn’t load your cart")
                        .font(.headline)

                    Text(message)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Button("Retry") {
                        store.send(.loadCart)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else {
                ProgressView("Opening your cart…")
            }
        }
        .task {
            await store.send(.loadCart).finish()
        }
        .safeAreaInset(edge: .top) {
            if let message = store.cartSaveError {
                VStack(spacing: 8) {
                    Text("Couldn’t save your cart")
                        .font(.headline)

                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Button("Retry") {
                        store.send(.saveCart)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.regularMaterial)
            } else if store.isSavingCart {
                ProgressView("Saving cart…")
                    .padding(8)
            }
        }
    }
    
    private var tabs: some View {
        TabView {
            Tab("Shop", systemImage: "bag") {
                ProductListView(store: store.scope(\.products, action: \.products))
            }
            
            Tab("Cart", systemImage: "cart") {
                NavigationStack {
                    CartView(store: store.scope(\.cart, action: \.cart))
                }
            }
            .badge(
                store.cart.items.reduce(0, { partialResult, item in
                    partialResult + item.quantity
                })
            )
        }
    }
}
