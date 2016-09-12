import Foundation

class WindowService: Service {
    private let window = UIApplication.sharedApplication().delegate!.window!
    private let talkService: TalkService
    private let currentUserService: CurrentUserService

    init(talkService: TalkService, currentUserService: CurrentUserService) {
        self.talkService = talkService
        self.currentUserService = currentUserService
    }

    func showMainScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("mainTabController")
        showWindowAnimated(viewController)
    }

    func showFriendScreen(author: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let mainTabController = storyboard.instantiateViewControllerWithIdentifier("mainTabController")
                as! UITabBarController

        let friendsNavigationController = mainTabController.viewControllers![0] as! UINavigationController

        let messagesController = storyboard.instantiateViewControllerWithIdentifier("messagesController") as! MessagesViewController

        messagesController.talk = talkService.getTalkByLogin(author)

        showWindowAnimated(mainTabController)
        friendsNavigationController.pushViewController(messagesController, animated: false)
    }

    private func showWindowAnimated(viewController: UIViewController) {
        UIView.transitionWithView(window!,
                duration: 0.5,
                options: UIViewAnimationOptions.TransitionCrossDissolve,
                animations: { () -> Void in
                    let oldState = UIView.areAnimationsEnabled()
                    UIView.setAnimationsEnabled(false)
                    self.window!.rootViewController = viewController
                    UIView.setAnimationsEnabled(oldState)
                },
                completion: nil)
    }

    func getCurrentController() -> UIViewController? {
        if let viewControllers = self.window?.rootViewController?.childViewControllers {
            for viewController in viewControllers {
                if viewController.isKindOfClass(UIViewController) {
                    return viewController as UIViewController
                }
            }
        }

        return nil
    }
}
