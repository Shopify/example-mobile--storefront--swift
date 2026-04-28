import Foundation
import CommonCrypto
import ShopifyCheckoutSheetKit

class AuthClient {

    let shopDomain: String
    let customerAccountsApiClientId: String
    let customerAccountsApiRedirectUri: String
    let storefrontAccessToken: String

    private var codeVerifier: String?
    private var savedState: String?

    init(shopDomain: String, clientId: String, redirectUri: String, storefrontAccessToken: String) {
        self.shopDomain = shopDomain
        self.customerAccountsApiClientId = clientId
        self.customerAccountsApiRedirectUri = redirectUri
        self.storefrontAccessToken = storefrontAccessToken
    }

    // MARK: - PKCE

    // [START auth.generate-pkce]
    func generateCodeVerifier() -> String {
        var buffer = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
        return base64Encode(Data(buffer))
    }

    func generateCodeChallenge(for codeVerifier: String) -> String {
        guard let data = codeVerifier.data(using: .utf8) else { fatalError() }
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { bytes in
            _ = CC_SHA256(bytes.baseAddress, CC_LONG(data.count), &digest)
        }
        return base64Encode(Data(digest))
    }

    private func base64Encode(_ data: Data) -> String {
        data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
    // [END auth.generate-pkce]

    // MARK: - Endpoint Discovery

    // [START auth.discover-endpoints]
    func discoverAuthEndpoints() async throws -> (String, String) {
        let discoveryUrl = URL(string: "https://\(shopDomain)/.well-known/openid-configuration")!
        let (data, _) = try await URLSession.shared.data(from: discoveryUrl)
        let config = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        let authEndpoint = config["authorization_endpoint"] as! String
        let tokenEndpoint = config["token_endpoint"] as! String

        return (authEndpoint, tokenEndpoint)
    }
    // [END auth.discover-endpoints]

    // MARK: - Authorization URL

    // [START auth.build-auth-url]
    func buildAuthorizationUrl() async throws -> String? {
        let codeVerifier = generateCodeVerifier()
        self.codeVerifier = codeVerifier

        let codeChallenge = generateCodeChallenge(for: codeVerifier)
        let (authEndpoint, _) = try await discoverAuthEndpoints()
        let state = generateRandomString(length: 36)
        self.savedState = state

        var components = URLComponents(string: authEndpoint)
        components?.queryItems = [
            URLQueryItem(name: "scope", value: "openid email customer-account-api:full"),
            URLQueryItem(name: "client_id", value: customerAccountsApiClientId),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: customerAccountsApiRedirectUri),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256")
        ]

        return components?.url?.absoluteString
    }

    private func generateRandomString(length: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in characters.randomElement()! })
    }
    // [END auth.build-auth-url]

    // MARK: - Callback Handling

    // [START auth.handle-callback]
    func handleCallback(url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let configuredComponents = URLComponents(string: customerAccountsApiRedirectUri),
              components.scheme == configuredComponents.scheme,
              components.host == configuredComponents.host else {
            return nil
        }

        guard let queryItems = components.queryItems else { return nil }

        guard let state = queryItems.first(where: { $0.name == "state" })?.value,
              state == savedState else {
            return nil
        }

        return queryItems.first(where: { $0.name == "code" })?.value
    }
    // [END auth.handle-callback]

    // MARK: - Token Exchange

    // [START auth.exchange-token]
    func requestAccessToken(code: String) async throws -> OAuthTokenResult {
        guard let codeVerifier = self.codeVerifier else {
            fatalError("Code verifier not found. Call buildAuthorizationUrl() first.")
        }

        let (_, tokenEndpoint) = try await discoverAuthEndpoints()
        let parameters: [String: String] = [
            "grant_type": "authorization_code",
            "client_id": customerAccountsApiClientId,
            "redirect_uri": customerAccountsApiRedirectUri,
            "code": code,
            "code_verifier": codeVerifier
        ]

        let body = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        var request = URLRequest(url: URL(string: tokenEndpoint)!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: .utf8)

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(OAuthTokenResult.self, from: data)
    }
    // [END auth.exchange-token]

    // MARK: - Authenticated Cart

    // [START auth.create-authenticated-cart]
    func createAuthenticatedCart(variantId: String, accessToken: String) async throws -> String {
        let query = """
        mutation cartCreate($input: CartInput!) {
            cartCreate(input: $input) {
                cart { checkoutUrl }
                userErrors { field message }
            }
        }
        """

        let variables: [String: Any] = [
            "input": [
                "lines": [["merchandiseId": variantId, "quantity": 1]],
                "buyerIdentity": ["customerAccessToken": accessToken]
            ]
        ]

        let payload: [String: Any] = ["query": query, "variables": variables]
        let body = try JSONSerialization.data(withJSONObject: payload)

        var request = URLRequest(url: URL(string: "https://\(shopDomain)/api/2026-01/graphql.json")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(storefrontAccessToken, forHTTPHeaderField: "X-Shopify-Storefront-Access-Token")
        request.httpBody = body

        let (data, _) = try await URLSession.shared.data(for: request)
        let result = try JSONDecoder().decode(CartCreateResponse.self, from: data)

        if let error = result.data.cartCreate.userErrors.first {
            throw CartError.userError(error.message)
        }

        guard let cart = result.data.cartCreate.cart else {
            throw CartError.cartNotCreated
        }

        return cart.checkoutUrl
    }
    // [END auth.create-authenticated-cart]

    // MARK: - Present Checkout

    // [START auth.present-checkout]
    func presentCheckout(checkoutUrl: URL, from viewController: UIViewController) {
        ShopifyCheckoutSheetKit.present(checkout: checkoutUrl, from: viewController, delegate: viewController as? ShopifyCheckoutSheetKitDelegate)
    }
    // [END auth.present-checkout]
}

struct OAuthTokenResult: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}
