import Foundation

class BaseTransitionManager: UIPercentDrivenInteractiveTransition,
        UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {

    var presenting = false
    var interactive = false

    var container: UIView!
    var fromView: UIView!
    var toView: UIView!

    var animationDuration = 0.5

    fileprivate var transitionContext: UIViewControllerContextTransitioning!

    var externalCompletionHandler: (() -> Void)?

    // MARK: UIViewControllerAnimatedTransitioning protocol methods

    // animate a change from one viewcontroller to another
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext

        // get reference to our fromView, toView and the container view that we should perform the transition in
        container = transitionContext.containerView

        let screens : (from:UIViewController, to:UIViewController) = (
            transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!,
            transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        )

        toView = screens.to.view
        fromView = screens.from.view

        // fix for bug in iOS 9 - if rotated after transition
        toView.frame.size = transitionContext.finalFrame(for: screens.to).size
        (screens.to as? BaseUIViewController)?.updateBackgroundGradient(toView.frame.size)

        addViewsToContainer()

        preAnimate()

        let duration = self.transitionDuration(using: transitionContext)

        UIView.animate(withDuration: duration, delay: 0, options: [], animations: animate, completion: completion)
    }

    func addViewsToContainer() {
        // add the both views to our view controller
        container.addSubview(toView)
        container.addSubview(fromView)
    }

    func preAnimate() {
        //do nothing by default
    }

    func animate() {
        fatalError("This method must be overridden")
    }

    func completion(_ finished: Bool) {
        // tell our transitionContext object that we've finished animating
        if(transitionContext.transitionWasCancelled){
            transitionContext.completeTransition(false)

            // bug: we have to manually add our 'from view' back http://openradar.appspot.com/radar?id=5320103646199808
            UIApplication.shared.keyWindow!.addSubview(fromView)
        }
        else {
            transitionContext.completeTransition(true)

            // bug: we have to manually add our 'to view' back http://openradar.appspot.com/radar?id=5320103646199808
            UIApplication.shared.keyWindow!.addSubview(toView)
        }

        //oneTime use only
        externalCompletionHandler?()
        externalCompletionHandler = nil
    }

    // return how many seconds the transiton animation will take
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }

    // MARK: UIViewControllerTransitioningDelegate protocol methods

    // return the animataor when presenting a viewcontroller
    // rememeber that an animator (or animation controller) is any object that aheres to the UIViewControllerAnimatedTransitioning protocol
    func animationController(forPresented presented: UIViewController,
                                                   presenting: UIViewController,
                                                   source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = true
        return self
    }

    // return the animator used when dismissing from a viewcontroller
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = false
        return self
    }

    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // if our interactive flag is true, return the transition manager object
        // otherwise return nil
        return interactive ? self : nil
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactive ? self : nil
    }
}
