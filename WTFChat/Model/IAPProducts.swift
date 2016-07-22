import Foundation

/// Product identifiers are unique strings registered on the app store.
public typealias ProductIdentifier = String

public class IAPProducts {
    private static let PREFIX = "wtf.wtfchat.wtfchatdev."

    public static let CIPHER_ALL = "\(PREFIX)CipherAll"
    public static let CIPHER_DOUBLE_CUTTER = "\(PREFIX)CipherDoubleCutter"
    public static let CIPHER_LEFT_CUTTER = "\(PREFIX)CipherLeftCutter"
    public static let CIPHER_RANDOM_CUTTER = "\(PREFIX)CipherRandomCutter"
    public static let CIPHER_SHUFFLE = "\(PREFIX)CipherShuffle"
    
    public static let HINTS_X2 = "\(PREFIX)HintsX2"
    public static let HINTS_1 = "\(PREFIX)Hints10"
    public static let HINTS_2 = "\(PREFIX)Hints30"
    public static let HINTS_3 = "\(PREFIX)Hints60"
    public static let HINTS_4 = "\(PREFIX)Hints100"
    public static let HINTS_5 = "\(PREFIX)Hints200"
    public static let HINTS_6 = "\(PREFIX)Hints1000"

    public static let HINTS_COUNT: [ProductIdentifier: Int] = [
            HINTS_1: 10,
            HINTS_2: 30,
            HINTS_3: 60,
            HINTS_4: 100,
            HINTS_5: 200,
            HINTS_6: 1000
    ]

    public static let CONSUMABLE: Set<ProductIdentifier> = [
        HINTS_1,
        HINTS_2,
        HINTS_3,
        HINTS_4,
        HINTS_5,
        HINTS_6
    ]
    
    public static let CIPHERS: Set<ProductIdentifier> = [
        CIPHER_ALL,
        CIPHER_DOUBLE_CUTTER,
        CIPHER_LEFT_CUTTER,
        CIPHER_RANDOM_CUTTER,
        CIPHER_SHUFFLE
    ]
    
    public static let OTHER: Set<ProductIdentifier> = [
        HINTS_X2
    ]
    
    public static let NON_CONSUMABLE: Set<ProductIdentifier> = CIPHERS.union(OTHER)
    
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

    public static func getHintsCount(productId: ProductIdentifier) -> Int {
        return HINTS_COUNT[productId] ?? 0
    }
}
