import Foundation

class CipherPageViewController: UIPageViewController, CipherViewAppearedNotifier {
    private let cipherTypes = CipherType.getAll()
    private var activeCipherIndex = 0

    private var viewControllersCache = [Int: CipherViewController]()

    private var currentCipherViewController: CipherViewController?

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
        }
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



    // MARK: UIPageControl
    /*func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return cipherTypes.count
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return activeCipherIndex ?? 0
    }*/
}
