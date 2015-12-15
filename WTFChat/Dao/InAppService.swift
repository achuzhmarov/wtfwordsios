//
//  InAppService.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 14/12/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation
import StoreKit

let inAppService = InAppService()

/*func initInAppSerivce() -> InAppService {
    let inAppService = InAppService()
    
    inAppService.getProductList()
    
    return inAppService
}*/

class InAppService {
    let inAppHelper = IAPHelper(productIdentifiers: IAPProducts.NON_CONSUMABLE)

    var products = [SKProduct]()
    
    func getProductList() {
        inAppHelper.requestProductsWithCompletionHandler { success, products in
            if success {
                self.products = products
            }
        }
    }
    
    func restorePurchased() {
        inAppHelper.restoreCompletedTransactions()
    }
    
    func purchaseProduct(productId: ProductIdentifier) {
        if !canPurchase(productId) {
            return
        }
        
        if let product = getProduct(productId) {
            inAppHelper.purchaseProduct(product)
        }
    }
    
    func getProductTitle(productId: ProductIdentifier) -> String? {
        if let product = getProduct(productId) {
            return product.localizedTitle
        }
        
        return nil
    }
    
    func getProductDescription(productId: ProductIdentifier) -> String? {
        if let product = getProduct(productId) {
            return product.localizedDescription
        }
        
        return nil
    }
    
    func getProductPrice(productId: ProductIdentifier) -> String? {
        if (!canMakePayments()) {
            return "Not available"
        }
        
        if isPurchased(productId) {
            return "Owned"
        }
        
        if let product = getProduct(productId) {
            return product.localizedPrice()
        }
        
        return nil
    }
    
    func canPurchase(productId: ProductIdentifier) -> Bool {
        if (!canMakePayments() || isPurchased(productId) || !isProductExists(productId)) {
            return false
        }
    
        return true
    }
    
    private func getProduct(productId: ProductIdentifier) -> SKProduct? {
        for product in products {
            if (product.productIdentifier == productId) {
                return product
            }
        }
        
        return nil
    }
    
    private func isProductExists(productId: ProductIdentifier) -> Bool {
        if getProduct(productId) != nil {
            return true
        }
        
        return false
    }
    
    private func isPurchased(productId: ProductIdentifier) -> Bool {
        return inAppHelper.isProductPurchased(productId)
    }
    
    private func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
}