import SwiftUI

struct RootView: View {
	@ObservedObject private var auth = AuthService.shared
	var body: some View {
		TabView {
			BrowseView()
				.tabItem { Label("Browse", systemImage: "bag") }
			MapScreen()
				.tabItem { Label("Map", systemImage: "map") }
			Group {
				if auth.isSignedIn { BusinessDashboardView() } else { SignInView() }
			}
			.tabItem { Label("Dashboard", systemImage: "square.grid.2x2") }
		}
	}
}