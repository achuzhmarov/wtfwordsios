import Foundation

class CoreSingleModeCategoryService: Service {
    private let CORE_SINGLE_MODE_CATEGORY_CLASS_NAME = "CoreSingleModeCategory"

    private let coreDataService: CoreDataService

    init(coreDataService: CoreDataService) {
        self.coreDataService = coreDataService
    }

    func createSingleModeCategory(category: SingleModeCategory) {
        let newCoreCategory = coreDataService.createObject(CORE_SINGLE_MODE_CATEGORY_CLASS_NAME) as! CoreSingleModeCategory
        category.setCoreSingleModeCategory(newCoreCategory)
        category.updateCoreSingleModeCategory()
        coreDataService.saveContext()
    }

    func updateSingleModeCategory(category: SingleModeCategory) {
        category.updateCoreSingleModeCategory()
        coreDataService.saveContext()
    }

    func getAll() -> [SingleModeCategory] {
        let fetchRequest = coreDataService.createFetch(CORE_SINGLE_MODE_CATEGORY_CLASS_NAME)
        let results = coreDataService.executeFetch(fetchRequest)

        var domainCategories = [SingleModeCategory]()

        for item in results {
            if let coreCategory = item as? CoreSingleModeCategory {
                if let domainCategory = coreCategory.getSingleModeCategory() {
                    domainCategories.append(domainCategory)
                }
            }
        }

        return domainCategories
    }
}
