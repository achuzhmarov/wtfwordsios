import UIKit

class PanTransitionManager: BaseTransitionManager  {

    fileprivate var offScreenBack: CGAffineTransform!
    fileprivate var offScreenForward: CGAffineTransform!

    var unwindSegue: (() -> Void)!

    func handleOffstagePan(_ pan: UIPanGestureRecognizer){
        let translation = pan.translation(in: pan.view!.superview!)
        let d = -translation.y / pan.view!.superview!.frame.height

        switch (pan.state) {

        case UIGestureRecognizerState.began:
            interactive = true
            unwindSegue()
            break
        case UIGestureRecognizerState.changed:
            update(d)
            break
        default: // .Ended, .Cancelled, .Failed ...
            interactive = false

            if(d > 0.15){
                self.finish()
            }
            else {
                self.cancel()
            }
        }
    }

    override func preAnimate() {
        offScreenBack = CGAffineTransform(translationX: 0, y: -container.frame.height)
        offScreenForward = CGAffineTransform(translationX: 0, y: container.frame.height)

        // prepare the toView for the animation
        toView.transform = presenting ? offScreenBack : offScreenForward
    }

    override func animate() {
        // slide fromView off either the left or right edge of the screen
        // depending if we're presenting or dismissing this view
        fromView.transform = presenting ? offScreenForward : offScreenBack
        toView.transform = CGAffineTransform.identity
    }
}
