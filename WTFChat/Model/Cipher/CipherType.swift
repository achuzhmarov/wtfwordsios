//
// Created by Artem Chuzhmarov on 31/05/16.
// Copyright (c) 2016 Artem Chuzhmarov. All rights reserved.
//

enum CipherType : Int, CustomStringConvertible {
    case RightCutter = 0
    case LeftCutter
    case DoubleCutter
    case RandomCutter
    case Shuffle

    var description : String {
        get {
            switch self {
            case CipherType.RightCutter:
                return "Right Cutter"
            case CipherType.LeftCutter:
                return "Left Cutter"
            case CipherType.DoubleCutter:
                return "Double Cutter"
            case CipherType.RandomCutter:
                return "Random Cutter"
            case CipherType.Shuffle:
                return "Shuffle"
            }
        }
    }

    static func getAll() -> [CipherType] {
        return [.RightCutter, .LeftCutter, .DoubleCutter, .RandomCutter, .Shuffle]
    }
}