//
//  CipherService.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 17/12/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

let cipherService = CipherService()

class CipherService {
    func isOwnedCipher(productId: ProductIdentifier) -> Bool {
        if (!IAPProducts.CIPHERS.contains(productId)) {
            return false
        }
        
        if (isAllPurchased()) {
            return true
        }
        
        if (isProductPurchased(productId)) {
            return true
        }
        
        if let category = CipherFactory.getCipherCategory(productId) {
            if (isLvlEnough(category, mode: CipherMode.Hard)) {
                return true
            }
        }
        
        return false
    }
    
    func canUseCipher(category: CipherCategory, mode: CipherMode) -> Bool {
        if (isAllPurchased()) {
            return true
        }
        
        if (isCipherPurchased(category)) {
            return true
        }
        
        if (isLvlEnough(category, mode: mode)) {
            return true
        }
        
        return false
    }
    
    func canUseCipher(cipherType: CipherType) -> Bool {
        let (category, mode) = CipherFactory.getCategoryAndMode(cipherType)
        return canUseCipher(category, mode: mode)
    }

    private func isAllPurchased() -> Bool {
        return userService.isContainBuyNonConsum(IAPProducts.CIPHER_ALL)
    }
    
    private func isCipherPurchased(category: CipherCategory) -> Bool {
        if let productId = CipherFactory.getProductId(category) {
            return userService.isContainBuyNonConsum(productId)
        }
        
        return false
    }
    
    private func isProductPurchased(productId: ProductIdentifier) -> Bool {
        return userService.isContainBuyNonConsum(productId)
    }
    
    private func isLvlEnough(category: CipherCategory, mode: CipherMode) -> Bool {
        if let cipherLvl = CipherFactory.getCipherLvl(category, mode: mode) {
            let userLvl = userService.getUserLvl()
            
            return (userLvl >= cipherLvl)
        }
        
        return false
    }
}