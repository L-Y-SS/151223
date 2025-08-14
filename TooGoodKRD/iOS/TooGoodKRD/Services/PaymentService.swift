import Foundation
import StripePaymentSheet
import FirebaseFunctions

final class PaymentService: ObservableObject {
	static let shared = PaymentService()
	private let functions = Functions.functions()
	@Published var lastPaymentSucceeded: Bool = false
	private var paymentSheet: PaymentSheet?

	private init() {}

	func checkout(amountCents: Int, completion: @escaping (Result<Void, Error>) -> Void) {
		functions.httpsCallable("createPaymentIntent").call(["amount": amountCents]) { [weak self] result, error in
			if let error { completion(.failure(error)); return }
			guard let clientSecret = (result?.data as? [String: Any])?["clientSecret"] as? String else {
				completion(.failure(NSError(domain: "Stripe", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing client secret"]))); return
			}
			var config = PaymentSheet.Configuration()
			config.merchantDisplayName = "TooGoodKRD"
			if !AppConfig.appleMerchantId.isEmpty {
				config.applePay = .init(merchantId: AppConfig.appleMerchantId, merchantCountryCode: "US")
			}
			self?.paymentSheet = PaymentSheet(paymentIntentClientSecret: clientSecret, configuration: config)
			guard let vc = UIApplication.topViewController(), let sheet = self?.paymentSheet else {
				completion(.failure(NSError(domain: "UI", code: 0, userInfo: [NSLocalizedDescriptionKey: "No presenter"]))); return
			}
			sheet.present(from: vc) { paymentResult in
				switch paymentResult {
				case .completed:
					self?.lastPaymentSucceeded = true
					completion(.success(()))
				case .canceled:
					completion(.failure(NSError(domain: "Stripe", code: 1, userInfo: [NSLocalizedDescriptionKey: "Canceled"])) )
				case .failed(let error):
					completion(.failure(error))
				}
			}
		}
	}
}