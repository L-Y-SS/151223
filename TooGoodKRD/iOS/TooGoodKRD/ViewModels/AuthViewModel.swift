import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
	@Published var email: String = ""
	@Published var password: String = ""
	@Published var error: String?
	@Published var isLoading: Bool = false

	func signIn() async {
		isLoading = true
		do { try await AuthService.shared.signIn(email: email, password: password) } catch { self.error = error.localizedDescription }
		isLoading = false
	}

	func signUp() async {
		isLoading = true
		do { try await AuthService.shared.signUp(email: email, password: password) } catch { self.error = error.localizedDescription }
		isLoading = false
	}
}