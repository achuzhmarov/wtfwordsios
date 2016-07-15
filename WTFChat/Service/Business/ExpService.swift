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

        while currentExp >= 0 {
            currentExp -= (1 + lvlStage) * BASE_LVL_EXP

            lvlStep += 1

            if (lvlStep == LVL_EXP_STEP) {
                lvlStep = 0
                lvlStage += 1
            }
        }

        return lvlStage * LVL_EXP_STEP + lvlStep
    }

    private func getExpByLvl(lvl: Int) -> Int {
        let expLvl = lvl - 1

        let leftMultiplier = intPow(2, power: expLvl / LVL_EXP_STEP) - 1
        let rightMultiplier = intPow(2, power: expLvl / LVL_EXP_STEP + 1)
        return leftMultiplier * 10 * BASE_LVL_EXP / 2 + rightMultiplier * (expLvl % LVL_EXP_STEP) * BASE_LVL_EXP / 2
    }

    private func intPow(radix: Int, power: Int) -> Int {
        return Int(pow(Double(radix), Double(power)))
    }

    func calculateExpForMessage(message: Message) -> Int {
        var dupWordsInMessage = Set<String>()

        var expResult = 0

        for word in message.words {
            expResult += calculateExpForWord(
                word,
                wasInMessage: dupWordsInMessage.contains(word.text),
                cipherDifficulty:message.cipherDifficulty
            )

            dupWordsInMessage.insert(word.text)
        }

        if message.getMessageStatus() == .Success {
            expResult *= 3
        }

        return expResult
    }

    private func calculateExpForWord(word: Word, wasInMessage: Bool, cipherDifficulty: CipherDifficulty) -> Int {
        if word.type != .Success && word.type != .CloseTry {
            return 0
        }

        if wasInMessage {
            return 0
        }

        if word.getCharCount() == 2 {
            if word.type == .CloseTry {
                return 0
            }

            return 1
        }

        switch cipherDifficulty {
            case .Easy:
                return 1
            case .Normal:
                if word.type == .CloseTry {
                    return 1
                }

                if word.getCharCount() == 3 {
                    return 2
                }

                return 3
            case .Hard:
                if word.type == .CloseTry {
                    if word.getCharCount() == 3 {
                        return 2
                    }

                    return 5
                }

                if word.getCharCount() == 3 {
                    return 3
                }

                return 10
        }
    }
}