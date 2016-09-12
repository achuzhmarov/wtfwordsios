import Foundation
import StoreKit
import Localize_Swift

class InAppService: Service {
    private let inAppHelper: InAppHelper

    private let PAID_TITLE = "Paid".localized()
    private let BUY_TEXT = "Buy".localized()
    private let FOR_TEXT = "for".localized()

    private var products = [SKProduct]()

    init(inAppHelper: InAppHelper) {
        self.inAppHelper = inAppHelper
    }

    override func initService() {
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
        
        if let product = inAppHelper.getProduct(productId) {
            inAppHelper.purchaseProduct(product)
        }
    }

    func getHintsProductTitle(productId: ProductIdentifier) -> String? {
        if let product = inAppHelper.getProduct(productId) {
            let titleParts = product.localizedTitle.componentsSeparatedByString(" ")
            return titleParts[0]
        }

        return nil
    }

    func getProductTitle(productId: ProductIdentifier) -> String? {
        if let product = inAppHelper.getProduct(productId) {
            return product.localizedTitle.localized()
        }
        
        return nil
    }
    
    func getProductDescription(productId: ProductIdentifier) -> String? {
        if let product = inAppHelper.getProduct(productId) {
            return product.localizedDescription.localized()
        }
        
        return nil
    }
    
    func getProductPrice(productId: ProductIdentifier) -> String? {
        if !canMakePayments() {
            return "-"
        }
        
        if isPurchased(productId) {
            return PAID_TITLE
        }
        
        if let product = inAppHelper.getProduct(productId) {
            return product.localizedPrice().localized()
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
        return inAppHelper.isProductPurchased(productId)
    }
    
    func showBuyAlert(productId: ProductIdentifier, cancelFunc: (() -> Void)? = nil) {
                
        if (!canPurchase(productId) || isPurchased(productId)) {
            return
        }
        
        let productName = getProductTitle(productId)
        let productPrice = getProductPrice(productId)
        let productDescription = getProductDescription(productId)
        
        WTFTwoButtonsAlert.show(BUY_TEXT + " " + productName! + FOR_TEXT + " " + productPrice!,
            message: productDescription!,
            firstButtonTitle: BUY_TEXT,
            alertButtonAction: { () -> Void in
                self.purchaseProduct(productId)
            }, cancelButtonAction: { () -> Void in
                cancelFunc?()
        })
    }
    
    private func isProductExists(productId: ProductIdentifier) -> Bool {
        if inAppHelper.getProduct(productId) != nil {
            return true
        }
        
        return false
    }
    
    private func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
}