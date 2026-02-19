// [START complete-tutorial.present-checkout]
// [START integrate.present-checkout]
// [START integrate.install]
import UIKit
import ShopifyCheckoutSheetKit
// [END integrate.install]

class CartViewController: UIViewController {
    private var checkoutUrl: URL?
    private let storefrontClient = StorefrontClient(
        shopDomain: "{shop}.myshopify.com",
        accessToken: "your-storefront-access-token"
    )

    func addToCart(variantId: String) async {
        do {
            let cart = try await storefrontClient.createCart(variantId: variantId)
            checkoutUrl = URL(string: cart.checkoutUrl)
        } catch {
            print("Failed to create cart: \(error)")
        }
    }

    @IBAction func checkoutTapped(_ sender: UIButton) {
        guard let url = checkoutUrl else {
            print("No checkout URL available")
            return
        }

        ShopifyCheckoutSheetKit.present(
            checkout: url,
            from: self,
            delegate: self
        )
    }
}

extension CartViewController: CheckoutDelegate {
    func checkoutDidComplete(event: CheckoutCompletedEvent) {
        let orderId = event.orderDetails.id
        print("Order completed: \(orderId)")
        checkoutUrl = nil
    }

    func checkoutDidCancel() {
        print("Checkout canceled")
    }

    func checkoutDidFail(error: CheckoutError) {
        print("Checkout failed: \(error.localizedDescription)")

        let alert = UIAlertController(
            title: "Checkout Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func checkoutDidClickLink(url: URL) {
        UIApplication.shared.open(url)
    }
}
// [END integrate.present-checkout]
// [END complete-tutorial.present-checkout]
