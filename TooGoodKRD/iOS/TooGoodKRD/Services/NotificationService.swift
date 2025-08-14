import Foundation
import FirebaseMessaging

enum NotificationService {
	static func subscribe(to city: City) {
		Messaging.messaging().subscribe(toTopic: "city_\(city.rawValue)")
	}
	static func unsubscribe(from city: City) {
		Messaging.messaging().unsubscribe(fromTopic: "city_\(city.rawValue)")
	}
}