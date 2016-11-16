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

let TileMargin: CGFloat = 2.0
let TileMaxSide: CGFloat = 100.0

let FontHUD = UIFont(name:"comic andy", size: 62.0)!
let FontHUDBig = UIFont(name:"comic andy", size:120.0)!

// Sound effects
let SoundDing = "ding.mp3"
let SoundWrong = "wrong.m4a"
let SoundWin = "win.mp3"
let AudioEffectFiles = [SoundDing, SoundWrong, SoundWin]
