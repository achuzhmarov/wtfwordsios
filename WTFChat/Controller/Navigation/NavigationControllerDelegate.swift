import UIKit

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
    weak var transitionManager: BaseTransitionManager!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch (operation) {
            case .Push:
                return transitionManager.animationControllerForPresentedController(
                    navigationController, presentingController: toVC, sourceController: fromVC
                )
            case .Pop:
                return transitionManager.animationControllerForDismissedController(fromVC)
            case .None:
                return transitionManager
        }
    }

    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if (transitionManager.presenting) {
            return transitionManager.interactionControllerForPresentation(animationController)
        } else {
            return transitionManager.interactionControllerForDismissal(animationController)
        }
    }
}