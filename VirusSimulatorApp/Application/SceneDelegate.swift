import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        window?.overrideUserInterfaceStyle = .light

        let settingsVC = SettingsViewController()
        let settingsNavBar = UINavigationController(rootViewController: settingsVC)

        window?.rootViewController = settingsNavBar
        window?.makeKeyAndVisible()
    }
}

