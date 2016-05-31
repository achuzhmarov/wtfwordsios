//
//  CipherService.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 17/12/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

/*class CipherService {
    private let currentUserService: CurrentUserService

    init(currentUserService: CurrentUserService) {
        self.currentUserService = currentUserService
    }

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

    func canUseCipher(type: CipherType, difficulty: CipherDifficulty) -> Bool {
        if (isAllPurchased()) {
            return true
        }
        
        if (isCipherPurchased(type)) {
            return true
        }
        
        if (isLvlEnough(type, difficulty: difficulty)) {
            return true
        }
        
        return false
    }

    func canUseCipher(cipherType: CipherType) -> Bool {
        let (category, mode) = CipherFactory.getCategoryAndMode(cipherType)
        return canUseCipher(category, mode: mode)
    }

    private func isAllPurchased() -> Bool {
        return currentUserService.isContainBuyNonConsum(IAPProducts.CIPHER_ALL)
    }
    
    private func isCipherPurchased(category: CipherCategory) -> Bool {
        if let productId = CipherFactory.getProductId(category) {
            return currentUserService.isContainBuyNonConsum(productId)
        }
        
        return false
    }

    private func isProductPurchased(productId: ProductIdentifier) -> Bool {
        return currentUserService.isContainBuyNonConsum(productId)
    }
    
    private func isLvlEnough(type: CipherType, difficulty: CipherDifficulty) -> Bool {
        if let cipherLvl = CipherFactory.getCipherLvl(type, difficulty: difficulty) {
            let userLvl = currentUserService.getUserLvl()
            
            return (userLvl >= cipherLvl)
        }
        
        return false
    }
}*/