import Foundation

/// Product identifiers are unique strings registered on the app store.
public typealias ProductIdentifier = String

public class IAPProducts {
    private static let PREFIX = NSBundle.mainBundle().objectForInfoDictionaryKey("BUNDLE_IDENTIFIER") as! String + "."
    
    public static let HINTS_X2 = "\(PREFIX)hintsX2"
    public static let HINTS_1 = "\(PREFIX)hints1"
    public static let HINTS_2 = "\(PREFIX)hints2"
    public static let HINTS_3 = "\(PREFIX)hints3"
    public static let HINTS_4 = "\(PREFIX)hints4"
    public static let HINTS_5 = "\(PREFIX)hints5"
    public static let HINTS_6 = "\(PREFIX)hints6"

    public static let CONSUMABLE: Set<ProductIdentifier> = [
        HINTS_1,
        HINTS_2,
        HINTS_3,
        HINTS_4,
        HINTS_5,
        HINTS_6
    ]
    
    public static let OTHER: Set<ProductIdentifier> = [
        HINTS_X2
    ]
    
    public static let NON_CONSUMABLE: Set<ProductIdentifier> = OTHER
    
    public static let ALL: Set<ProductIdentifier> = NON_CONSUMABLE.union(CONSUMABLE)

    public static func getProductRef(productIdentifier: String) -> String? {
        return productIdentifier.componentsSeparatedByString(".").last
    }
    
    public static func isConsumable(productId: ProductIdentifier) -> Bool {
        return CONSUMABLE.contains(productId)
    }
    
    public static func isNonConsumbale(productId: ProductIdentifier) -> Bool {
        return NON_CONSUMABLE.contains(productId)
    }
}
