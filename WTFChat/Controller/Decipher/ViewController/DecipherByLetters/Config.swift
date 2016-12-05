//
//  Config.swift
//  Anagrams
//
//  Created by Caroline on 1/08/2014.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

import Foundation
import UIKit

//Random number generator
func randomNumber(minX:UInt32, maxX:UInt32) -> Int {
  let result = (arc4random() % (maxX - minX + 1)) + minX
  return Int(result)
}

let FontHUD = UIFont(name:"comic andy", size: 50.0)!
let FontHUDBig = UIFont(name:"comic andy", size:120.0)!

let LettersOnBoard = 21
let MaxLettersPerRow = 7
let MaxTargetsPerRow = 10
let TargetMargin: CGFloat = 2
let TileMargin: CGFloat = 6
let VerticalPadding: CGFloat = 8
