//
//  LvlService.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 29/10/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

let lvlService = LvlService()

class LvlService {
    func getUserLvl() -> Int {
        return userService.getUserLvl()
    }
    
    func getCurrentLvlExp() -> Int {
        return userService.getUserExp() - getExpByLvl(userService.getUserLvl())
    }
    
    func getNextLvlExp() -> Int {
        return getExpByLvl(userService.getUserLvl() + 1) - getExpByLvl(userService.getUserLvl())
    }
    
    private func getExpByLvl(lvl: Int) -> Int {
        let leftMultiplier = intPow(2, power: lvl / 5) - 1
        let rightMultiplier = intPow(2, power: lvl / 5 + 1)
        return leftMultiplier * 5000 + rightMultiplier * (lvl % 5) * 500
    }
}