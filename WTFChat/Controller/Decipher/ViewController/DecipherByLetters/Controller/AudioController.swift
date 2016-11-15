//
//  AudioController.swift
//  Anagrams
//
//  Created by Caroline Begbie on 12/04/2015.
//  Copyright (c) 2015 Caroline. All rights reserved.
//

import Foundation
import AVFoundation

class AudioController {
  fileprivate var audio = [String:AVAudioPlayer]()
  
    func preloadAudioEffects(effectFileNames:[String]) {
        for effect in AudioEffectFiles {
            do {
                var soundURL = URL.init(fileURLWithPath: Bundle.main.resourcePath!);
                soundURL.appendPathComponent(effect)
                
                let player = try AVAudioPlayer(contentsOf: soundURL)
                
                player.numberOfLoops = 0
                player.prepareToPlay()
                
                audio[effect] = player
            } catch {
                assert(false, "Load sound failed")
            }
        }
    }
  
  func playEffect(_ name:String) {
    if let player = audio[name] {
      if player.isPlaying {
        player.currentTime = 0
      } else {
        player.play()
      }
    }
  }
  
}

