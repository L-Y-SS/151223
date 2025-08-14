import SwiftUI

struct BusinessDashboardView: View {
	@StateObject private var vm = BusinessViewModel()
	@State private var showAddItem = false

	var body: some View {
		NavigationStack {
			Group {
				if let _ = vm.myBusiness {
					VStack(alignment: .leading, spacing: 12) {
						Button("Add Item") { showAddItem = true }
							.buttonStyle(.bordered)
						List {
							ForEach(vm.myItems) { item in
								HStack {
									VStack(alignment: .leading) {
										Text(item.name)
										Text("$\(String(format: "%.2f", Double(item.priceCents)/100))").font(.caption).foregroundColor(.secondary)
									}
									Spacer()
									Toggle("Sold", isOn: Binding(get: { item.isSoldOut }, set: { newValue in
										var updated = item
										updated.isSoldOut = newValue
										Task { await vm.updateItem(updated) }
									}))
									.labelsHidden()
								}
							}
						}
						.listStyle(.plain)
					}
				} else {
					BusinessRegistrationView(onRegistered: { /* no-op, listener will pick it up */ })
				}
			}
			.padding(.horizontal)
			.navigationTitle("Dashboard")
		}
		.onAppear { vm.start() }
		.onDisappear { vm.stop() }
		.sheet(isPresented: $showAddItem) {
			if let businessId = vm.myBusiness?.id {
				AddItemSheet(businessId: businessId) { newItem in
					Task { await vm.addItem(newItem) }
				}
			}
		}
	}
}

struct BusinessRegistrationView: View {
	var onRegistered: () -> Void
	@State private var name: String = ""
	@State private var city: City = .Duhok
	@State private var category: Category = .Bakery
	@State private var phone: String = ""
	@State private var latitude: Double? = nil
	@State private var longitude: Double? = nil
	@Environment(\.dismiss) private var dismiss
	@StateObject private var vm = BusinessViewModel()

	var body: some View {
		Form {
			Section("Business") {
				TextField("Name", text: $name)
				Picker("City", selection: $city) { ForEach(City.allCases) { Text($0.rawValue).tag($0) } }
				Picker("Category", selection: $category) { ForEach(Category.allCases) { Text($0.rawValue).tag($0) } }
				TextField("Phone", text: $phone)
			}
			Section("Location") {
				HStack {
					Text("Lat: \(latitude ?? 0), Lon: \(longitude ?? 0)")
					Spacer()
					Button("Use Current") { LocationService.shared.requestOnce(); self.latitude = LocationService.shared.coordinate?.latitude; self.longitude = LocationService.shared.coordinate?.longitude }
				}
			}
		}
		.toolbar {
			ToolbarItem(placement: .confirmationAction) { Button("Register") { Task { await register() } } }
		}
		.navigationTitle("Register Store")
	}

	private func register() async {
		guard let lat = latitude, let lon = longitude else { return }
		let business = Business(id: nil, ownerUserId: "", name: name, city: city, category: category, latitude: lat, longitude: lon, contactPhone: phone, createdAt: Date())
		await vm.createBusiness(business)
		onRegistered()
		dismiss()
	}
}

struct AddItemSheet: View {
	let businessId: String
	var onSave: (Item) -> Void
	@Environment(\.dismiss) private var dismiss
	@State private var name: String = ""
	@State private var priceCents: Int = 1000
	@State private var quantity: Int = 1
	@State private var expiryDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
	@State private var pickupStart: Date = Date()
	@State private var pickupEnd: Date = Calendar.current.date(byAdding: .hour, value: 4, to: Date())!
	@State private var category: Category = .Bakery
	@State private var city: City = .Duhok

	var body: some View {
		NavigationStack {
			Form {
				Section("Details") {
					TextField("Name", text: $name)
					Stepper("Price cents: \(priceCents)", value: $priceCents, in: 100...500000, step: 100)
					Stepper("Quantity: \(quantity)", value: $quantity, in: 1...100)
					DatePicker("Expiry", selection: $expiryDate, displayedComponents: [.date])
					Picker("Category", selection: $category) { ForEach(Category.allCases) { Text($0.rawValue).tag($0) } }
					Picker("City", selection: $city) { ForEach(City.allCases) { Text($0.rawValue).tag($0) } }
				}
				Section("Pickup") {
					DatePicker("From", selection: $pickupStart, displayedComponents: [.hourAndMinute])
					DatePicker("To", selection: $pickupEnd, displayedComponents: [.hourAndMinute])
				}
			}
			.toolbar {
				ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
				ToolbarItem(placement: .confirmationAction) { Button("Save") { save() } }
			}
			.navigationTitle("New Item")
		}
	}

	private func save() {
		let item = Item(id: nil, businessId: businessId, name: name, quantity: quantity, expiryDate: expiryDate, priceCents: priceCents, pickupStart: pickupStart, pickupEnd: pickupEnd, category: category, city: city, isSoldOut: false)
		onSave(item)
		dismiss()
	}
}