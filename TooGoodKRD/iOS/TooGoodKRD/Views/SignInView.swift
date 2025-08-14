import SwiftUI

struct SignInView: View {
	@StateObject private var vm = AuthViewModel()
	var body: some View {
		VStack(spacing: 12) {
			Text("Business Sign In").font(.title2).bold()
			TextField("Email", text: $vm.email)
				.textContentType(.emailAddress)
				.keyboardType(.emailAddress)
				.textInputAutocapitalization(.never)
			SecureField("Password", text: $vm.password)
			HStack {
				Button("Sign In") { Task { await vm.signIn() } }
					.buttonStyle(.borderedProminent)
				Button("Sign Up") { Task { await vm.signUp() } }
			}
			if let error = vm.error { Text(error).foregroundColor(.red).font(.footnote) }
		}
		.padding()
	}
}