import SwiftUI
import ComposableArchitecture

@main struct MyApp: App {
    private let imagePipeline = FeedImagePipeline()
    let store = Store(initialState: ProductListFeature.State()) {
        ProductListFeature()
    } withDependencies: {
        $0.productService = DefaultProductService()
    }
    
    let storee = Store(initialState: ShopFeature.State()) {
        ShopFeature()
    } withDependencies: { values in
        values.productService = DefaultProductService()
    }

    
    var body: some Scene {
        WindowGroup {
            ShopView(store: storee)
                .environment(\.imagePipeline, imagePipeline)
//            ProductListView(store: store)
//                .environment(\.imagePipeline, imagePipeline)
        }
    }
}
