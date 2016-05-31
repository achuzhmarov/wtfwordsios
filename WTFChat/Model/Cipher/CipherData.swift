//
// Created by Artem Chuzhmarov on 31/05/16.
// Copyright (c) 2016 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class CipherData {
    var type: CipherType
    var difficulty: CipherDifficulty
    var maxStars: Int
    var cipher: Cipher

    var wins: Int = 0

    init(type: CipherType, difficulty: CipherDifficulty, maxStars: Int, cipher: Cipher) {
        self.type = type
        self.difficulty = difficulty
        self.maxStars = maxStars
        self.cipher = cipher
    }
}
