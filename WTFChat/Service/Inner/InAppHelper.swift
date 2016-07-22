//
//  InAppHelper.swift
//  inappragedemo
//
//  Created by Ray Fix on 5/1/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import StoreKit

/// Notification that is generated when a product is purchased.
public let IAPHelperProductPurchasedNotification = "IAPHelperProductPurchasedNotification"
public let IAPHelperProductPurchasedErrorNotification = "IAPHelperProductPurchasedErrorNotification"

public let IAPHelperProductRestoreNotification = "IAPHelperProductRestoreNotification"
public let IAPHelperProductRestoreErrorNotification = "IAPHelperProductRestoreErrorNotification"

/// Completion handler called when products are fetched.
public typealias RequestProductsCompletionHandler = (success: Bool, products: [SKProduct]) -> ()

/// A Helper class for In-App-Purchases, it can fetch products, tell you if a product has been purchased,
/// purchase products, and restore purchases.  Uses NSUserDefaults to cache if a product has been purchased.
public class InAppHelper: NSObject  {
    /// MARK: - Private Properties
  
    private let inAppNetworkService: InAppNetworkService
    private let currentUserService: CurrentUserService

    // Used to keep track of the possible products and which ones have been purchased.
    private let productIdentifiers: Set<ProductIdentifier>
    private var purchasedProductIdentifiers = Set<ProductIdentifier>()
  
    // Used by SKProductsRequestDelegate
    private var productsRequest: SKProductsRequest?
    private var completionHandler: RequestProductsCompletionHandler?
  
    /// MARK: - User facing API
  
    /// Initialize the helper.  Pass in the set of ProductIdentifiers supported by the app.
    init(inAppNetworkService: InAppNetworkService, currentUserService: CurrentUserService, productIdentifiers: Set<ProductIdentifier>) {
        self.inAppNetworkService = inAppNetworkService
        self.currentUserService = currentUserService

        self.productIdentifiers = productIdentifiers
        for productIdentifier in productIdentifiers {
            let purchased = NSUserDefaults.standardUserDefaults().boolForKey(productIdentifier)
            
            if purchased {
                purchasedProductIdentifiers.insert(productIdentifier)
                print("Previously purchased: \(productIdentifier)")
            } else {
                print("Not purchased: \(productIdentifier)")
            }
        }
        
        super.init()
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
  
    /// Gets the list of SKProducts from the Apple server calls the handler with the list of products.
    public func requestProductsWithCompletionHandler(handler: RequestProductsCompletionHandler) {
        completionHandler = handler
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
    }
  
    /// Initiates purchase of a product.
    public func purchaseProduct(product: SKProduct) {
        print("Buying \(product.productIdentifier)...")
        let payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
  
    /// Given the product identifier, returns true if that product has been purchased.
    public func isProductPurchased(productIdentifier: ProductIdentifier) -> Bool {
        return purchasedProductIdentifiers.contains(productIdentifier)
    }
  
    /// If the state of whether purchases have been made is lost  (e.g. the
    /// user deletes and reinstalls the app) this will recover the purchases.
    public func restoreCompletedTransactions() {
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
  
    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
}

// This extension is used to get a list of products, their titles, descriptions,
// and prices from the Apple server.

extension InAppHelper: SKProductsRequestDelegate {
    public func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        print("Loaded list of products...")
        let products = response.products
        completionHandler?(success: true, products: products)
        clearRequest()
    }

    public func request(request: SKRequest, didFailWithError error: NSError) {
        print("Failed to load list of products.")
        print("Error: \(error)")
        clearRequest()
    }

    private func clearRequest() {
        productsRequest = nil
        completionHandler = nil
    }
}


extension InAppHelper: SKPaymentTransactionObserver {
    /// This is a function called by the payment queue, not to be called directly.
    /// For each transaction act accordingly, save in the purchased cache, issue notifications,
    /// mark the transaction as complete.
    public func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
                case .Purchased:
                    completeTransaction(transaction)
                    break
                case .Failed:
                    failedTransaction(transaction)
                    break
                case .Restored:
                    restoreTransaction(transaction)
                    break
                case .Deferred:
                    break
                case .Purchasing:
                    break
            }
        }
    }
  
    private func completeTransaction(transaction: SKPaymentTransaction) {
        let productId = transaction.payment.productIdentifier
        print("completeTransaction... \(productId)")
        validateReceiptForTransaction(transaction, isRestore: false)
    }
  
    private func restoreTransaction(transaction: SKPaymentTransaction) {
        let productId = transaction.payment.productIdentifier
        //let productId = transaction.originalTransaction!.payment.productIdentifier
        print("restoreTransaction... \(productId)")
        validateReceiptForTransaction(transaction, isRestore: true)
    }
    
    private func validateReceiptForTransaction(transaction: SKPaymentTransaction, isRestore: Bool) {
        if let receipt =  NSBundle.mainBundle().appStoreReceiptURL {
            if let data = NSData(contentsOfURL: receipt) {
                let receiptString = data.base64EncodedStringWithOptions([])
                let productId = transaction.payment.productIdentifier
                
                inAppNetworkService.verifyInAppPurchase(receiptString, productId: productId, completion:
                {(valid, error) -> Void in
                    
                    if (error != nil) {
                        print(error)
                        self.saveError(transaction, isRestore: isRestore)
                    } else if (valid!) {
                        print("Successfully verified receipt!")

                        self.provideContentForProduct(transaction.payment.productIdentifier, isRestore: isRestore)
                        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
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
    
    private func saveError(transaction: SKPaymentTransaction, isRestore: Bool = false) {
        let productId = transaction.payment.productIdentifier
        
        print("Failed to validate receipt for \(productId)")
        
        if (isRestore) {
            NSNotificationCenter.defaultCenter().postNotificationName(IAPHelperProductRestoreErrorNotification, object: productId)
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(IAPHelperProductPurchasedErrorNotification, object: productId)
        }
    }
  
    // Helper: Saves the fact that the product has been purchased and posts a notification.
    private func provideContentForProduct(productId: String, isRestore: Bool) {
        if (IAPProducts.isConsumable(productId)) {
            let hintsBought = IAPProducts.getHintsCount(productId)

            if (hintsBought > 0) {
                currentUserService.addHints(hintsBought)
            }
        } else if (IAPProducts.isNonConsumbale(productId)) {
            purchasedProductIdentifiers.insert(productId)
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: productId)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    
        if (isRestore) {
            NSNotificationCenter.defaultCenter().postNotificationName(IAPHelperProductRestoreNotification, object: productId)
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(IAPHelperProductPurchasedNotification, object: productId)
        }
    }
    
    private func failedTransaction(transaction: SKPaymentTransaction) {
        print("failedTransaction...")
        
        if transaction.error!.code != SKErrorCode.PaymentCancelled.rawValue {
            print("Transaction error: \(transaction.error!.localizedDescription)")
            
            NSNotificationCenter.defaultCenter().postNotificationName(IAPHelperProductPurchasedErrorNotification, object: nil)
        }
        
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
}

extension SKProduct {
    func localizedPrice() -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.locale = self.priceLocale
        return formatter.stringFromNumber(self.price)!
    }
}