//
//  LvlService.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 29/10/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class LvlService {
    private let currentUserService: CurrentUserService

    init(currentUserService: CurrentUserService) {
        self.currentUserService = currentUserService
    }

    func getUserLvl() -> Int {
        return currentUserService.getUserLvl()
    }
    
    func getCurrentLvlExp() -> Int {
        return currentUserService.getUserExp() - getExpByLvl(currentUserService.getUserLvl())
    }
    
    func getNextLvlExp() -> Int {
        return getExpByLvl(currentUserService.getUserLvl() + 1) - getExpByLvl(currentUserService.getUserLvl())
    }
    
    private func getExpByLvl(lvl: Int) -> Int {
        let leftMultiplier = intPow(2, power: lvl / 5) - 1
        let rightMultiplier = intPow(2, power: lvl / 5 + 1)
        return leftMultiplier * 5000 + rightMultiplier * (lvl % 5) * 500
    }
}