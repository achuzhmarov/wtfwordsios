//
// Created by Artem Chuzhmarov on 31/05/16.
// Copyright (c) 2016 Artem Chuzhmarov. All rights reserved.
//

enum CipherDifficulty : Int, CustomStringConvertible {
    case Easy = 0
    case Normal
    case Hard

    var description : String {
        get {
            switch self {
            case CipherDifficulty.Easy:
                return "Easy"
            case CipherDifficulty.Normal:
                return "Normal"
            case CipherDifficulty.Hard:
                return "Hard"
            }
        }
    }

    static func getAll() -> [CipherDifficulty] {
        return [.Easy, .Normal, .Hard]
    }
}