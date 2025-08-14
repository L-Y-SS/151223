import Foundation
import FirebaseAuth

final class AuthService: ObservableObject {
	static let shared = AuthService()
	@Published var isSignedIn: Bool = Auth.auth().currentUser != nil
	private init() {
		Auth.auth().addStateDidChangeListener { _, user in
			DispatchQueue.main.async { self.isSignedIn = user != nil }
		}
	}

	func signIn(email: String, password: String) async throws {
		_ = try await Auth.auth().signIn(withEmail: email, password: password)
	}

	func signUp(email: String, password: String) async throws {
		_ = try await Auth.auth().createUser(withEmail: email, password: password)
	}

	func signOut() throws { try Auth.auth().signOut() }
}