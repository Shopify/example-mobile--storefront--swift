// [START accelerated-checkouts.configure]
import SwiftUI
import ShopifyAcceleratedCheckouts

let configuration = ShopifyAcceleratedCheckouts.Configuration(
    storefrontDomain: "{shop}.myshopify.com",
    storefrontAccessToken: "your-storefront-access-token",
    customer: ShopifyAcceleratedCheckouts.Customer(
        email: "customer@example.com",
        phoneNumber: "0123456789",
        customerAccessToken: "optional-customer-access-token"
    )
)

let applePayConfig = ShopifyAcceleratedCheckouts.ApplePayConfiguration(
    merchantIdentifier: "merchant.com.yourcompany",
    contactFields: [.email, .phone]
)

struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(configuration)
                .environmentObject(applePayConfig)
        }
    }
}
// [END accelerated-checkouts.configure]
