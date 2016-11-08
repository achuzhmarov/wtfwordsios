import UIKit

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
    weak var transitionManager: BaseTransitionManager!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch (operation) {
            case .push:
                return transitionManager.animationController(
                    forPresented: navigationController, presenting: toVC, source: fromVC
                )
            case .pop:
                return transitionManager.animationController(forDismissed: fromVC)
            case .none:
                return transitionManager
        }
    }

    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if (transitionManager.presenting) {
            return transitionManager.interactionControllerForPresentation(animator: animationController)
        } else {
            return transitionManager.interactionControllerForDismissal(animator: animationController)
        }
    }
}
