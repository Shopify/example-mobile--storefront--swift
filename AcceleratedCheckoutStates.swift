// [START accelerated-checkouts.states]
import SwiftUI
import ShopifyAcceleratedCheckouts

struct AcceleratedCheckoutView: View {
    let cartID: String
    @State private var renderState: RenderState = .loading

    var body: some View {
        if case .loading = renderState {
           ProgressView()
        }

        if case .error = renderState {
           ErrorState()
        }

        AcceleratedCheckoutButtons(cartID: cartID)
            .onRenderStateChange { state in
                renderState = state
            }
    }
}
// [END accelerated-checkouts.states]
