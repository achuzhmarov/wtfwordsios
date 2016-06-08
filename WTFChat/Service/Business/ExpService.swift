//
//  ExpService.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 29/10/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class ExpService: Service {
    private let BASE_LVL_EXP = 1000
    private let LVL_EXP_STEP = 5

    func getCurrentLvlExp(exp: Int) -> Int {
        let currentLvl = getLvl(exp)
        return exp - getExpByLvl(currentLvl)
    }

    func getNextLvlExp(exp: Int) -> Int {
        let currentLvl = getLvl(exp)
        return getExpByLvl(currentLvl + 1) - getExpByLvl(currentLvl)
    }

    func getLvl(exp: Int) -> Int {
        //increment every LVL_EXP_STEP levels
        var lvlStage = 0

        //zero on the beginning of the next stage
        var lvlStep = 0

        var currentExp = exp

        while currentExp > 0 {
            currentExp -= (1 + lvlStage) * BASE_LVL_EXP

            lvlStep += 1

            if (lvlStep == LVL_EXP_STEP) {
                lvlStep = 0
                lvlStage += 1
            }
        }

        return lvlStage * LVL_EXP_STEP + lvlStep - 1
    }

    private func getExpByLvl(lvl: Int) -> Int {
        let leftMultiplier = intPow(2, power: lvl / LVL_EXP_STEP) - 1
        let rightMultiplier = intPow(2, power: lvl / LVL_EXP_STEP + 1)
        return leftMultiplier * 10 * BASE_LVL_EXP / 2 + rightMultiplier * (lvl % LVL_EXP_STEP) * BASE_LVL_EXP / 2
    }

    private func intPow(radix: Int, power: Int) -> Int {
        return Int(pow(Double(radix), Double(power)))
    }
}