import Foundation
import FirebaseAuth

@MainActor
final class BusinessViewModel: ObservableObject {
	@Published var myBusiness: Business?
	@Published var myItems: [Item] = []
	@Published var isSaving: Bool = false
	private var businessTask: Task<Void, Never>?
	private var itemsTask: Task<Void, Never>?

	func start() {
		businessTask?.cancel()
		guard let uid = Auth.auth().currentUser?.uid else { return }
		businessTask = Task {
			for try await list in FirebaseService.shared.listenMyBusiness(ownerUserId: uid) as AsyncThrowingStream<[Business], Error> {
				self.myBusiness = list.first
				self.startItemsListener()
			}
		}
	}

	private func startItemsListener() {
		itemsTask?.cancel()
		guard let businessId = myBusiness?.id else { return }
		itemsTask = Task {
			for try await list in FirebaseService.shared.listenItemsForBusiness(businessId) as AsyncThrowingStream<[Item], Error> {
				self.myItems = list
			}
		}
	}

	func stop() { businessTask?.cancel(); itemsTask?.cancel() }

	func createBusiness(_ business: Business) async {
		isSaving = true
		var b = business
		if let uid = Auth.auth().currentUser?.uid { b.ownerUserId = uid }
		do { try await FirebaseService.shared.createBusiness(b) } catch { }
		isSaving = false
	}

	func addItem(_ item: Item) async {
		guard let businessId = myBusiness?.id else { return }
		isSaving = true
		var newItem = item
		newItem.businessId = businessId
		do { try await FirebaseService.shared.createItem(newItem) } catch { }
		isSaving = false
	}

	func updateItem(_ item: Item) async { try? await FirebaseService.shared.updateItem(item) }
}