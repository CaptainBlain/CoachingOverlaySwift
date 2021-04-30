import UIKit

@available(iOS 13.0, *)
extension UIApplication {
    var activeScene: UIWindowScene? {
        let scene = connectedScenes.filter { $0.activationState == .foregroundActive }.first
        return scene as? UIWindowScene
    }
}
