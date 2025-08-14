import SwiftUI
import MapKit

struct MapScreen: View {
	@State private var selectedCity: City = .Duhok
	@State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 36.8671, longitude: 42.9885), span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3))
	@State private var businesses: [Business] = []

	var body: some View {
		NavigationStack {
			VStack(spacing: 8) {
				Picker("City", selection: $selectedCity) {
					Text("Duhok").tag(City.Duhok)
					Text("Zakho").tag(City.Zakho)
				}
				.pickerStyle(.segmented)
				.onChange(of: selectedCity) { newCity in
					NotificationService.subscribe(to: newCity)
					loadBusinesses()
				}
				Map(coordinateRegion: $region, annotationItems: businesses) { business in
					MapAnnotation(coordinate: business.coordinate) {
						NavigationLink(destination: BusinessDetailView(business: business)) {
							Image(systemName: "mappin.circle.fill").font(.title).foregroundColor(.orange)
						}
					}
				}
			}
			.padding(.horizontal)
			.navigationTitle("Map")
		}
		.onAppear {
			NotificationService.subscribe(to: selectedCity)
			loadBusinesses()
		}
	}

	private func loadBusinesses() {
		Task {
			var center: CLLocationCoordinate2D
			switch selectedCity {
			case .Duhok: center = CLLocationCoordinate2D(latitude: 36.8671, longitude: 42.9885)
			case .Zakho: center = CLLocationCoordinate2D(latitude: 37.1440, longitude: 42.6734)
			}
			region = .init(center: center, span: .init(latitudeDelta: 0.25, longitudeDelta: 0.25))
			for try await list in FirebaseService.shared.listenBusinesses(in: selectedCity) as AsyncThrowingStream<[Business], Error> {
				self.businesses = list
			}
		}
	}
}

struct BusinessDetailView: View {
	let business: Business
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text(business.name).font(.title2).bold()
			Text(business.category.rawValue)
			Text("City: \(business.city.rawValue)")
			Text("Phone: \(business.contactPhone)")
		}
		.padding()
		.navigationTitle("Store")
	}
}