import Foundation

class ReplaceSegue: UIStoryboardSegue {
    override func perform() {
        let navigationController = sourceViewController.navigationController!
        var controllerStack = navigationController.viewControllers

        let sourceIndex = controllerStack.indexOf(sourceViewController)!
        controllerStack[sourceIndex] = destinationViewController

        navigationController.setViewControllers(controllerStack, animated: true)
    }
}
