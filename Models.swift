import Foundation

// [START complete-tutorial.response-types]
struct ProductsResponse: Decodable {
    let data: ProductsData
}

struct ProductsData: Decodable {
    let products: ProductConnection
}

struct ProductConnection: Decodable {
    let edges: [ProductEdge]
}

struct ProductEdge: Decodable {
    let node: Product
}

struct Product: Decodable, Identifiable {
    let id: String
    let title: String
    let description: String?
    let featuredImage: FeaturedImage?
    let variants: VariantConnection

    var firstVariantId: String? {
        variants.edges.first?.node.id
    }
}

struct FeaturedImage: Decodable {
    let url: String
}

struct VariantConnection: Decodable {
    let edges: [VariantEdge]
}

struct VariantEdge: Decodable {
    let node: ProductVariant
}

struct ProductVariant: Decodable {
    let id: String
    let title: String
    let price: Price
}

struct Price: Decodable {
    let amount: String
    let currencyCode: String
}

struct CartCreateResponse: Decodable {
    let data: CartCreateData
}

struct CartCreateData: Decodable {
    let cartCreate: CartCreatePayload
}

struct CartCreatePayload: Decodable {
    let cart: Cart?
    let userErrors: [UserError]
}

struct Cart: Decodable {
    let id: String
    let checkoutUrl: String
}

struct UserError: Decodable {
    let field: [String]?
    let message: String
}

enum StorefrontError: Error {
    case requestFailed
    case decodingFailed
}

enum CartError: Error {
    case userError(String)
    case cartNotCreated
}
// [END complete-tutorial.response-types]
