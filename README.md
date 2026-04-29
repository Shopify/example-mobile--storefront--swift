# Mobile Storefront — Swift

Companion code for [shopify.dev](https://shopify.dev) tutorials covering the Storefront API, [Checkout Kit for Swift](https://github.com/Shopify/checkout-sheet-kit-swift), and Customer Account API authentication.

> **This repository is not a standalone runnable app.** It contains the source files referenced inline by the tutorials. To use them, drop the files into an existing iOS project and add the dependencies listed below.

## Tutorials

- [Build a mobile storefront](https://shopify.dev/docs/storefronts/mobile/build-mobile-storefront)
- [Embed Checkout Kit](https://shopify.dev/docs/storefronts/mobile/checkout-kit)
- [Authenticate checkouts](https://shopify.dev/docs/storefronts/mobile/checkout-kit/authenticate-checkouts)
- [Accelerated checkouts](https://shopify.dev/docs/storefronts/mobile/checkout-kit/accelerated-checkouts)

## What's included

| File | Description |
|---|---|
| `StorefrontClient.swift` | Storefront API client — product queries, cart creation, cart permalinks |
| `Models.swift` | Decodable response types for GraphQL responses |
| `ProductListView.swift` | SwiftUI product list with Add to Cart |
| `CartViewController.swift` | Checkout Kit integration with event handling |
| `AuthClient.swift` | OAuth + PKCE flow against the Customer Account API |
| `AcceleratedCheckout*.swift` | Accelerated checkout buttons, configuration, customization, events, and render-state handling |

## Use these snippets in your project

1. Copy the relevant files into your iOS project's source tree.
2. Add the [Checkout Sheet Kit Swift package](https://github.com/Shopify/checkout-sheet-kit-swift) (and the `ShopifyAcceleratedCheckouts` module if you're using accelerated checkouts) via Swift Package Manager.
3. In `StorefrontClient.swift`, replace `{shop}.myshopify.com` with your store domain and add your Storefront API access token.
4. The samples target iOS 15 or later.

## Requirements

- Xcode 14 or later
- iOS 15 or later
- A [Shopify development store](https://shopify.dev/docs/storefronts/headless/building-with-the-storefront-api/getting-started) with at least one product
- A Storefront API access token with `unauthenticated_read_product_listings` and `unauthenticated_write_checkouts` scopes

## Contributing

This repository doesn't accept issues or external contributions. It exists as a companion to the tutorials linked above. If you find an issue with the tutorial content, use the feedback form on the tutorial page.

## License

This project is licensed under the [MIT License](LICENSE.md).
