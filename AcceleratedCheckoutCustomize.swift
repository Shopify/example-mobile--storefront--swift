// [START accelerated-checkouts.customize]
import SwiftUI
import ShopifyAcceleratedCheckouts

struct CustomizedCheckoutView: View {
    let cartID: String

    var body: some View {
        VStack {
            // Show only Shop Pay
            AcceleratedCheckoutButtons(cartID: cartID)
                .wallets([.shoppay])

            // Show only Apple Pay
            AcceleratedCheckoutButtons(cartID: cartID)
                .wallets([.applepay])

            // Show both in a specific order
            AcceleratedCheckoutButtons(cartID: cartID)
                .wallets([.shoppay, .applepay])

            // Custom corner radius
            AcceleratedCheckoutButtons(cartID: cartID)
                .cornerRadius(16)

            // Pin the Apple Pay button to the white-outline style
            AcceleratedCheckoutButtons(cartID: cartID)
                .applePayStyle(.whiteOutline)
        }
    }
}
// [END accelerated-checkouts.customize]
