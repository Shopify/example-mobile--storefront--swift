// [START accelerated-checkouts.buttons]
import SwiftUI
import ShopifyAcceleratedCheckouts

struct CheckoutView: View {
    let cartID: String

    var body: some View {
        VStack {
            AcceleratedCheckoutButtons(cartID: cartID)
        }
    }
}

struct ProductView: View {
    let variantID: String
    @State private var quantity = 1

    var body: some View {
        VStack {
            AcceleratedCheckoutButtons(
                variantID: variantID,
                quantity: quantity
            )
        }
    }
}
// [END accelerated-checkouts.buttons]
