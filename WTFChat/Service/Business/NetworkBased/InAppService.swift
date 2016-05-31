//
//  InAppService.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 14/12/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation
import StoreKit

class InAppService {
    private let inAppHelper: InAppHelper
    private let currentUserService: CurrentUserService
    
    private var products = [SKProduct]()

    init(inAppHelper: InAppHelper, currentUserService: CurrentUserService) {
        self.inAppHelper = inAppHelper
        self.currentUserService = currentUserService
    }

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
        if !canMakePayments() {
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
        if canMakePayments() && isProductExists(productId) {
            return true
        }
    
        return false
    }
    
    func isPurchased(productId: ProductIdentifier) -> Bool {
        if (IAPProducts.CONSUMABLE.contains(productId)) {
            return false
        }
        
        if (IAPProducts.OTHER.contains(productId)) {
            return currentUserService.isContainBuyNonConsum(productId)
        }
        
        return false
    }
    
    func showBuyAlert(productId: ProductIdentifier, viewPresenter: UIViewController,
            cancelFunc: (() -> Void)? = nil) {
                
        if (!canPurchase(productId) || isPurchased(productId)) {
            return
        }
        
        let productName = getProductTitle(productId)
        let productPrice = getProductPrice(productId)
        let productDescription = getProductDescription(productId)
        
        WTFTwoButtonsAlert.show("Buy \(productName!) for \(productPrice!)",
            message: productDescription!,
            firstButtonTitle: "Ok",
            secondButtonTitle: "Cancel",
            viewPresenter: viewPresenter,
            alertButtonAction: { () -> Void in
                self.purchaseProduct(productId)
            }, cancelButtonAction: { () -> Void in
                cancelFunc?()
        })
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
    
    private func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
}