import Foundation
import CoreData

class CoreSingleModeCategory: NSManagedObject {
    func updateFromSingleModeCategoryWithoutLevels(singleModeCategory: SingleModeCategory) {
        self.cipherType = singleModeCategory.cipherType.rawValue
    }

    func getSingleModeCategory() -> SingleModeCategory? {
        let enumCipherType = CipherType(rawValue: Int(self.cipherType!))

        let category = SingleModeCategory(
            cipherType: enumCipherType!
        )

        var domainLevels = [Level]()

        for item in self.levels! {
            if let coreLevel = item as? CoreLevel {
                let domainLevel = coreLevel.getLevel()
                domainLevel.category = category
                domainLevels.append(domainLevel)
            }
        }

        category.levels = domainLevels
        category.setCoreSingleModeCategory(self)

        return category
    }
}
