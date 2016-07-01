import Foundation

class CipherPageViewController: UIPageViewController {
    private let cipherTypes = CipherType.getAll()
    private var activeCipherIndex = 0

    private var currentViewController: CipherViewController?

    private var viewControllersCache = [Int: CipherViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.whiteColor()

        dataSource = self

        initViewControllers()

        if let viewController = singleModeViewController(activeCipherIndex) {
            let viewControllers = [viewController]
            setViewControllers(viewControllers,
                    direction: .Forward,
                    animated: false,
                    completion: nil)

            currentViewController = viewController
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        notifyParentForViewUpdate(currentViewController!)
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
            viewControllersCache[index] = page
            return page
        }

        return nil
    }

    private func notifyParentForViewUpdate(newController: CipherViewController) {
        currentViewController = newController
        let parent = self.parentViewController as! SingleModeViewController
        parent.cipherViewUpdated(newController)
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

            activeCipherIndex = index

            let page = singleModeViewController(index)
            notifyParentForViewUpdate(page!)
            return page
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

            activeCipherIndex = index

            let page = singleModeViewController(index)
            notifyParentForViewUpdate(page!)
            return page
        }
        return nil
    }

    // MARK: UIPageControl
    /*func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return cipherTypes.count
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return activeCipherIndex ?? 0
    }*/
}
