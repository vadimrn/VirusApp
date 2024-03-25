import UIKit

// MARK: - Add Subview On View
extension UIView {
    func addSubviews(_ subviews: UIView...) {
        subviews.forEach { subview in
            addSubview(subview)
        }
    }
}


// MARK: - Shake Animation
extension UIView {
    func shake(for duration: TimeInterval = 0.5,
               withTranslation translation: CGFloat = 10) {
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.3) {
            self.transform = CGAffineTransform(translationX: translation, y: 0)
        }

        animator.addAnimations({ [weak self] in
            self?.transform = .identity
        }, delayFactor: 0.2)

        animator.startAnimation()
    }
}
