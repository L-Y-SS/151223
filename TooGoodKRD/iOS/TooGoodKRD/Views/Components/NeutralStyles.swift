import SwiftUI

struct NeutralColors {
	static let background = Color(UIColor.systemBackground)
	static let primary = Color(UIColor.label)
	static let secondary = Color(UIColor.secondaryLabel)
	static let accent = Color(UIColor.systemGray3)
}

struct MinimalButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.font(.body)
			.foregroundColor(.white)
			.padding(.vertical, 10)
			.frame(maxWidth: .infinity)
			.background(NeutralColors.accent.cornerRadius(8))
	}
}