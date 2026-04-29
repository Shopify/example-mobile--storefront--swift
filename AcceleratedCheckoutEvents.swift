// [START accelerated-checkouts.events]
import SwiftUI
import ShopifyAcceleratedCheckouts

struct CheckoutWithEventsView: View {
    let cartID: String

    var body: some View {
        VStack {
            AcceleratedCheckoutButtons(cartID: cartID)
                .onComplete { event in
                    // Clear your cart and navigate to a confirmation screen.
                }
                .onFail { error in
                    // Surface the error to the buyer.
                }
                .onCancel {
                    // Reset any pending UI state.
                }
        }
    }
}
// [END accelerated-checkouts.events]
