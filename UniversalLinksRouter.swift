import UIKit
import ShopifyCheckoutSheetKit

// [START universal-links.route-url]
struct StorefrontURL {
    let url: URL

    var isCheckout: Bool {
        url.path.contains("/checkouts/")
    }

    var isCart: Bool {
        url.path == "/cart" || url.path.hasPrefix("/cart/")
    }

    var isThankYouPage: Bool {
        url.path.range(of: "/thank[-_]you", options: .regularExpression) != nil
    }
}

final class UniversalLinksRouter {
    private let checkoutDelegate: CheckoutDelegate
    private let navigateToCart: () -> Void

    init(
        checkoutDelegate: CheckoutDelegate,
        navigateToCart: @escaping () -> Void
    ) {
        self.checkoutDelegate = checkoutDelegate
        self.navigateToCart = navigateToCart
    }

    func route(_ url: URL, from viewController: UIViewController) {
        let storefrontUrl = StorefrontURL(url: url)

        switch true {
        case storefrontUrl.isCheckout && !storefrontUrl.isThankYouPage:
            ShopifyCheckoutSheetKit.present(
                checkout: url,
                from: viewController,
                delegate: checkoutDelegate
            )
        case storefrontUrl.isCart:
            navigateToCart()
        default:
            UIApplication.shared.open(url)
        }
    }
}
// [END universal-links.route-url]

// [START universal-links.handle-user-activity]
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var universalLinksRouter: UniversalLinksRouter?
    private weak var rootViewController: UIViewController?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        if let userActivity = connectionOptions.userActivities.first {
            handle(userActivity)
        }
    }

    func scene(
        _ scene: UIScene,
        continue userActivity: NSUserActivity
    ) {
        handle(userActivity)
    }

    private func handle(_ userActivity: NSUserActivity) {
        guard
            userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL,
            let rootViewController,
            let universalLinksRouter
        else {
            return
        }

        universalLinksRouter.route(url, from: rootViewController)
    }
}
// [END universal-links.handle-user-activity]
