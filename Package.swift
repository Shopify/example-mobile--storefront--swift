// swift-tools-version: 5.7
// [START integrate.install-spm]
import PackageDescription

let package = Package(
    name: "MobileStorefront",
    platforms: [
        .iOS(.v15)
    ],
    dependencies: [
        .package(url: "https://github.com/Shopify/checkout-sheet-kit-swift", from: "3.0.0")
    ],
    targets: [
        .executableTarget(
            name: "MobileStorefront",
            dependencies: [
                .product(name: "ShopifyCheckoutSheetKit", package: "checkout-sheet-kit-swift")
            ]
        )
    ]
)
// [END integrate.install-spm]
