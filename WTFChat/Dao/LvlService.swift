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
        return (2 ^^ (lvl / 5) - 1) * 10000 + (2 ^^ (lvl / 5 + 1)) * (lvl % 5) * 1000
    }
}