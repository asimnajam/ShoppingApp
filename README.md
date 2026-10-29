# 🛍️ Shopping App

A SwiftUI shopping app built with **The Composable Architecture (TCA)**. It browses and searches a live product catalogue from the [DummyJSON](https://dummyjson.com) REST API, shows product details and keeps a persistent cart.

The project focuses on clean feature composition, explicit dependency management, Swift Concurrency and testable business logic.

> Personal portfolio project. It is not published to the App Store.

<p align="center">
  <!-- Add screenshots to docs/screenshots/ -->
  <img src="docs/screenshots/products.png" width="220" />
  <img src="docs/screenshots/product-detail.png" width="220" />
  <img src="docs/screenshots/cart.png" width="220" />
</p>

---

## ✨ Features

- **Product catalogue** with infinite scrolling (paginated `limit`/`skip` requests)
- **Search** with debouncing and cancellation of in-flight requests
- **Product details** with an image gallery, a quantity stepper and add-to-cart
- **Cart** with quantity changes, item removal and limits on quantities
- **Cart persistence**: the cart is saved to disk and restored on launch
- **Image loading pipeline** with in-memory caching and de-duplication of in-flight requests
- **Explicit UI states** for loading, empty, error and pagination failures

---

## 🧱 Architecture

The app follows **The Composable Architecture**. Each feature is a `@Reducer` with its own `State` and `Action`, and features are composed into a root `ShopFeature`.

```
ShopFeature                 (tab container, cart load/save)
├── ProductListFeature      (catalogue, search, pagination)
│   └── Path: ProductDetailFeature   (stack navigation)
└── CartFeature             (quantities, removal)
```

**Key decisions**

- **Feature composition**: child features are combined with `Scope` and `forEach`. Children talk to parents through `delegate` actions (for example, add-to-cart from the detail screen).
- **State-driven navigation**: product details are pushed with `StackState`, so navigation is part of the state and can be tested.
- **Dependency injection**: `ProductService`, `CartStorage` and the clock are provided through `@Dependency`, which makes them easy to replace in tests and previews.
- **Effect management**: search and pagination effects are cancellable, and debouncing uses an injected clock instead of real time.
- **Swift Concurrency**: async/await throughout, with actors for thread-safe shared state (`FileCartStorage`, `FeedImagePipeline`).

### Networking

- A small, generic networking layer: an `EndPoint` protocol describes each request and its typed `Response`
- `DefaultNetworkClient` builds the request, validates the HTTP response and decodes JSON
- Errors are mapped into a single `NetworkClientError` with readable decoding messages
- `ProductService` picks the list or search endpoint depending on the query

### Persistence

`FileCartStorage` is an actor that writes the cart as JSON to Application Support with atomic writes. If saved data no longer matches the model, it falls back to an empty cart.

---

## 🧪 Testing

Business logic is covered by unit tests written with **Swift Testing** and TCA's **`TestStore`**. `TestStore` checks every state change and every action an effect sends back.

**What's covered**

- **Cart**: quantity changes, removal, zero and out-of-range quantities, unknown items
- **Product list**: loading, search, debouncing (with a test clock), pagination and failures
- **Product detail**: quantity validation and add-to-cart delegation
- **Shop**: cart restore and save through a mocked `CartStorage`
- **Networking**: request building, status-code handling and decoding errors

```swift
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
```

Run the tests in Xcode with `⌘U`, or from the command line:

```bash
xcodebuild test \
  -project ShoppingApp.xcodeproj \
  -scheme ShoppingApp \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

---

## 🛠️ Tech Stack

| Area          | Technology                                   |
|---------------|----------------------------------------------|
| Language      | Swift                                        |
| UI            | SwiftUI                                      |
| Architecture  | The Composable Architecture (TCA)            |
| Networking    | URLSession with a protocol-based REST client |
| Concurrency   | async/await, actors                          |
| Persistence   | JSON file storage                            |
| Testing       | Swift Testing, TCA `TestStore`               |
| Dependencies  | Swift Package Manager                        |

---

## 🚀 Getting Started

**Requirements**

- Xcode 27 or later
- iOS 27 or later

```bash
git clone https://github.com/asimnajam/ShoppingApp.git
cd ShoppingApp
open ShoppingApp.xcodeproj
```

Swift Package Manager resolves dependencies automatically. Select the `ShoppingApp` scheme and run it on a simulator. No API key is needed.

---

## 📁 Project Structure

```
ShoppingApp/
├── ShoppingApp.swift            # App entry point
├── Features/
│   ├── Shop/                    # Root feature: tabs and cart persistence
│   ├── ProductList/             # Catalogue, search, pagination
│   ├── ProductDetail/           # Product detail screen
│   └── Cart/                    # Cart screen
├── Shared/                      # Reusable views (RemoteImageView)
├── Services/
│   ├── EndPoints/               # Typed API endpoints
│   ├── NetworkClient.swift
│   ├── ProductService.swift
│   ├── CartStorage.swift
│   └── FeedImagePipeline.swift
├── Dependencies/                # TCA dependency keys and environment values
├── Models/                      # Product, CartItem
└── Assets.xcassets

ShoppingAppTests/                # Unit tests
```

---

## 👤 Author

**Syed Asim Najam**, Senior iOS Engineer
[GitHub](https://github.com/asimnajam) · [LinkedIn](https://www.linkedin.com/in/<your-profile>)

## 📄 License

Released under the [MIT License](LICENSE).
