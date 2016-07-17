import Foundation

class CipherPageViewController: UIPageViewController, CipherViewAppearedNotifier {
    private let cipherTypes = CipherType.getAll()
    private var viewControllersCache = [Int: CipherViewController]()

    private var currentCipherViewController: CipherViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clearColor()

        dataSource = self

        initViewControllers()

        showPage(0)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let parent = self.parentViewController as! SingleModeViewController
        parent.cipherViewUpdated(currentCipherViewController!)
    }

    private func initViewControllers() {
        for i in 0..<cipherTypes.count {
            singleModeViewController(i)
        }
    }

    private func singleModeViewController(index: Int) -> CipherViewController? {
        if let cachedController = viewControllersCache[index] {
            return cachedController
        } else if let storyboard = storyboard, page = storyboard.instantiateViewControllerWithIdentifier("CipherViewController") as? CipherViewController {
            page.activeCipherIndex = index
            page.cipherViewAppearedNotifier = self
            viewControllersCache[index] = page
            return page
        }

        return nil
    }

    func cipherViewAppeared(viewController: CipherViewController) {
        currentCipherViewController = viewController

        if let parent = self.parentViewController as? SingleModeViewController {
            parent.cipherViewUpdated(viewController)
        }
    }

    func showPage(index: Int){
        var direction: UIPageViewControllerNavigationDirection!
        var animated: Bool!

        if let currentIndex = currentCipherViewController?.activeCipherIndex {
            animated = true

            if currentIndex > index {
                direction = .Reverse
            } else {
                direction = .Forward
            }
        } else {
            animated = false
            direction = .Forward
        }

        if let viewController = singleModeViewController(index) {
            let viewControllers = [viewController]
            setViewControllers(viewControllers, direction: direction, animated: animated, completion: nil)
        }
    }
}

//MARK: implementation of UIPageViewControllerDataSource
extension CipherPageViewController: UIPageViewControllerDataSource {
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {

        if let viewController = viewController as? CipherViewController {
            var index = viewController.activeCipherIndex
            guard index != NSNotFound && index != 0 else { return nil }
            index = index - 1
            return singleModeViewController(index)
        }
        return nil
    }

    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {

        if let viewController = viewController as? CipherViewController {
            var index = viewController.activeCipherIndex
            guard index != NSNotFound else { return nil }
            index = index + 1
            guard index != cipherTypes.count else {return nil}
            return singleModeViewController(index)
        }
        return nil
    }
}
