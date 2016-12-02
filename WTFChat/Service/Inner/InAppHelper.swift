import StoreKit

/// Notification that is generated when a product is purchased.
public let IAPHelperProductPurchasedNotification = "IAPHelperProductPurchasedNotification"
public let IAPHelperProductPurchasedErrorNotification = "IAPHelperProductPurchasedErrorNotification"

public let IAPHelperProductRestoreNotification = "IAPHelperProductRestoreNotification"
public let IAPHelperProductRestoreErrorNotification = "IAPHelperProductRestoreErrorNotification"

/// Completion handler called when products are fetched.
public typealias RequestProductsCompletionHandler = (_ success: Bool, _ products: [SKProduct]) -> ()

/// A Helper class for In-App-Purchases, it can fetch products, tell you if a product has been purchased,
/// purchase products, and restore purchases.  Uses NSUserDefaults to cache if a product has been purchased.
open class InAppHelper: NSObject  {
    fileprivate let inAppNetworkService: InAppNetworkService
    fileprivate let currentUserService: CurrentUserService

    // Used to keep track of the possible products and which ones have been purchased.
    fileprivate let productIdentifiers: Set<ProductIdentifier>
    fileprivate var purchasedProductIdentifiers = Set<ProductIdentifier>()
  
    // Used by SKProductsRequestDelegate
    fileprivate var productsRequest: SKProductsRequest?
    fileprivate var completionHandler: RequestProductsCompletionHandler?

    fileprivate var products = [SKProduct]()

    /// MARK: - User facing API
  
    /// Initialize the helper.  Pass in the set of ProductIdentifiers supported by the app.
    init(inAppNetworkService: InAppNetworkService, currentUserService: CurrentUserService, productIdentifiers: Set<ProductIdentifier>) {
        self.inAppNetworkService = inAppNetworkService
        self.currentUserService = currentUserService

        self.productIdentifiers = productIdentifiers
        for productIdentifier in productIdentifiers {
            let purchased = UserDefaults.standard.bool(forKey: productIdentifier)
            
            if purchased {
                purchasedProductIdentifiers.insert(productIdentifier)
                print("Previously purchased: \(productIdentifier)")
            } else {
                print("Not purchased: \(productIdentifier)")
            }
        }
        
        super.init()

        SKPaymentQueue.default().add(self)
    }
  
    /// Gets the list of SKProducts from the Apple server calls the handler with the list of products.
    open func requestProductsWithCompletionHandler(_ handler: @escaping RequestProductsCompletionHandler) {
        completionHandler = handler
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
    }
  
    /// Initiates purchase of a product.
    open func purchaseProduct(_ product: SKProduct) {
        print("Buying \(product.productIdentifier)...")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
  
    /// Given the product identifier, returns true if that product has been purchased.
    open func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
        return purchasedProductIdentifiers.contains(productIdentifier)
    }
  
    /// If the state of whether purchases have been made is lost  (e.g. the
    /// user deletes and reinstalls the app) this will recover the purchases.
    open func restoreCompletedTransactions() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
  
    open class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
}

// This extension is used to get a list of products, their titles, descriptions,
// and prices from the Apple server.

extension InAppHelper: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Loaded list of products...")
        products = response.products
        completionHandler?(true, products)
        clearRequest()
    }

    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products.")
        print("Error: \(error)")
        clearRequest()
    }

    fileprivate func clearRequest() {
        productsRequest = nil
        completionHandler = nil
    }
}


extension InAppHelper: SKPaymentTransactionObserver {
    /// This is a function called by the payment queue, not to be called directly.
    /// For each transaction act accordingly, save in the purchased cache, issue notifications,
    /// mark the transaction as complete.
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
                case .purchased:
                    completeTransaction(transaction)
                    break
                case .failed:
                    failedTransaction(transaction)
                    break
                case .restored:
                    restoreTransaction(transaction)
                    break
                case .deferred:
                    break
                case .purchasing:
                    break
            }
        }
    }
  
    fileprivate func completeTransaction(_ transaction: SKPaymentTransaction) {
        let productId = transaction.payment.productIdentifier
        print("completeTransaction... \(productId)")
        validateReceiptForTransaction(transaction, isRestore: false)
    }
  
    fileprivate func restoreTransaction(_ transaction: SKPaymentTransaction) {
        let productId = transaction.payment.productIdentifier
        //let productId = transaction.originalTransaction!.payment.productIdentifier
        print("restoreTransaction... \(productId)")
        validateReceiptForTransaction(transaction, isRestore: true)
    }
    
    fileprivate func validateReceiptForTransaction(_ transaction: SKPaymentTransaction, isRestore: Bool) {
        if let receipt =  Bundle.main.appStoreReceiptURL {
            if let data = try? Data(contentsOf: receipt) {
                let receiptString = data.base64EncodedString(options: [])
                let productId = transaction.payment.productIdentifier
                
                inAppNetworkService.verifyInAppPurchase(receiptString, productId: productId, completion:
                {(valid, error) -> Void in
                    
                    if (error != nil) {
                        print(error!)
                        self.saveError(transaction, isRestore: isRestore)
                    } else if (valid!) {
                        print("Successfully verified receipt!")

                        self.provideContentForProduct(transaction.payment.productIdentifier, isRestore: isRestore)
                        SKPaymentQueue.default().finishTransaction(transaction)
                    } else {
                        print("Server validation error")
                    }
                })
            } else {
                saveError(transaction)
            }
        } else {
            saveError(transaction)
        }
    }
    
    fileprivate func saveError(_ transaction: SKPaymentTransaction, isRestore: Bool = false) {
        let productId = transaction.payment.productIdentifier
        
        print("Failed to validate receipt for \(productId)")
        
        if (isRestore) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: IAPHelperProductRestoreErrorNotification), object: productId)
        } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: IAPHelperProductPurchasedErrorNotification), object: productId)
        }
    }
  
    // Helper: Saves the fact that the product has been purchased and posts a notification.
    fileprivate func provideContentForProduct(_ productId: String, isRestore: Bool) {
        if (IAPProducts.isConsumable(productId)) {
            let wtfBought = getWtfCount(productId)

            if (wtfBought > 0) {
                currentUserService.addWtf(wtfBought)
            }
        } else if (IAPProducts.isNonConsumbale(productId)) {
            purchasedProductIdentifiers.insert(productId)
            UserDefaults.standard.set(true, forKey: productId)
            UserDefaults.standard.synchronize()
        }
    
        if (isRestore) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: IAPHelperProductRestoreNotification), object: productId)
        } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: IAPHelperProductPurchasedNotification), object: productId)
        }
    }

    func getWtfCount(_ productId: ProductIdentifier) -> Int {
        if let product = getProduct(productId) {
            let titleParts = product.localizedTitle.components(separatedBy: " ")
            let count = Int(titleParts[0])!

            //TODO - for backward compatibility with old inApps
            let lowercaseTitle = product.localizedTitle.lowercased()
            if (lowercaseTitle.contains("hints") || lowercaseTitle.contains("подсказок")) {
                return count * 2
            }

            return count
        }

        return 0
    }

    func getProduct(_ productId: ProductIdentifier) -> SKProduct? {
        for product in products {
            if (product.productIdentifier == productId) {
                return product
            }
        }

        return nil
    }
    
    fileprivate func failedTransaction(_ transaction: SKPaymentTransaction) {
        print("failedTransaction...")
        
        if let transactionError = transaction.error as? NSError {
            if transactionError.code != SKError.Code.paymentCancelled.rawValue {
                print("Transaction error: \(transaction.error!.localizedDescription)")
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: IAPHelperProductPurchasedErrorNotification), object: nil)
            }
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}

extension SKProduct {
    func localizedPrice() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)!
    }
}
