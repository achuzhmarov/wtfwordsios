import UIKit

class FadeTransitionManager: BaseTransitionManager  {
    override func addViewsToContainer() {
        //add modal window after main

        if (presenting) {
            container.addSubview(fromView)
            container.addSubview(toView)
        } else {
            container.addSubview(toView)
            container.addSubview(fromView)
        }
    }

    override func preAnimate() {
        if (presenting) {
            toView.alpha = 0
        }
    }

    override func animate() {
        // either fade in or fade out
        if (presenting) {
            toView.alpha = 1
        } else {
            fromView.alpha = 0
        }
    }
}
