// [START accelerated-checkouts.install-spm]
// Package.swift
import PackageDescription

let package = Package(
    name: "MobileStorefront",
    platforms: [
        .iOS(.v16)
    ],
    dependencies: [
        .package(url: "https://github.com/Shopify/checkout-sheet-kit-swift", from: "3.4.0")
    ],
    targets: [
        .executableTarget(
            name: "MobileStorefront",
            dependencies: [
                .product(name: "ShopifyCheckoutSheetKit", package: "checkout-sheet-kit-swift"),
                .product(name: "ShopifyAcceleratedCheckouts", package: "checkout-sheet-kit-swift")
            ]
        )
    ]
)
// [END accelerated-checkouts.install-spm]
