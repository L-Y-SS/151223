import UIKit

extension UIApplication {
	static func rootViewController() -> UIViewController? {
		guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return nil }
		return scene.windows.first(where: { $0.isKeyWindow })?.rootViewController
	}
	static func topViewController(base: UIViewController? = UIApplication.rootViewController()) -> UIViewController? {
		if let nav = base as? UINavigationController { return topViewController(base: nav.visibleViewController) }
		if let tab = base as? UITabBarController { return topViewController(base: tab.selectedViewController) }
		if let presented = base?.presentedViewController { return topViewController(base: presented) }
		return base
	}
}