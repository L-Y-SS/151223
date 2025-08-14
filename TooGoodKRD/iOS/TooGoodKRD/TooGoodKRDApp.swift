import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging
import UserNotifications
import UIKit
import StripePaymentSheet

@main
struct TooGoodKRDApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

	var body: some Scene {
		WindowGroup {
			RootView()
		}
	}
}

final class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		FirebaseApp.configure()
		StripeAPI.defaultPublishableKey = AppConfig.stripePublishableKey
		registerForPushNotifications()
		Messaging.messaging().delegate = self
		return true
	}

	private func registerForPushNotifications() {
		UNUserNotificationCenter.current().delegate = self
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
			DispatchQueue.main.async {
				UIApplication.shared.registerForRemoteNotifications()
			}
		}
	}

	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		Messaging.messaging().apnsToken = deviceToken
	}

	func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
		// Token available for topic subscription per city
	}

	// Foreground notification
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		completionHandler([.banner, .sound])
	}
}