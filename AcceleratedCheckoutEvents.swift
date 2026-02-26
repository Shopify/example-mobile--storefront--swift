// [START accelerated-checkouts.events]
import SwiftUI
import ShopifyAcceleratedCheckouts

struct CheckoutWithEventsView: View {
    let cartID: String

    var body: some View {
        VStack {
            AcceleratedCheckoutButtons(cartID: cartID)
                .onComplete { event in
                    cartManager.clearCart()
                }
                .onFail { error in
                    // Show error
                }
                .onCancel {
                    // Reset state
                }
        }
    }
}
// [END accelerated-checkouts.events]
