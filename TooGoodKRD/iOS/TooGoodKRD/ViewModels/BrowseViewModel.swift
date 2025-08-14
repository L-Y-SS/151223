import Foundation

@MainActor
final class BrowseViewModel: ObservableObject {
	@Published var items: [Item] = []
	@Published var selectedCity: City? = nil
	@Published var selectedCategory: Category? = nil
	@Published var isLoading: Bool = false
	private var streamTask: Task<Void, Never>?

	func start() {
		isLoading = true
		streamTask?.cancel()
		streamTask = Task {
			for try await result in FirebaseService.shared.listenItems(city: selectedCity, category: selectedCategory) as AsyncThrowingStream<[Item], Error> {
				self.items = result
				self.isLoading = false
			}
		}
	}

	func stop() { streamTask?.cancel() }
}