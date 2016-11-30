import Foundation

class ExpService: Service {
    fileprivate let BASE_LVL_EXP = 1000
    fileprivate let LVL_EXP_STEP = 5

    fileprivate let LVL_WTFS_STEP = 5
    fileprivate let WTFS_PER_STEP = 10

    func getWtfsForLvl(_ lvl: Int) -> Int {
        return ((lvl / LVL_WTFS_STEP) + 1) * WTFS_PER_STEP
    }

    func getCurrentLvlExp(_ exp: Int) -> Int {
        let currentLvl = getLvl(exp)
        return exp - getExpByLvl(currentLvl)
    }

    func getNextLvlExp(_ exp: Int) -> Int {
        let currentLvl = getLvl(exp)
        return getExpByLvl(currentLvl + 1) - getExpByLvl(currentLvl)
    }

    func getLvl(_ exp: Int) -> Int {
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

    fileprivate func getExpByLvl(_ lvl: Int) -> Int {
        let expLvl = lvl - 1
        let lvlStage = expLvl / LVL_EXP_STEP
        let stepsOnLvl = expLvl % LVL_EXP_STEP
        let expPerLvlStep = (lvlStage + 1) * BASE_LVL_EXP

        let stepsExp = expPerLvlStep * stepsOnLvl

        let levelStageMultiplier = ((1 + lvlStage) * lvlStage) / 2
        let lvlStageExp = levelStageMultiplier * LVL_EXP_STEP * BASE_LVL_EXP

        return lvlStageExp + stepsExp

        //let leftMultiplier = intPow(2, power: expLvl / LVL_EXP_STEP) - 1
        //let rightMultiplier = intPow(2, power: expLvl / LVL_EXP_STEP + 1)
        //return leftMultiplier * 10 * BASE_LVL_EXP / 2 + rightMultiplier * (expLvl % LVL_EXP_STEP) * BASE_LVL_EXP / 2
    }

    fileprivate func intPow(_ radix: Int, power: Int) -> Int {
        return Int(pow(Double(radix), Double(power)))
    }

    func calculateExpForMessage(_ message: Message) -> Int {
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

        if message.getMessageStatus() == .success {
            expResult *= 3
        }

        return expResult
    }

    fileprivate func calculateExpForWord(_ word: Word, wasInMessage: Bool, cipherDifficulty: CipherDifficulty) -> Int {
        if word.type != .success && word.type != .closeTry {
            return 0
        }

        if wasInMessage {
            return 0
        }

        if word.getCharCount() == 2 {
            if word.type == .closeTry {
                return 0
            }

            return 1
        }

        switch cipherDifficulty {
            case .easy:
                return 1
            case .normal:
                if word.type == .closeTry {
                    return 1
                }

                if word.getCharCount() == 3 {
                    return 2
                }

                return 3
            case .hard:
                if word.type == .closeTry {
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
