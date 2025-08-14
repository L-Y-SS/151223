import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

final class FirebaseService {
	static let shared = FirebaseService()
	let db = Firestore.firestore()

	private init() {}

	// Auth
	func signInAnonymouslyIfNeeded() async throws {
		if Auth.auth().currentUser == nil {
			_ = try await Auth.auth().signInAnonymously()
		}
	}

	// Users
	func upsertUser(_ user: AppUser) async throws {
		guard let uid = Auth.auth().currentUser?.uid else { return }
		var u = user
		u.id = uid
		try db.collection("users").document(uid).setData(from: u, merge: true)
	}

	// Businesses
	func createBusiness(_ business: Business) async throws {
		_ = try db.collection("businesses").addDocument(from: business)
	}

	func listenBusinesses(in city: City) -> AsyncThrowingStream<[Business], Error> {
		let query = db.collection("businesses").whereField("city", isEqualTo: city.rawValue)
		return listenCollection(query: query)
	}

	func listenMyBusiness(ownerUserId: String) -> AsyncThrowingStream<[Business], Error> {
		let query = db.collection("businesses").whereField("ownerUserId", isEqualTo: ownerUserId)
		return listenCollection(query: query)
	}

	// Items
	func createItem(_ item: Item) async throws {
		_ = try db.collection("items").addDocument(from: item)
	}

	func updateItem(_ item: Item) async throws {
		guard let id = item.id else { return }
		try db.collection("items").document(id).setData(from: item, merge: true)
	}

	func listenItems(city: City?, category: Category?) -> AsyncThrowingStream<[Item], Error> {
		var query: Query = db.collection("items").order(by: "createdAt", descending: true)
		if let city { query = query.whereField("city", isEqualTo: city.rawValue) }
		if let category { query = query.whereField("category", isEqualTo: category.rawValue) }
		return listenCollection(query: query)
	}

	func listenItemsForBusiness(_ businessId: String) -> AsyncThrowingStream<[Item], Error> {
		let query = db.collection("items").whereField("businessId", isEqualTo: businessId).order(by: "createdAt", descending: true)
		return listenCollection(query: query)
	}

	// Orders
	func createOrder(_ order: Order) async throws -> String {
		let ref = try db.collection("orders").addDocument(from: order)
		return ref.documentID
	}

	// Generic collection listener
	private func listenCollection<T: Decodable>(query: Query) -> AsyncThrowingStream<[T], Error> {
		AsyncThrowingStream { continuation in
			let listener = query.addSnapshotListener { snapshot, error in
				if let error { continuation.finish(throwing: error); return }
				guard let docs = snapshot?.documents else { continuation.yield([]); return }
				do {
					let values: [T] = try docs.map { try $0.data(as: T.self) }
					continuation.yield(values)
				} catch {
					continuation.finish(throwing: error)
				}
			}
			continuation.onTermination = { _ in listener.remove() }
		}
	}
}