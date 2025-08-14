import Foundation
import FirebaseFirestoreSwift
import CoreLocation

/// Supported cities in Kurdistan region
enum City: String, Codable, CaseIterable, Identifiable { case Duhok, Zakho; var id: String { rawValue } }

/// Store categories
enum Category: String, Codable, CaseIterable, Identifiable {
	case Bakery, Grocery, Restaurant, Cafe, Other
	var id: String { rawValue }
}

/// App user profile
struct AppUser: Identifiable, Codable {
	@DocumentID var id: String?
	var email: String
	var role: UserRole
	var favoriteCity: City?
	var createdAt: Date = Date()
}

enum UserRole: String, Codable { case customer, business }

/// Business store
struct Business: Identifiable, Codable {
	@DocumentID var id: String?
	var ownerUserId: String
	var name: String
	var city: City
	var category: Category
	var latitude: Double
	var longitude: Double
	var contactPhone: String
	var createdAt: Date = Date()
}

/// Surplus/expiring item offered by a business
struct Item: Identifiable, Codable {
	@DocumentID var id: String?
	var businessId: String
	var name: String
	var quantity: Int
	var expiryDate: Date
	var priceCents: Int
	var pickupStart: Date
	var pickupEnd: Date
	var category: Category
	var city: City
	var isSoldOut: Bool = false
	var createdAt: Date = Date()
}

/// Customer order for an item
struct Order: Identifiable, Codable {
	@DocumentID var id: String?
	var itemId: String
	var buyerUserId: String
	var quantity: Int
	var amountCents: Int
	var status: OrderStatus
	var pickupTime: Date
	var createdAt: Date = Date()
}

enum OrderStatus: String, Codable { case pending, paid, cancelled, fulfilled }

extension Business {
	var coordinate: CLLocationCoordinate2D { .init(latitude: latitude, longitude: longitude) }
}