import Foundation

class StorefrontClient {
    // [START integrate.config]
    let shopDomain: String
    let accessToken: String
    let apiVersion: String

    init(shopDomain: String, accessToken: String, apiVersion: String = "2026-01") {
        self.shopDomain = shopDomain
        self.accessToken = accessToken
        self.apiVersion = apiVersion
    }
    // [END integrate.config]

    // [START complete-tutorial.fetch-products]
    func fetchProducts() async throws -> [Product] {
        let url = URL(string: "https://\(shopDomain)/api/\(apiVersion)/graphql.json")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(accessToken, forHTTPHeaderField: "X-Shopify-Storefront-Access-Token")

        let query = """
        query Products {
          products(first: 10) {
            edges {
              node {
                id
                title
                description
                featuredImage { url }
                variants(first: 1) {
                  edges {
                    node {
                      id
                      title
                      price { amount currencyCode }
                    }
                  }
                }
              }
            }
          }
        }
        """

        let body = ["query": query]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw StorefrontError.requestFailed
        }

        let result = try JSONDecoder().decode(ProductsResponse.self, from: data)
        return result.data.products.edges.map { $0.node }
    }
    // [END complete-tutorial.fetch-products]

    // [START complete-tutorial.create-cart]
    func createCart(variantId: String, quantity: Int = 1) async throws -> Cart {
        let url = URL(string: "https://\(shopDomain)/api/\(apiVersion)/graphql.json")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(accessToken, forHTTPHeaderField: "X-Shopify-Storefront-Access-Token")

        let mutation = """
        mutation CartCreate($input: CartInput!) {
          cartCreate(input: $input) {
            cart {
              id
              checkoutUrl
            }
            userErrors {
              field
              message
            }
          }
        }
        """

        let variables: [String: Any] = [
            "input": [
                "lines": [
                    ["merchandiseId": variantId, "quantity": quantity]
                ]
            ]
        ]

        let body: [String: Any] = ["query": mutation, "variables": variables]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw StorefrontError.requestFailed
        }

        let result = try JSONDecoder().decode(CartCreateResponse.self, from: data)

        if let error = result.data.cartCreate.userErrors.first {
            throw CartError.userError(error.message)
        }

        guard let cart = result.data.cartCreate.cart else {
            throw CartError.cartNotCreated
        }

        return cart
    }
    // [END complete-tutorial.create-cart]

    // [START integrate.cart-permalink]
    func buildCartPermalink(variantId: String, quantity: Int = 1) -> URL {
        URL(string: "https://\(shopDomain)/cart/\(variantId):\(quantity)")!
    }
    // [END integrate.cart-permalink]
}
