import SwiftUI
import FirebaseAuth

struct ItemDetailView: View {
	let item: Item
	@State private var pickupTime: Date = Date()
	@State private var isPaying: Bool = false
	@State private var errorMessage: String?

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 12) {
				Text(item.name).font(.largeTitle).bold()
				Text("Price: $\(String(format: "%.2f", Double(item.priceCents)/100))")
				DatePicker("Pick-up time", selection: $pickupTime, in: item.pickupStart...item.pickupEnd, displayedComponents: [.hourAndMinute])
				Button(action: pay) {
					Label("Checkout", systemImage: "creditcard")
				}
				.buttonStyle(.borderedProminent)
				.disabled(isPaying)
				if let errorMessage { Text(errorMessage).foregroundColor(.red) }
			}
			.padding()
		}
		.navigationTitle(item.name)
	}

	private func pay() {
		isPaying = true
		PaymentService.shared.checkout(amountCents: item.priceCents) { result in
			isPaying = false
			switch result {
			case .success:
				Task {
					let uid = Auth.auth().currentUser?.uid ?? "anonymous"
					let order = Order(id: nil, itemId: item.id ?? "", buyerUserId: uid, quantity: 1, amountCents: item.priceCents, status: .paid, pickupTime: pickupTime, createdAt: Date())
					_ = try? await FirebaseService.shared.createOrder(order)
				}
			case .failure(let error): errorMessage = error.localizedDescription
			}
		}
	}
}