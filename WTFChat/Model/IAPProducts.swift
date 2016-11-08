import Foundation

/// Product identifiers are unique strings registered on the app store.
public typealias ProductIdentifier = String

open class IAPProducts {
    fileprivate static let PREFIX = Bundle.main.object(forInfoDictionaryKey: "BUNDLE_IDENTIFIER") as! String + "."
    
    open static let HINTS_X2 = "\(PREFIX)hintsX2"
    open static let HINTS_1 = "\(PREFIX)hints1"
    open static let HINTS_2 = "\(PREFIX)hints2"
    open static let HINTS_3 = "\(PREFIX)hints3"
    open static let HINTS_4 = "\(PREFIX)hints4"
    open static let HINTS_5 = "\(PREFIX)hints5"
    open static let HINTS_6 = "\(PREFIX)hints6"

    open static let CONSUMABLE: Set<ProductIdentifier> = [
        HINTS_1,
        HINTS_2,
        HINTS_3,
        HINTS_4,
        HINTS_5,
        HINTS_6
    ]
    
    open static let OTHER: Set<ProductIdentifier> = [
        HINTS_X2
    ]
    
    open static let NON_CONSUMABLE: Set<ProductIdentifier> = OTHER
    
    open static let ALL: Set<ProductIdentifier> = NON_CONSUMABLE.union(CONSUMABLE)

    open static func getProductRef(_ productIdentifier: String) -> String? {
        return productIdentifier.components(separatedBy: ".").last
    }
    
    open static func isConsumable(_ productId: ProductIdentifier) -> Bool {
        return CONSUMABLE.contains(productId)
    }
    
    open static func isNonConsumbale(_ productId: ProductIdentifier) -> Bool {
        return NON_CONSUMABLE.contains(productId)
    }
}
