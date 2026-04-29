// [START accelerated-checkouts.customize]
import SwiftUI
import ShopifyAcceleratedCheckouts

struct CustomizedCheckoutView: View {
    let cartID: String

    var body: some View {
        VStack {
            // Show only Shop Pay
            AcceleratedCheckoutButtons(cartID: cartID)
                .wallets([.shopPay])

            // Show only Apple Pay
            AcceleratedCheckoutButtons(cartID: cartID)
                .wallets([.applePay])

            // Show both in a specific order
            AcceleratedCheckoutButtons(cartID: cartID)
                .wallets([.shopPay, .applePay])

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
