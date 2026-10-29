//
//  ProductListView.swift
//  ShoppingApp
//
//  Created by Syed Asim Najam on 13/10/2026.
//

import ComposableArchitecture
import SwiftUI

struct ProductListView: View {
    @Bindable var store: StoreOf<ProductListFeature>
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            VStack {
                switch store.loadingState {
                case .idle:
                    Text("Ready to load products")
                case .loading:
                    ProgressView("Loading products..")
                case .loaded(let products):
                    listView(products)
                case .failed(let message):
                    VStack(spacing: 12) {
                        Text(message)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Retry") {
                            store.send(.search(query: store.searchQuery))
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Products")
            .background(Color(uiColor: .systemGroupedBackground))
            .searchable(
                text: Binding(
                    get: { store.searchQuery },
                    set: { store.send(.searchQueryChanged($0)) }
                ),
                prompt: "")
            .onSubmit(of: .search) {
                store.send(.search(query: store.searchQuery))
            }
            .task {
                guard case .idle = store.loadingState else { return }
                await store.send(.fetchProducts).finish()
            }
        }
        destination: { pathStore in
            switch pathStore.case {
            case .detail(let productDetailFeature):
                ProductDetailView(store: productDetailFeature)
            }
        }
    }
    
    func listView(_ products: [Product]) -> some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 160), spacing: 16)
                    ],
                    spacing: 16
                ) {
                    ForEach(products) { product in
                        Button {
                            store.send(.productSelected(product))
                        } label: {
                            ProductCardView(product: product)
                        }
                        .buttonStyle(.plain)
                    }
                }

                paginationFooter
            }
            .padding(16)
        }
    }
    
    @ViewBuilder
    private var paginationFooter: some View {
        if store.isLoadingMore {
            ProgressView("Loading more…")
                .padding()
        } else if let message = store.paginationError {
            VStack(spacing: 12) {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Button("Retry loading more") {
                    store.send(.loadMore)
                }
                .buttonStyle(.bordered)
            }
            .padding()
        } else if store.nextSkip < store.totalProducts {
            Color.clear
                .frame(height: 1)
                .task(id: store.nextSkip) {
                    store.send(.loadMore)
                }
        }
    }
}
