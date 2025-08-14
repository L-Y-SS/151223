import Foundation
import CoreLocation

final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
	static let shared = LocationService()
	private let manager = CLLocationManager()
	@Published var coordinate: CLLocationCoordinate2D?

	private override init() {
		super.init()
		manager.delegate = self
	}

	func requestOnce() {
		manager.requestWhenInUseAuthorization()
		manager.requestLocation()
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		coordinate = locations.first?.coordinate
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
}