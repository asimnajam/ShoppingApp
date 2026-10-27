//
//  ProductDetailFeature.swift
//  RepoRadar
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
                guard (1...99).contains(state.quantity) else {
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

import SwiftUI
import ComposableArchitecture

struct ProductDetailView: View {
    @Bindable var store: StoreOf<ProductDetailFeature>
    
    let feedImagePipeline = FeedImagePipeline()
    private var imageURLs: [URL] {
        store.product.images.isEmpty
        ? [store.product.thumbnail]
        : [store.product.thumbnail, store.product.thumbnail, store.product.thumbnail]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                imageGallery
                
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(store.product.title)
                            .font(.title2.bold())
                            .accessibilityAddTraits(.isHeader)
                        
                        Text(
                            store.product.price,
                            format: .currency(code: "USD")
                        )
                        .font(.title3.weight(.semibold))
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About this product")
                            .font(.headline)
                            .accessibilityAddTraits(.isHeader)
                        
                        Text(store.product.description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .lineSpacing(5)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 32)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                Stepper(
                    "Quantity: \(store.quantity)",
                    value: $store.quantity,
                    in: 1...99
                )

                Button {
                    store.send(.addToCartTapped)
                } label: {
                    Text("Add to Cart")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(.indigo)

                if store.didAddToCart {
                    Label("Added to cart", systemImage: "checkmark.circle.fill")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(.regularMaterial)
        }
        .background(Color(uiColor: .systemBackground))
        .navigationTitle("Product details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var imageGallery: some View {
        TabView {
            ForEach(imageURLs, id: \.self) { url in
                RemoteImageView(url: url)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .frame(height: 320)
        .background(
            Color(uiColor: .secondarySystemGroupedBackground)
        )
        
    }
}
