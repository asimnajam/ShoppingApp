import SwiftUI
import ComposableArchitecture

@main struct MyApp: App {
    private let imagePipeline = FeedImagePipeline()
    private let store = Store(initialState: ShopFeature.State()) {
        ShopFeature()
    }

    var body: some Scene {
        WindowGroup {
            ShopView(store: store)
                .environment(\.imagePipeline, imagePipeline)
        }
    }
}
