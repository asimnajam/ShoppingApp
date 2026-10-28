//
//  ProductListFeature.swift
//  RepoRadar
//
//  Created by Syed Asim Najam on 13/10/2026.
//

import ComposableArchitecture
import Foundation

@Reducer
struct ProductListFeature {
    @ObservableState
    struct State {
        var searchQuery = ""
        var loadingState: LoadingState = .idle
        var path = StackState<Path.State>()
        var totalProducts = 0
        var nextSkip = 0
        var resultsQuery = ""
        var isLoadingMore = false
        var paginationError: String?
//        var cart: [CartItem] = []
//        @Presents var destination: Destination.State?
        
        enum LoadingState: Equatable {
            case idle
            case loading
            case loaded(items: [Product])
            case failed(error: String)
        }
    }
    
    @Reducer
    enum Path {
        case detail(ProductDetailFeature)
    }
    
//    @Reducer
//    enum Destination {
//        case cart(CartFeature)
//    }
    
    enum Action {
        case searchQueryChanged(String)
        case search(query: String)
        case fetchProducts
        case productsLoaded(Products, query: String)
        case loadMore
        case nextPageLoaded(Products)
        case nextPageFailed(String)
        case productFailed(String)
        case productSelected(Product)
        case path(StackAction<Path.State, Path.Action>)
//        case cartTapped
//        case sheetDestination(PresentationAction<Destination.Action>)
        case delegate(Delegate)
        
        enum Delegate {
            case addToCart(product: Product, quantity: Int)
        }
    }
    
    private enum CancelID {
        case products
        case loadMore
    }
    
    @Dependency(\.productService) var productService
    @Dependency(\.continuousClock) var clock
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .search(let query):
                let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
                
                guard !trimmedQuery.isEmpty else {
                    return .send(.fetchProducts)
                }
                state.loadingState = .loading
                
                return loadFirstPage(query: query, delay: .zero)
            case .fetchProducts:
                state.loadingState = .loading
                
                return loadFirstPage(query: "", delay: .zero)
            case .productSelected(let product):
                state.path.append(.detail(ProductDetailFeature.State(product: product)))
                return .none
            case let .productsLoaded(response, query):
                state.loadingState = .loaded(items: response.products)
                state.resultsQuery = query
                state.totalProducts = response.total
                state.nextSkip = response.skip + response.products.count
                state.isLoadingMore = false
                state.paginationError = nil
                // A page request for the previous results may have started while
                // this search was waiting; its products don't belong to these results.
                return .cancel(id: CancelID.loadMore)
            case let .productFailed(message):
                state.isLoadingMore = false
                state.loadingState = .failed(error: message)
                return .none
            case let .path(
                .element(id: _, action: .detail(.delegate(.addToCart(product: product, quantity: quantity))))):
                return .send(.delegate(.addToCart(product: product, quantity: quantity)))
            case .path:
                return .none
            case .delegate:
                return .none
            case .searchQueryChanged(let query):
                guard query != state.searchQuery else {
                    return .none
                }
                state.searchQuery = query
                if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    return .send(.fetchProducts)
                }
                
                return loadFirstPage(query: query, delay: .milliseconds(300))
            case .loadMore:
                guard case .loaded = state.loadingState,
                      !state.isLoadingMore,
                      state.nextSkip < state.totalProducts
                else {
                    return .none
                }

                state.isLoadingMore = true
                state.paginationError = nil

                return .run {
                    [productService,
                     query = state.resultsQuery,
                     skip = state.nextSkip] send in

                    do {
                        let response = try await productService.fetchPage(
                            query: query,
                            limit: 20,
                            skip: skip
                        )

                        try Task.checkCancellation()
                        await send(.nextPageLoaded(response))
                    } catch {
                        guard !Task.isCancelled else { return }
                        await send(.nextPageFailed(error.localizedDescription))
                    }
                }
                .cancellable(id: CancelID.loadMore, cancelInFlight: true)

            case let .nextPageLoaded(response):
                guard case let .loaded(existingProducts) = state.loadingState
                else { return .none }

                var seenIDs = Set(existingProducts.map(\.id))
                let newProducts = response.products.filter {
                    seenIDs.insert($0.id).inserted
                }

                state.loadingState = .loaded(
                    items: existingProducts + newProducts
                )
                state.totalProducts = response.total
                state.nextSkip = response.products.isEmpty
                    ? response.total
                    : response.skip + response.products.count
                state.isLoadingMore = false
                state.paginationError = nil
                return .none

            case let .nextPageFailed(message):
                state.isLoadingMore = false
                state.paginationError = message
                return .none
            }
        }
        .forEach(\.path, action: \.path)
//        .ifLet(\.$destination, action: \.sheetDestination)
    }

    private func loadFirstPage(
        query: String,
        delay: Duration
    ) -> EffectOf<Self> {
        .merge(
            // A new search makes any in-flight page request for the old results stale.
            .cancel(id: CancelID.loadMore),
            .run { [clock, productService] send in
                do {
                    if delay > .zero {
                        try await clock.sleep(for: delay)
                    }

                    let response = try await productService.fetchPage(
                        query: query,
                        limit: 20,
                        skip: 0
                    )

                    try Task.checkCancellation()
                    await send(.productsLoaded(response, query: query))
                } catch {
                    guard !Task.isCancelled else { return }
                    await send(.productFailed(error.localizedDescription))
                }
            }
            .cancellable(id: CancelID.products, cancelInFlight: true)
        )
    }
}
