import Foundation

class WindowService: Service {
    fileprivate let window = UIApplication.shared.delegate!.window!
    fileprivate let talkService: TalkService
    fileprivate let currentUserService: CurrentUserService

    init(talkService: TalkService, currentUserService: CurrentUserService) {
        self.talkService = talkService
        self.currentUserService = currentUserService
    }

    func showMainScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "mainTabController")
        showWindowAnimated(viewController)
    }

    func showFriendScreen(_ author: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let mainTabController = storyboard.instantiateViewController(withIdentifier: "mainTabController")
                as! UITabBarController

        let friendsNavigationController = mainTabController.viewControllers![0] as! UINavigationController

        let messagesController = storyboard.instantiateViewController(withIdentifier: "messagesController") as! MessagesViewController

        messagesController.talk = talkService.getTalkByLogin(author)

        showWindowAnimated(mainTabController)
        friendsNavigationController.pushViewController(messagesController, animated: false)
    }

    fileprivate func showWindowAnimated(_ viewController: UIViewController) {
        UIView.transition(with: window!,
                duration: 0.5,
                options: UIViewAnimationOptions.transitionCrossDissolve,
                animations: { () -> Void in
                    let oldState = UIView.areAnimationsEnabled
                    UIView.setAnimationsEnabled(false)
                    self.window!.rootViewController = viewController
                    UIView.setAnimationsEnabled(oldState)
                },
                completion: nil)
    }

    func getCurrentController() -> UIViewController? {
        if let viewControllers = self.window?.rootViewController?.childViewControllers {
            for viewController in viewControllers {
                if viewController.isKind(of: UIViewController.self) {
                    return viewController as UIViewController
                }
            }
        }

        return nil
    }
}
