import Foundation

struct AppConfig {
	// Replace with your keys
	static let stripePublishableKey: String = "pk_test_REPLACE_ME"
	static let appleMerchantId: String = "merchant.com.your.merchant"

	// Feature flags
	static let enableSampleSeeding: Bool = false

	// Regions
	static let supportedCities: [String] = ["Duhok", "Zakho"]
	static let defaultCurrencyCode: String = "IQD"
}