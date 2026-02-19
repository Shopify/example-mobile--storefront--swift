// [START complete-tutorial.display-products]
import SwiftUI

struct ProductListView: View {
    @StateObject private var viewModel = ProductListViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.products) { product in
                ProductRow(
                    product: product,
                    onAddToCart: { viewModel.addToCart(product: product) }
                )
            }
            .navigationTitle("Products")
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
        }
        .task {
            await viewModel.loadProducts()
        }
    }
}

struct ProductRow: View {
    let product: Product
    let onAddToCart: () -> Void

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: product.featuredImage?.url ?? "")) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 60, height: 60)
            .cornerRadius(8)

            VStack(alignment: .leading) {
                Text(product.title)
                    .font(.headline)
                if let price = product.variants.edges.first?.node.price {
                    Text("$\(price.amount) \(price.currencyCode)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Button("Add to Cart") {
                onAddToCart()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

@MainActor
class ProductListViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false

    private let client = StorefrontClient(
        shopDomain: "{shop}.myshopify.com",
        accessToken: "your-storefront-access-token"
    )

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            products = try await client.fetchProducts()
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    func addToCart(product: Product) {
        guard let variantId = product.firstVariantId else { return }
        Task {
            do {
                let cart = try await client.createCart(variantId: variantId)
                print("Checkout URL: \(cart.checkoutUrl)")
            } catch {
                print("Failed to create cart: \(error)")
            }
        }
    }
}
// [END complete-tutorial.display-products]
