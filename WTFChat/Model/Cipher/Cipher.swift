//
// Created by Artem Chuzhmarov on 31/05/16.
// Copyright (c) 2016 Artem Chuzhmarov. All rights reserved.
//

protocol Cipher {
    func getTextForDecipher(word: Word) -> String
}