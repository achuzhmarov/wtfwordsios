import Foundation

class ReplaceSegue: UIStoryboardSegue {
    override func perform() {
        let navigationController = source.navigationController!
        var controllerStack = navigationController.viewControllers

        let sourceIndex = controllerStack.index(of: source)!
        controllerStack[sourceIndex] = destination

        navigationController.setViewControllers(controllerStack, animated: true)
    }
}
