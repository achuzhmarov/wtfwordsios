import Foundation

class CipherPageViewController: UIPageViewController, CipherViewAppearedNotifier {
    fileprivate let guiDataService: GuiDataService = serviceLocator.get(GuiDataService.self)

    fileprivate let cipherTypes = CipherType.getAll()
    fileprivate var viewControllersCache = [Int: CipherViewController]()

    fileprivate var currentCipherViewController: CipherViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clear

        dataSource = self

        initViewControllers()

        showPage(guiDataService.getLastSelectedCategoryType().rawValue)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let parent = self.parent as! SingleModeViewController
        parent.cipherViewUpdated(currentCipherViewController!)
    }

    fileprivate func initViewControllers() {
        for i in 0..<cipherTypes.count {
            _ = singleModeViewController(i)
        }
    }

    fileprivate func singleModeViewController(_ index: Int) -> CipherViewController? {
        if let cachedController = viewControllersCache[index] {
            return cachedController
        } else if let storyboard = storyboard, let page = storyboard.instantiateViewController(withIdentifier: "CipherViewController") as? CipherViewController {
            page.activeCipherIndex = index
            page.cipherViewAppearedNotifier = self
            viewControllersCache[index] = page
            return page
        }

        return nil
    }

    func cipherViewAppeared(_ viewController: CipherViewController) {
        currentCipherViewController = viewController

        if let parent = self.parent as? SingleModeViewController {
            parent.cipherViewUpdated(viewController)
        }
    }

    func showPage(_ index: Int){
        var direction: UIPageViewControllerNavigationDirection!
        var animated: Bool!

        if let currentIndex = currentCipherViewController?.activeCipherIndex {
            animated = true

            if currentIndex > index {
                direction = .reverse
            } else {
                direction = .forward
            }
        } else {
            animated = false
            direction = .forward
        }

        if let viewController = singleModeViewController(index) {
            let viewControllers = [viewController]
            setViewControllers(viewControllers, direction: direction, animated: animated, completion: nil)
        }
    }

    func reloadData() {
        currentCipherViewController?.reloadData()
    }
}

//MARK: implementation of UIPageViewControllerDataSource
extension CipherPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {

        if let viewController = viewController as? CipherViewController {
            var index = viewController.activeCipherIndex
            guard index != NSNotFound && index != 0 else { return nil }
            index = index - 1
            return singleModeViewController(index)
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {

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
