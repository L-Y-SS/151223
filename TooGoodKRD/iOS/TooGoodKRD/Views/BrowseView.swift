import SwiftUI

struct BrowseView: View {
	@StateObject private var vm = BrowseViewModel()

	var body: some View {
		NavigationStack {
			VStack(spacing: 8) {
				filters
				list
			}
			.padding(.horizontal)
			.navigationTitle("Find Deals")
		}
		.onAppear { vm.start() }
		.onDisappear { vm.stop() }
	}

	private var filters: some View {
		HStack {
			Menu(vm.selectedCity?.rawValue ?? "City") {
				Button("All") { vm.selectedCity = nil; vm.start() }
				ForEach(City.allCases) { city in Button(city.rawValue) { vm.selectedCity = city; vm.start() } }
			}
			Spacer()
			Menu(vm.selectedCategory?.rawValue ?? "Category") {
				Button("All") { vm.selectedCategory = nil; vm.start() }
				ForEach(Category.allCases) { cat in Button(cat.rawValue) { vm.selectedCategory = cat; vm.start() } }
			}
		}
	}

	private var list: some View {
		List(vm.items) { item in
			NavigationLink(destination: ItemDetailView(item: item)) {
				VStack(alignment: .leading, spacing: 4) {
					Text(item.name).font(.headline)
					Text("$\(String(format: "%.2f", Double(item.priceCents)/100)) • \(item.city.rawValue)").font(.subheadline).foregroundColor(.secondary)
				}
			}
		}
		.listStyle(.plain)
	}
}